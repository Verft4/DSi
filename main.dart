import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

Future<List<List<dynamic>>> carregarCsv() async {
  String data = await rootBundle.loadString('assets/dataset.csv');
  List<List<dynamic>> dataset = CsvToListConverter().convert(data);
  return dataset;
}
void main() {
  runApp(MyApp());
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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 31, 81, 157)),
        ),
        home: LoginPage(), // A aplicação começa na tela de login
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

// Tela de Login
// Tela de Login

class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  final imagebookshelf = "https://icon-library.com/images/bookshelf-icon-png/bookshelf-icon-png-6.jpg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 188, 185, 225),
      body: Column(
        children: [
          // Cabeçalho com título e imagem
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
          Expanded(
            child: Container(
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
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Se o formulário for válido, navega para a próxima tela
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileCreationPage()),
                            );
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Perfil'),
        backgroundColor: Theme.of(context).colorScheme.primaryFixed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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

              // Campo Gênero de Jogos
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gênero de Jogos Favorito',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                items: [
                  'Ação',
                  'Aventura',
                  'RPG',
                  'Estratégia',
                  'Esportes'
                ].map((genero) {
                  return DropdownMenuItem(
                    value: genero,
                    child: Text(genero),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    genero = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Campo Categoria Favorita
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Categoria Favorita',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onSaved: (value) {
                  categoriaFavorita = value;
                },
              ),
              SizedBox(height: 20),

              // Botão Salvar e Continuar
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState?.save();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(),
                        settings: RouteSettings(
                          arguments: {
                            'nome': nome,
                            'dataNascimento': dataNascimento,
                            'genero': genero,
                            'categoriaFavorita': categoriaFavorita,
                          },
                        ),
                      ),
                    );
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
    }

    return Scaffold(
      body: Row(
        children: [
          if (showNavigationRail)
            SafeArea(
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.close), // Ícone para ocultar a aba
                    onPressed: () {
                      setState(() {
                        showNavigationRail = false; // Oculta o NavigationRail
                      });
                    },
                  ),
                  Expanded(
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
                          icon: Icon(Icons.person), // Novo ícone para a tela de perfil
                          label: Text('Perfil'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.search_off), // Novo ícone para a tela de perfil
                          label: Text('Jogos'),
                        ),
                      ],
                      selectedIndex: selectedindex,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedindex = value;
                        });

                        // Navegar para a tela de perfil
                       
                      },
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: page,
                ),
                if (!showNavigationRail)
                  Positioned(
                    top: 56, // Aumentado para descer o botão
                    left: 16,
                    child: IconButton(
                      icon: Icon(Icons.menu), // Ícone para reexibir a aba
                      onPressed: () {
                        setState(() {
                          showNavigationRail = true; // Mostra o NavigationRail
                        });
                      },
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




class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // Filtrar pares com base na pesquisa
    var isVisible = searchQuery.isEmpty ||
        pair.asLowerCase.contains(searchQuery.toLowerCase());

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Column(
      children: [
        // Barra de pesquisa
        Container(
          width: double.infinity,
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 188, 185, 225),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar par de palavras...',
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
        // Exibir par de palavras ou mensagem
        PALAVRAS(isVisible: isVisible, pair: pair, appState: appState, icon: icon),
      ],
    );
  }
}

class PALAVRAS extends StatelessWidget {
  const PALAVRAS({
    super.key,
    required this.isVisible,
    required this.pair,
    required this.appState,
    required this.icon,
  });

  final bool isVisible;
  final WordPair pair;
  final MyAppState appState;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: isVisible
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BIGcard(pair: pair),
                  SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          appState.toggleFavorite();
                        },
                        icon: Icon(icon),
                        label: Text('Like'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          appState.getNext();
                        },
                        child: Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: Text('Nenhum par de palavras encontrado.'),
            ),
    );
  }
}


// ...

