


import 'bibliotecas.dart';
import 'firebase.dart';

import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 31, 81, 157),
          ),
        ),
        initialRoute: '/login', // Define a rota inicial
        routes: {
          '/login': (context) => LoginPage(),
          '/cadastro': (context) => CadastroPage(),
          '/home': (context) => MyHomePage(),
          '/criacao': (context)=>ProfileCreationPage(),
          '/reset':(context)=>SenhaPage(),
          '/apagar':(context)=>DeleteAccountPage(),
          '/apagarperfil':(context)=>DeleteProfilePage(),
          '/quiz':(context)=>QuizPage()
        },
      ),
    );
  }
}



// Tela de Login
// Tela de Login
// Importações necessárias
// Classe para interagir com o Firebase





// Tela de Cadastro

class CadastroPage extends StatefulWidget {
  @override
  State <CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  final imagebookshelf = "https://th.bing.com/th/id/OIP.qGu31yC_X4ZoXeqmoOxy2wHaHa?rs=1&pid=ImgDetMain";

  // Controladores para os campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 188, 185, 225),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(color: Color.fromARGB(255, 188, 185, 225)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "GAME LIBRARY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Image.network(
                      imagebookshelf,
                      width: 150,
                      height: 150,
                      colorBlendMode: BlendMode.modulate,
                      color: Color.fromARGB(255, 193, 190, 227),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Crie sua conta!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 20),

                      // Campo Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o email';
                          }
                          final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!regex.hasMatch(value)) {
                            return 'Informe um email válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Campo Senha
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a senha';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Botão Cadastrar
                      ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final senha = _senhaController.text;

      final authService = AuthService();
      final errorMessage = await authService.cadastrarUsuario(email, senha);

      if (errorMessage == null) {
        // Sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
        Navigator.pop(context); // Volta para a tela de login
      } else {
        // Exibe mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  },
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
  ),
  child: Text('Cadastrar'),
),

                      SizedBox(height: 20),

                      // Texto clicável "Já tem uma conta?"
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Volta para a tela de login
                        },
                        child: Text(
                          'Já tem uma conta? Entrar',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService(); // Instância do FirebaseAuthService
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instância do Firestore
  final imagebookshelf = "https://th.bing.com/th/id/OIP.qGu31yC_X4ZoXeqmoOxy2wHaHa?rs=1&pid=ImgDetMain";

  Future<void> _saveUserId(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid); // Salva o UID
  }

  Future<void> _checkUserAndRedirect(String uid, BuildContext context) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(uid).get();
      

      if (userDoc.exists) {
        
        // Se o documento do usuário existir, redireciona para /home
        
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Se o documento não existir, redireciona para /criacao
        Navigator.pushReplacementNamed(context, '/criacao');
      }
    } catch (e) {
      // Exibe mensagem de erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar o usuário: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 188, 185, 225),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(color: Color.fromARGB(255, 188, 185, 225)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "GAME LIBRARY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Image.network(
                      imagebookshelf,
                      width: 150,
                      height: 150,
                      colorBlendMode: BlendMode.modulate,
                      color: Color.fromARGB(255, 193, 190, 227),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bem-vindo!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 20),

                      // Campo Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o email';
                          }
                          final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!regex.hasMatch(value)) {
                            return 'Informe um email válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Campo Senha
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a senha';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Botão Entrar
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            try {
                              final userCredential = await _authService.signInWithEmailAndPassword(
                                _emailController.text.trim(),
                                _senhaController.text.trim(),
                              );
                              
                              if (userCredential != null) {
                                final uid = userCredential.user?.uid;
                                if (uid != null) {
                                  await _saveUserId(uid);  // Salva o UID do usuário
                                  await _checkUserAndRedirect(uid, context);  // Verifica o Firestore
                                }
                              }
                            
                            }  catch (e) {
                              
                              // Exibe mensagem de erro caso o login falhe
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao fazer login: ${e.toString()}')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        ),
                        child: Text('Entrar'),
                      ),
                      SizedBox(height: 20),

                      // Texto clicável "Esqueceu a senha?"
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/reset');
                        },
                        child: Text(
                          'Esqueceu a senha?',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/cadastro');
                        },
                        child: Text(
                          'Criar conta?',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/apagar');
                        },
                        child: Text(
                          'Apagar conta?',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class ProfileCreationPage extends StatefulWidget {
  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final _formKey = GlobalKey<FormState>();
  String? nome;
  String? dataNascimento;
  String? genero;
  String? categoriaFavorita;

  List<String> categorias = [];
  List<String> generos = [];

  @override
  void initState() {
    super.initState();
    carregarDadosCsv();
  }

  Future<void> carregarDadosCsv() async {
    final String response =
        await rootBundle.loadString('assets/dataset_filtrado.csv');
    final List<List<dynamic>> data = CsvToListConverter().convert(response);

    Set<String> categoriasSet = {};
    Set<String> generosSet = {};

    for (var row in data) {
      if (row.isNotEmpty) {
        final categoria = row[34];
        final genero = row[35];

        if (categoria != null) {
          categoriasSet.add(categoria);
        }
        if (genero != null) {
          generosSet.add(genero);
        }
      }
    }

    setState(() {
      categorias = categoriasSet.toList();
      generos = generosSet.toList();
    });
  }

  Future<String?> _obterUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  Future<void> _salvarUsuarioNoFirestore() async {
    String? uid = await _obterUid();
    if (uid == null) {
      // UID não encontrado no SharedPreferences, talvez redirecionar para a página de login.
      return;
    }

    // Instância do Firestore
    final firestore = FirebaseFirestore.instance;

    // Salvar os dados no Firestore
    await firestore.collection('usuarios').doc(uid).set({
      'nome': nome,
      'dataNascimento': dataNascimento,
      'genero': genero,
      'categoriaFavorita': categoriaFavorita,
    });

    // Navegar para a próxima página após salvar
    if (mounted){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context)=>QuizPage(),
        settings: RouteSettings(
          arguments: {
            'nome': nome,
            'dataNascimento': dataNascimento,
            'genero': genero,
            'categoriaFavorita': categoriaFavorita,
          },
        ),
      ),
    );}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 188, 185, 225),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 188, 185, 225)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Perfil do Usuário",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),

                      // Campo Nome
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          nome = value;
                        },
                      ),
                      SizedBox(height: 20),

                      // Campo Data de Nascimento
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Data de Nascimento (DD/MM/AAAA)',
                          hintText: 'Exemplo: 25/11/1995',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onSaved: (value) {
                          dataNascimento = value;
                        },
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a data de nascimento';
                          }
                          final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
                          if (!regex.hasMatch(value)) {
                            return 'Formato inválido. Use DD/MM/AAAA';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Campo Gênero de Jogos (Autocomplete)
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return generos.where((genero) => genero
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          setState(() {
                            genero = selection;
                          });
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Gênero de Jogos Favorito',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      // Campo Categoria Favorita (Autocomplete)
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return categorias.where((categoria) => categoria
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          setState(() {
                            categoriaFavorita = selection;
                          });
                        },
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Categoria Favorita',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      // Botão Salvar e Continuar
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState?.save();
                            _salvarUsuarioNoFirestore(); // Salva no Firestore
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                        ),
                        child: Text('Salvar e Continuar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedindex = 0;
  bool showNavigationRail = true; // Controle de visibilidade da aba

  @override
  Widget build(BuildContext context) {
    Widget page = Placeholder();
    switch (selectedindex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = Profilels();
        break;
      case 3:
        page = NotesPage();
        break;
      case 4:
        page=Pesquisa();
        break;
      case 5 :
      page = QuizPage();
        break;
      case 6:
      page = MapaJogosScreen();
       break;
    }

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          // Detecta o gesto de deslizar para a direita para abrir a barra
          if (details.delta.dx > 0 && !showNavigationRail) {
            setState(() {
              showNavigationRail = true;
            });
          }
          // Detecta o gesto de deslizar para a esquerda para fechar a barra
          if (details.delta.dx < 0 && showNavigationRail) {
            setState(() {
              showNavigationRail = false;
            });
          }
        },
        child: Row(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: showNavigationRail ? 72.0 : 0.0, // Largura do NavigationRail
              child: showNavigationRail
                  ? SafeArea(
                      child: NavigationRail(
                        destinations: [
                          NavigationRailDestination(
                            icon: Icon(Icons.home),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.favorite),
                            label: Text('Favorites'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person),
                            label: Text('Perfil'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.note_alt_rounded),
                            label: Text('Jogos'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.search),
                            label: Text('Pesquisa'),
                             ),
                           NavigationRailDestination(
                            icon: Icon(Icons.quiz),
                            label: Text('quiz'),
                             ),
                        ],
                        selectedIndex: selectedindex,
                        onDestinationSelected: (value) {
                          setState(() {
                            selectedindex = value;
                          });
                        },
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<List<dynamic>> jogos = [];
  Set<int> favorites = {};

  void adicionarAosFavoritos(int appid) {
    if (!favorites.contains(appid)) {
      favorites.add(appid);
      notifyListeners();
    }
  }

  Future<void> carregarDadosCsv() async {
    try {
      final String response = await rootBundle.loadString('assets/dataset_filtrado.csv');
      final List<List<dynamic>> data = CsvToListConverter().convert(response);
      jogos = data;
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar CSV: $e");
    }
  }
}



class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    carregarDadosCsv();
  }

  Future<void> carregarDadosCsv() async {
    await context.read<MyAppState>().carregarDadosCsv();
  }

  void proximoJogo() {
    setState(() {
      currentIndex = (currentIndex + 1) % context.read<MyAppState>().jogos.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final jogos = appState.jogos;

    if (jogos.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final jogoAtual = jogos[currentIndex];
    if (jogoAtual.length < 36) {
      return Center(child: Text("Dados do jogo incompletos"));
    }

    final int appid = int.tryParse(jogoAtual[0].toString()) ?? 0;
    final String header = jogoAtual[12];
    final String genres = jogoAtual[35];
    final String name = jogoAtual[1];

    bool isFavorito = appState.favorites.contains(appid);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0) {
            appState.adicionarAosFavoritos(appid);
          } else {
            proximoJogo();
          }
        }
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    width: 300,
                    height: 500,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(header),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(
                        isFavorito ? Icons.favorite : Icons.favorite_border,
                        color: isFavorito ? Colors.red : Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        appState.adicionarAosFavoritos(appid);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              genres,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}



class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final favoritos = appState.favorites;
    final jogos = appState.jogos;

    var filteredFavorites = jogos.where((jogo) {
      return favoritos.contains(jogo[0]);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar favoritos...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              // Filtra favoritos com base na pesquisa
            },
          ),
        ),
        Expanded(
          child: filteredFavorites.isEmpty
              ? Center(child: Text('Nenhum favorito encontrado.'))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: filteredFavorites.length,
                  itemBuilder: (context, index) {
                    var jogo = filteredFavorites[index];
                    var header = jogo[12]; // URL da capa do jogo
                    var name = jogo[1];

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(header),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageFullScreen(header: header, name: name),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}


class ImageFullScreen extends StatelessWidget {
  final String header;
  final String name;

  ImageFullScreen({required this.header, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(header, fit: BoxFit.contain),
        ),
      ),
    );
  }
}




class Profilels extends StatelessWidget {
  final Color green = Color.fromARGB(255, 188, 185, 225);
  final String url =
      "https://cdn-2.worldwebs.com/assets/images/f/ed0b52349d39d39d5693cac6bb0cc06f.jpeg?666490501";

  Future<Map<String, dynamic>> _fetchUserProfile(String uid) async {
    if (uid.isEmpty) {
      throw Exception("UID inválido ou não encontrado.");
    }
    try {
      final firestore = FirebaseFirestore.instance;
      final docSnapshot = await firestore.collection('usuarios').doc(uid).get();

      if (docSnapshot.exists) {
        return docSnapshot.data()!;
      } else {
        return {
          'nome': 'Nome não informado',
          'dataNascimento': 'Data não informada',
          'genero': 'Gênero não informado',
          'categoriaFavorita': 'Categoria não informada',
        };
      }
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
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(url),
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






class SenhaPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  final _senhaController = TextEditingController(); // Controlador para o campo de senha
  final _emailController = TextEditingController(); // Controlador para o campo de email
  final imagebookshelf = "https://icon-library.com/images/bookshelf-icon-png/bookshelf-icon-png-6.jpg";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 188, 185, 225),
      body: SingleChildScrollView( // Tornar a tela rolável
        child: Column(
          children: <Widget>[
            // Cabeçalho com título e imagem
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 188, 185, 225),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "GAME LIBRARY",
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    Image.network(
                      imagebookshelf,
                      width: 150,
                      height: 150,
                      colorBlendMode: BlendMode.modulate,
                      color: Color.fromARGB(255, 193, 190, 227),
                    ),
                  ],
                ),
              ),
            ),
            // Corpo da página
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Recuperação de Senha',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 20),

                      // Campo Email
                      TextFormField(
                        controller: _emailController, // Controlador para email
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o email';
                          }
                          final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!regex.hasMatch(value)) {
                            return 'Informe um email válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Campo Nova Senha
                      TextFormField(
                        obscureText: true,
                        controller: _senhaController, // Controlador do campo de senha
                        decoration: InputDecoration(
                          labelText: 'Nova Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a nova senha';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Campo Confirmar Senha
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirme sua senha';
                          }
                          if (value != _senhaController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Botão Confirmar
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            try {
                              // Atualiza a senha do usuário
                              User? user = _auth.currentUser;
                              await user?.updatePassword(_senhaController.text);

                              

                              // Exemplo de ação ao confirmar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Senha atualizada com sucesso!')),
                              );

                              Navigator.pop(context); // Voltar para a tela anterior
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro: ${e.toString()}')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        ),
                        child: Text('Confirmar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}








class Note {
  String title;
  String content;
  DateTime creationDate;

  Note({
    required this.title,
    required this.content,
    required this.creationDate,
  });

  // Converte uma nota para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'creationDate': creationDate.toIso8601String(),
    };
  }

  // Cria uma nota a partir de um Map (para ler do Firestore)
  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      content: map['content'],
      creationDate: DateTime.parse(map['creationDate']),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];
  String searchQuery = '';
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  late String uid;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Carrega o UID do usuário
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString('uid') ?? '';
    });
    _fetchNotes();
  }

  // Função para salvar uma nota no Firebase
  Future<void> _saveNoteToFirestore(Note note) async {
    if (uid.isEmpty) return; // Certifique-se de que o UID foi carregado

    try {
      await FirebaseFirestore.instance
          .collection('notas')
          .doc(uid)
          .collection('userNotes')
          .add(note.toMap());
      _fetchNotes(); // Atualiza as notas após salvar
    } catch (e) {
      print('Erro ao salvar nota: $e');
    }
  }

  // Função para buscar notas do Firebase
  Future<void> _fetchNotes() async {
    if (uid.isEmpty) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notas')
          .doc(uid)
          .collection('userNotes')
          .get();

      setState(() {
        notes = snapshot.docs.map((doc) => Note.fromMap(doc.data() as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      print('Erro ao buscar notas: $e');
    }
  }

  void addNote() {
    if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
      Note newNote = Note(
        title: titleController.text,
        content: contentController.text,
        creationDate: DateTime.now(),
      );
      _saveNoteToFirestore(newNote);
      titleController.clear();
      contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    var filteredNotes = notes.where((note) {
      return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notas'),
        backgroundColor: Color.fromARGB(255, 188, 185, 225),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 188, 185, 225),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 123, 115, 115).withValues(),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar Notas...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                String previewContent = note.content.length > 30
                    ? '${note.content.substring(0, 30)}...'
                    : note.content;
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    '$previewContent | ${note.creationDate.toLocal()}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título da Nota',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: 'Conteúdo da Nota'),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: addNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 188, 185, 225),
                  ),
                  child: Text(
                    'Adicionar Nota',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class DeleteAccountPage extends StatefulWidget {
  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum usuário autenticado')),
          );
        }
        return;
      }

      final email = emailController.text.trim();
      final senha = senhaController.text.trim();

      // Reautenticação do usuário
      final credential = EmailAuthProvider.credential(email: email, password: senha);
      await user.reauthenticateWithCredential(credential);

      // Deleta o documento do Firestore
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).delete();
      }

      // Deleta a conta
      await user.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta apagada com sucesso')),
        );
      }
      if (mounted){

      Navigator.of(context).pop();}

    } on FirebaseAuthException catch (e) {
      String message = 'Erro ao apagar conta.';
      if (e.code == 'wrong-password') {
        message = 'Senha incorreta.';
      } else if (e.code == 'user-not-found') {
        message = 'Usuário não encontrado.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Faça login novamente para excluir a conta.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro inesperado. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 185, 225),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(color: Color.fromARGB(255, 188, 185, 225)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "APAGAR CONTA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Digite suas credenciais para apagar a conta',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Campo Email
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o email';
                          }
                          final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!regex.hasMatch(value)) {
                            return 'Informe um email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Campo Senha
                      TextFormField(
                        controller: senhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a senha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Botão Apagar Conta
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await _deleteAccount();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        ),
                        child: const Text('Apagar Conta'),
                      ),
                      const SizedBox(height: 20),

                      // Botão Voltar
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class DeleteProfilePage extends StatefulWidget {
  @override
  State<DeleteProfilePage> createState() => _DeleteProfilePageState();
}

