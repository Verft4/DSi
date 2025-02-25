
import 'bibliotecas.dart';
import 'Telas/utilidades.dart';



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
            seedColor: const Color.fromARGB(255, 188, 185, 225),
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





class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedindex = 0;
  bool showNavigationRail = true; // Controle de visibilidade da aba
  List<String> recomendacoes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Pegando as recomendações da tela anterior
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        recomendacoes = args['recomendacoes'] ?? [];
      });
    }
  }

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
        page = Pesquisa();
        break;
      case 5:
        page = QuizPage();  // Alterado para manter a navegação para a tela do Quiz
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
                          NavigationRailDestination(
                            icon: Icon(Icons.map_outlined),
                            label: Text('Mapa'),
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
