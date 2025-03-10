
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:namer_app/bibliotecas.dart';

class Profilels extends StatefulWidget { 
  @override
  _ProfilelsState createState() => _ProfilelsState();
}

class _ProfilelsState extends State<Profilels> {
  final Color green = Color.fromARGB(255, 188, 185, 225);
  // Imagem padrão caso nenhuma seja selecionada
  final String defaultImageUrl =
      "https://cdn-2.worldwebs.com/assets/images/f/ed0b52349d39d39d5693cac6bb0cc06f.jpeg?666490501";

  File? _selectedImageFile;
  String? _selectedAssetImage;

  // Função que carrega os dados do usuário e a imagem de perfil do Firestore
  Future<Map<String, dynamic>> _fetchUserProfile(String uid) async {
    if (uid.isEmpty) {
      throw Exception("UID inválido ou não encontrado.");
    }
    try {
      final firestore = FirebaseFirestore.instance;
      // Dados do usuário na coleção 'usuarios'
      final userDocSnapshot = await firestore.collection('usuarios').doc(uid).get();
      Map<String, dynamic> userData;
      if (userDocSnapshot.exists) {
        userData = userDocSnapshot.data()!;
      } else {
        userData = {
          'nome': 'Nome não informado',
          'dataNascimento': 'Data não informada',
          'genero': 'Gênero não informado',
          'categoriaFavorita': 'Categoria não informada',
        };
      }
      // Tenta recuperar a imagem salva na coleção 'imagens'
      final imageDocSnapshot = await firestore.collection('imagens').doc(uid).get();
      if (imageDocSnapshot.exists) {
        userData['profileImageUrl'] = imageDocSnapshot.data()?['url'];
        userData['profileImageType'] = imageDocSnapshot.data()?['type'];
      } else {
        userData['profileImageUrl'] = defaultImageUrl;
        userData['profileImageType'] = 'network';
      }
      return userData;
    } catch (e) {
      throw Exception("Erro ao acessar Firestore: $e");
    }
  }

  Future<String> _getUid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('uid') ?? '';
    } catch (e) {
      throw Exception("Erro ao recuperar o UID: $e");
    }
  }


  // Upload da imagem para o Firebase Storage e retorna o download URL
 
  
  Future<void> _uploadAndSaveImage(File image) async {
  final uid = await _getUid();
  final imageUrl = await _uploadImageToSupabase(image, uid);
  
  await FirebaseFirestore.instance
      .collection('imagens')
      .doc(uid)
      .set({'url': imageUrl, 'type': 'file'});
}

  // Salva o caminho do asset escolhido no Firestore
  Future<void> _saveAssetImage(String assetPath) async {
    final uid = await _getUid();
    await FirebaseFirestore.instance
        .collection('imagens')
        .doc(uid)
        .set({'url': assetPath, 'type': 'asset'});
  }

  // Retorna a imagem de perfil baseada na seleção do usuário ou na imagem salva
  ImageProvider _getProfileImage(String profileImageUrl, String profileImageType) {
    if (_selectedImageFile != null) {
      return FileImage(_selectedImageFile!);
    } else if (_selectedAssetImage != null) {
      return AssetImage(_selectedAssetImage!);
    } else {
      if (profileImageType == 'asset') {
        return AssetImage(profileImageUrl);
      } else {
        return NetworkImage(profileImageUrl);
      }
    }
  }

  // Exibe as opções para seleção de imagem
  void _showImageSelectionOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Selecionar da galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('Selecionar dos assets'),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectImageFromAssets();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Seleciona uma imagem da galeria, exibe e salva no Firestore
  Future<void> _pickImageFromGallery() async {
  final pickedFile =
      await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    final imageFile = File(pickedFile.path);
    setState(() {
      _selectedImageFile = imageFile;
      _selectedAssetImage = null; // Reseta a seleção de assets
    });
    await _uploadAndSaveImage(imageFile);
  }
}


  // Abre uma nova tela para seleção de imagem dos assets e salva no Firestore
  Future<void> _selectImageFromAssets() async {
    final selectedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AssetImageSelectionScreen()),
    );

    if (selectedImage != null) {
      setState(() {
        _selectedAssetImage = selectedImage;
        _selectedImageFile = null; // Reseta a seleção da galeria
      });
      await _saveAssetImage(selectedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: green,
        title: Center(
          child: Text(
            "Perfil",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/criacao');
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUid().then((uid) => _fetchUserProfile(uid)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar os dados: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'Nenhum dado encontrado.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          } else {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 24),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        // Ao tocar, permite selecionar nova imagem
                        GestureDetector(
                          onTap: _showImageSelectionOptions,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundImage: _getProfileImage(
                              data['profileImageUrl'],
                              data['profileImageType'],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          data['nome'] ?? 'Nome não disponível',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              _buildInfoColumn(
                                Icons.calendar_today_outlined,
                                data['dataNascimento'] ?? 'Não informado',
                              ),
                              _buildInfoColumn(
                                Icons.games,
                                data['genero'] ?? 'Não informado',
                              ),
                              _buildInfoColumn(
                                Icons.category,
                                data['categoriaFavorita'] ?? 'Não informado',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/apagarperfil');
                      },
                      child: Text(
                        'Apagar conta?',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String label) {
    return Flexible(
      child: Column(
        children: <Widget>[
          Icon(icon, color: Colors.white),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// Tela para seleção de imagens dos assets
class AssetImageSelectionScreen extends StatelessWidget {
  // Defina os caminhos das imagens disponíveis na pasta assets/imagens.
  final List<String> assetImages = [
    'assets/images/gato1.jpeg',
    'assets/images/gato2.jpg',
    'assets/images/gato3.jpg',
    // Adicione mais caminhos conforme necessário.
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecione uma imagem"),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: assetImages.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Número de colunas
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final imagePath = assetImages[index];
          return GestureDetector(
            onTap: () {
              // Retorna o caminho da imagem selecionada
              Navigator.pop(context, imagePath);
            },
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}


Future<String> _uploadImageToSupabase(File image, String uid) async {
  final supabase = Supabase.instance.client;
  final bucketName = 'profile-images';
  final filePath = 'profileImages/$uid.jpg';

  try {
    // Pass the file directly instead of its bytes
    await supabase.storage.from(bucketName).upload(filePath, image);

    // Generate and return the public URL
    final publicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
    return publicUrl;
  } catch (e) {
    throw Exception("Erro ao fazer upload da imagem: $e");
  }
}