class BIGcard extends StatelessWidget {
  const BIGcard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme=Theme.of(context);
    var style=theme.textTheme.displayMedium!.copyWith(color:theme.colorScheme.onPrimary,);
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(pair.asLowerCase,style: style,
        semanticsLabel: pair.asPascalCase,),
      ),
    );
  }
}
// ...

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    // Filtrar favoritos com base na pesquisa
    var filteredFavorites = appState.favorites
        .where((pair) => pair.asLowerCase.contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Barra de pesquisa
        Container( width: double.infinity, // Ocupa toda a largura disponível
                   height: 60, // Define a altura
                   padding: EdgeInsets.symmetric(horizontal: 10),
                   decoration: BoxDecoration(
                         color: const Color.fromARGB(255, 188, 185, 225),
                         borderRadius: BorderRadius.circular(15),
                         boxShadow: [
                           BoxShadow(
                                 color: Colors.grey.withOpacity(0.5),
                                 spreadRadius: 1,
                                 blurRadius: 5,
                                 offset: Offset(0, 3), // Sombra com deslocamento
                              ),
                            ],
                          ),
          
         
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar favoritos...',
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
        // Lista de favoritos
        Expanded(
          child: filteredFavorites.isEmpty
              ? Center(
                  child: Text('Nenhum favorito encontrado.'),
                )
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Você tem ${filteredFavorites.length} favoritos:'),
                    ),
                    for (var pair in filteredFavorites)
                      ListTile(
                        leading: Icon(Icons.favorite),
                        title: Text(pair.asLowerCase),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}



class Profilels extends StatelessWidget{
  final Color green =Color.fromARGB(255, 188, 185, 225);
  final String url ="https://cdn-2.worldwebs.com/assets/images/f/ed0b52349d39d39d5693cac6bb0cc06f.jpeg?666490501";
 
  @override
  
  Widget build(BuildContext context){
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    final nome = arguments?['nome'] ?? 'Nome não informado';
    final dataNascimento = arguments?['dataNascimento'] ?? 'Data não informada';
    final genero = arguments?['genero'] ?? 'Gênero não informado';
    final categoriaFavorita = arguments?['categoriaFavorita'] ?? 'Categoria não informada';
    return Scaffold(
      appBar: AppBar(
        
        
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 188, 185, 225),
        flexibleSpace: Center(
          child: Text("Perfil",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top:24),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/2,
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                
              )
              
          ),
          child: Column(
            children:<Widget> [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                 CircleAvatar(
                      radius: 60, // Tamanho da imagem redonda
                      backgroundImage: NetworkImage(url),
                    ),

                  
                ],
               ),
               Text("ID: 434534",style: TextStyle(color: Colors.white70,)),
               Padding(
                 padding: const EdgeInsets.only(top: 16,bottom: 32),
                 child: Text(nome,style: TextStyle(color: Colors.white,fontSize: 24,fontWeight:FontWeight.bold )),
               ),
               Padding(
                 padding: const EdgeInsets.only(left: 20,right: 20),
                 child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Icon(Icons.calendar_today_outlined,color: Colors.white,),
                        Text(dataNascimento,style: TextStyle(color: Colors.white)),
                      ]
                      
                 
                    ),
                    Column(
                      children: <Widget>[
                        Icon(Icons.games,color: Colors.white,),
                        Text(genero,style: TextStyle(color: Colors.white)),
                      ]
                      
                 
                    ),
                    Column(
                      children: <Widget>[
                        Icon(Icons.category,color: Colors.white,),
                        Text(categoriaFavorita,style: TextStyle(color: Colors.white)),
                      ]
                      
                 
                    ),
                    
                   
                  ],
                 ),
               )
            ],
          ),
          ),
        ],
      ),
    );
    

  }
}
//usar essa tela para fazer outra (tela de recriação de senha)
class Login extends StatefulWidget{
  @override
  State<Login> createState() =>_LoginState();
}
class _LoginState extends State<Login>{
  final imagebookshelf="https://icon-library.com/images/bookshelf-icon-png/bookshelf-icon-png-6.jpg";
  @override
  
  
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: Color.fromARGB(255, 188, 185, 225),
    body: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*.3,
            decoration: BoxDecoration(color: Color.fromARGB(255, 188, 185, 225)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                
                children:<Widget> [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:<Widget> [
              Text("GAME LIBRARY",style: TextStyle(color: Colors.white,
              fontSize: 30,fontWeight: FontWeight.bold),
              ),
              Image(image:NetworkImage(imagebookshelf),width:150 ,height:150,colorBlendMode: BlendMode.modulate,color: Color.fromARGB(255, 193, 190, 227),)
              
              
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
     Expanded(child:Container(
      decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.only(topLeft: Radius.circular(70))),
            ) 
          ),
        ],
      ),
    );
  }
}