class _DeleteProfilePageState extends State<DeleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  Future<void> _deleteProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum usuário autenticado')),
          );
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString('uid');
      if (uid != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil excluído com sucesso')),
        );
      }
      if (mounted){

      Navigator.of(context).pop();}


    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro inesperado ao excluir o perfil')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 185, 225),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(color: Color.fromARGB(255, 188, 185, 225)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "EXCLUIR PERFIL",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirme para excluir seu perfil',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Botão Excluir Perfil
                      ElevatedButton(
                        onPressed: () async {
                          await _deleteProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        ),
                        child: const Text('Excluir Perfil'),
                      ),
                      const SizedBox(height: 20),

                      // Botão Voltar
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class Pesquisa extends StatefulWidget {
  @override
  State<Pesquisa> createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  String searchQuery = '';
  List<List<dynamic>> jogos = [];
  List<List<dynamic>> jogosFiltrados = [];
  List<List<dynamic>> sugestoes = [];  // Armazenar sugestões
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    carregarDadosCsv();
  }

  Future<void> carregarDadosCsv() async {
    final String response =
        await rootBundle.loadString('assets/dataset_filtrado.csv');
    final List<List<dynamic>> data = CsvToListConverter().convert(response);

    setState(() {
      jogos = data;
      jogosFiltrados = List.from(jogos);
      sugestoes = List.from(jogos);  // Inicializa as sugestões com todos os jogos
    });
  }

  void filtrarJogos(String query) {
    setState(() {
      searchQuery = query;
      // Filtra os jogos com base no nome (assumindo que o nome do jogo esteja na posição 1)
      jogosFiltrados = jogos
          .where((jogo) => jogo[1].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
      sugestoes = jogosFiltrados;  // Atualiza as sugestões com base na pesquisa
      currentIndex = 0; // Resetar o índice ao filtrar
    });
  }

  void proximoJogo() {
    setState(() {
      if (currentIndex < jogosFiltrados.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 188, 185, 225),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar jogo...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: filtrarJogos,
              ),
            ),
            if (searchQuery.isNotEmpty && sugestoes.isNotEmpty)
              SizedBox(
                height: 200,  // Defina a altura da lista de sugestões
                child: ListView.builder(
                  itemCount: sugestoes.length,
                  itemBuilder: (context, index) {
                    final jogo = sugestoes[index];
                    return ListTile(
                      title: Text(jogo[1].toString()),  // Exibe o nome do jogo
                      onTap: () {
                        setState(() {
                          searchQuery = jogo[1].toString();
                          jogosFiltrados = [jogo];  // Exibe apenas o jogo selecionado
                          currentIndex = 0;
                        });
                      },
                    );
                  },
                ),
              ),
            if (jogosFiltrados.isNotEmpty)
              Jogos(jogo: jogosFiltrados[currentIndex]),
            if (jogosFiltrados.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: proximoJogo,
                  child: Text('Próximo Jogo'),
                ),
              ),
            if (jogosFiltrados.isEmpty)
              Center(child: Text('Nenhum jogo encontrado.')),
          ],
        ),
      ),
    );
  }
}


