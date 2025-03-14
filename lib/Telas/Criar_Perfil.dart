import 'package:namer_app/bibliotecas.dart'; 
import 'quiz.dart';
import 'package:intl/intl.dart';


class ProfileCreationPage extends StatefulWidget {
  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final _formKey = GlobalKey<FormState>();
  String? nome;
  DateTime? dataNascimento; // Armazena a data como DateTime
  String? genero;
  String? categoriaFavorita;

  // Controlador para o campo de data
  final TextEditingController _dataNascimentoController = TextEditingController();

  List<String> categorias = [];
  List<String> generos = [];

  @override
  void initState() {
    super.initState();
    carregarDadosCsv();
  }

  @override
  void dispose() {
    _dataNascimentoController.dispose();
    super.dispose();
  }

  Future<void> carregarDadosCsv() async {
    final String response = await rootBundle.loadString('assets/dataset_filtrado.csv');
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

    final firestore = FirebaseFirestore.instance;

    await firestore.collection('usuarios').doc(uid).set({
      'nome': nome,
      'dataNascimento': _dataNascimentoController.text,
      'genero': genero,
      'categoriaFavorita': categoriaFavorita,
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizPage(),
          settings: RouteSettings(
            arguments: {
              'nome': nome,
              'dataNascimento': _dataNascimentoController.text,
              'genero': genero,
              'categoriaFavorita': categoriaFavorita,
            },
          ),
        ),
      );
    }
  }

  // Função para selecionar a data usando o DatePicker
  Future<void> _selectDataNascimento() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        dataNascimento = pickedDate;
        _dataNascimentoController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 188, 185, 225),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho da página
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
            // Formulário
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

                      // Campo Data de Nascimento com DatePicker
                      TextFormField(
                        controller: _dataNascimentoController,
                        decoration: InputDecoration(
                          labelText: 'Data de Nascimento (DD/MM/AAAA)',
                          hintText: 'Exemplo: 25/11/1995',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        readOnly: true,
                        onTap: _selectDataNascimento,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a data de nascimento';
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
                          return generos.where((genero) =>
                              genero.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          setState(() {
                            genero = selection;
                          });
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                            FocusNode focusNode, VoidCallback onFieldSubmitted) {
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
                          return categorias.where((categoria) =>
                              categoria.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (String selection) {
                          setState(() {
                            categoriaFavorita = selection;
                          });
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                            FocusNode focusNode, VoidCallback onFieldSubmitted) {
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
                            _salvarUsuarioNoFirestore();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
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

