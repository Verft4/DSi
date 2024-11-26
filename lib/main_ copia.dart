import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.primaryFixed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bem-vindo!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 20),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileCreationPage()),
                );
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
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onSaved: (value) {
                  dataNascimento = value;
                },
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gênero Favorito',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                items: ['Feminino', 'Masculino', 'Outro']
                    .map((genero) => DropdownMenuItem(
                          value: genero,
                          child: Text(genero),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    genero = value;
                  });
                },
              ),
              SizedBox(height: 20),
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
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
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

// Restante do código permanece o mesmo
// ...

// As páginas existentes como MyHomePage, GeneratorPage e FavoritesPage continuarão a usar o mesmo tema


class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedindex=0;
  @override
  Widget build(BuildContext context) {
  Widget page=Placeholder();
  switch (selectedindex) {
  case 0:
    page = GeneratorPage();
    break;
  case 1:
    page = FavoritesPage();
    break;
  
}

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              selectedIndex: selectedindex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedindex=value;
                });
                
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: page,
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