class Jogos extends StatelessWidget {
  const Jogos({super.key, required this.jogo});

  final List<dynamic> jogo;

  @override
  Widget build(BuildContext context) {
    final header = jogo[12];
    final about = jogo[8];
    final price = jogo[6];
    final genres = jogo[35];
    final name = jogo[1];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Image.network(
              header,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.broken_image,
                size: 100,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(name, style: Theme.of(context).textTheme.bodyMedium),
          Wrap(
            spacing: 10,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category, color: Colors.blue),
                  SizedBox(width: 5),
                  // Limita o tamanho do texto do gênero com TextOverflow.ellipsis
                  Text(
                    genres,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1, // Limita para 1 linha
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.attach_money, color: Colors.green),
                  SizedBox(width: 5),
                  Text(price.toString(),
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade400,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              about,
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}




class QuizPage extends StatefulWidget {
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _formKey = GlobalKey<FormState>();
  String? plataforma;
  String? preferenciaJogos;
  String? generoJogo;
  String? tagJogo;
  TextEditingController plataformaController = TextEditingController();
  TextEditingController preferenciaJogosController = TextEditingController();
  TextEditingController generoJogoController = TextEditingController();
  TextEditingController tagJogoController = TextEditingController();

  final List<String> plataformas = ['Windows', 'Linux', 'Mac'];
  final List<String> preferenciasJogos = ['Single-Player', 'Multi-Player'];
  final List<String> gameGenres = [
    'Action', 'Adventure', 'RPG', 'Strategy', 'Horror', 'Racing', 
    'Sports', 'Simulation', 'Puzzle', 'FPS', 'Open World'
  ];
  final List<String> gameTags = [
    'Retro', 'Co-op', 'Battle Royale', 'Rich Story', 'Online Multiplayer', 
    'Casual', 'Indie', 'Exploration', 'Survival', 'Hack and Slash'
  ];

  final FirebaseServiceQUiz _firebaseService = FirebaseServiceQUiz();
  final RecomendacaoService _recomendacaoService = RecomendacaoService();

  Future<void> _salvarRespostasNoFirestore() async {
  await _firebaseService.salvarRespostas(plataforma, preferenciaJogos, generoJogo, tagJogo);
  List<String> recomendacoes = await _buscarRecomendacoes();

  if (mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(),
        settings: RouteSettings(
          arguments: {
            'plataforma': plataforma,
            'preferenciaJogos': preferenciaJogos,
            'generoJogo': generoJogo,
            'tagJogo': tagJogo,
            'recomendacoes': recomendacoes, // Passando as recomendações para a Home
          },
        ),
      ),
    );
  }
}


  Future<List<String>> _buscarRecomendacoes() async {
    try {
      return await _recomendacaoService.buscarRecomendacoes(
        plataforma: plataforma ?? "",
        categoria: preferenciaJogos ?? "",
        genero: generoJogo ?? "",
        tag: tagJogo ?? "",
      );
    } catch (e) {
      print("Erro ao buscar recomendações: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 188, 185, 225),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(color: Color.fromARGB(255, 188, 185, 225)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Quiz de Preferências",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(70)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      // Plataforma
                      TextFormField(
                        controller: plataformaController,
                        decoration: InputDecoration(
                          labelText: 'Qual plataforma você prefere?',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onChanged: (value) {
                          setState(() {
                            plataforma = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Selecione ou digite a Plataforma' : null,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Ou selecione uma das opções',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        value: plataforma?.isEmpty == true ? null : plataforma,
                        onChanged: (String? newValue) {
                          setState(() {
                            plataforma = newValue;
                            plataformaController.clear();
                          });
                        },
                        items: plataformas.map((plataforma) => DropdownMenuItem<String>(
                          value: plataforma,
                          child: Text(plataforma),
                        )).toList(),
                      ),
                      SizedBox(height: 20),
                      // Preferência Jogos
                      TextFormField(
                        controller: preferenciaJogosController,
                        decoration: InputDecoration(
                          labelText: 'Você prefere Single-Player ou Multi-Player?',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onChanged: (value) {
                          setState(() {
                            preferenciaJogos = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Selecione ou digite uma opção' : null,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Ou selecione uma das opções',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        value: preferenciaJogos?.isEmpty == true ? null : preferenciaJogos,
                        onChanged: (String? newValue) {
                          setState(() {
                            preferenciaJogos = newValue;
                            preferenciaJogosController.clear();
                          });
                        },
                        items: preferenciasJogos.map((preferencia) => DropdownMenuItem<String>(
                          value: preferencia,
                          child: Text(preferencia),
                        )).toList(),
                      ),
                      SizedBox(height: 20),
                      // Gênero Jogo
                      TextFormField(
                        controller: generoJogoController,
                        decoration: InputDecoration(
                          labelText: 'Escolha o Gênero',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onChanged: (value) {
                          setState(() {
                            generoJogo = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Selecione ou digite o Gênero' : null,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Ou selecione uma das opções',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        value: generoJogo?.isEmpty == true ? null : generoJogo,
                        onChanged: (String? newValue) {
                          setState(() {
                            generoJogo = newValue;
                            generoJogoController.clear();
                          });
                        },
                        items: gameGenres.map((genre) => DropdownMenuItem<String>(
                          value: genre,
                          child: Text(genre),
                        )).toList(),
                      ),
                      SizedBox(height: 20),
                      // Tag Jogo
                      TextFormField(
                        controller: tagJogoController,
                        decoration: InputDecoration(
                          labelText: 'Escolha a Tag (Opcional)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onChanged: (value) {
                          setState(() {
                            tagJogo = value;
                          });
                        },
                      ),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Ou selecione uma das opções',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        value: tagJogo?.isEmpty == true ? null : tagJogo,
                        onChanged: (String? newValue) {
                          setState(() {
                            tagJogo = newValue;
                            tagJogoController.clear();
                          });
                        },
                        items: gameTags.map((tag) => DropdownMenuItem<String>(
                          value: tag,
                          child: Text(tag),
                        )).toList(),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState?.save();
                            _salvarRespostasNoFirestore();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        ),
                        child: Text('Salvar e Continua'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}










class MapaJogosScreen extends StatefulWidget {
  @override
  MapaJogosScreenState createState() => MapaJogosScreenState();
}

class MapaJogosScreenState extends State<MapaJogosScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _currentLocation = LatLng(-8.0476, -34.8770); // Recife como ponto inicial
  bool _locationLoaded = false;

  List<LatLng> _gameLocations = [
    LatLng(35.6895, 139.6917), // Tóquio (Nintendo, Sony)
    LatLng(47.4925, 19.0513), // Budapeste (CD Projekt Red)
    LatLng(37.7749, -122.4194), // São Francisco (Ubisoft SF)
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, ative a localização")),
      );}
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permissão negada permanentemente")),
        );}
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    if (mounted){
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _locationLoaded = true;
      _mapController.move(_currentLocation, 12.0);
    });}
  }

  Future<void> _searchLocation() async {
    // Aqui você pode implementar a busca de localização com geocoding
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa de Jogos")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(hintText: "Pesquisar localização"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: _currentLocation, initialZoom: 12.0),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                MarkerLayer(
                  markers: [
                    if (_locationLoaded)
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: _currentLocation,
                        child: Icon(Icons.location_pin, color: Colors.blue, size: 30.0),
                      ),
                    ..._gameLocations.map((location) => Marker(
                          width: 40.0,
                          height: 40.0,
                          point: location,
                          child: Icon(Icons.videogame_asset, color: Colors.red, size: 30.0),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
