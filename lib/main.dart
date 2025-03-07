
import 'bibliotecas.dart';
import 'Telas/utilidades.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
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
          '/criacao': (context) => ProfileCreationPage(),
          '/reset': (context) => SenhaPage(),
          '/apagar': (context) => DeleteAccountPage(),
          '/apagarperfil': (context) => DeleteProfilePage(),
          '/quiz': (context) => QuizPage()
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  var selectedIndex = 0;
  bool showNavigationRail = true;
  List<String> recomendacoes = [];
  final double _navigationRailWidth = 72.0;
  late AnimationController _railAnimationController;

  @override
  void initState() {
    super.initState();
    _railAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        recomendacoes = args['recomendacoes'] ?? [];
      });
    }
  }

  Widget _buildPage() {
    switch (selectedIndex) {
      case 0:
        return GeneratorPage();
      case 1:
        return FavoritesPage();
      case 2:
        return Profilels();
      case 3:
        return NotesPage();
      case 4:
        return Pesquisa();
      case 5:
        return QuizPage();
      case 6:
        return MapaJogosScreen();
      default:
        return GeneratorPage();
    }
  }

  List<NavigationRailDestination> _navDestinations() {
    return [
      NavigationRailDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_filled),
        label: Text('Início'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.favorite_outline),
        selectedIcon: Icon(Icons.favorite),
        label: Text('Favoritos'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: Text('Perfil'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.notes_outlined),
        selectedIcon: Icon(Icons.notes),
        label: Text('Anotações'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.search),
        label: Text('Pesquisa'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.quiz_outlined),
        selectedIcon: Icon(Icons.quiz),
        label: Text('Quiz'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.map_outlined),
        selectedIcon: Icon(Icons.map),
        label: Text('Mapa'),
      ),
    ];
  }

  // Função para exibir o modal com as opções adicionais
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botão para Pesquisa
              IconButton(
                icon: Icon(Icons.search, size: 30),
                onPressed: () {
                  Navigator.pop(context); // Fecha o modal
                  setState(() => selectedIndex = 4); // Abre a tela Pesquisa
                },
              ),
              // Botão para Quiz
              IconButton(
                icon: Icon(Icons.quiz, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => selectedIndex = 5); // Abre a tela Quiz
                },
              ),
              // Botão para Mapa
              IconButton(
                icon: Icon(Icons.map, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => selectedIndex = 6); // Abre a tela Mapa
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (!isMobile)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: showNavigationRail ? _navigationRailWidth : 0,
                child: NavigationRail(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  elevation: 4,
                  minWidth: _navigationRailWidth,
                  groupAlignment: -0.2,
                  destinations: _navDestinations(),
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => selectedIndex = index);
                    if (isMobile) setState(() => showNavigationRail = false);
                  },
                  labelType: NavigationRailLabelType.selected,
                  trailing: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            showNavigationRail
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                          ),
                          onPressed: () => setState(
                              () => showNavigationRail = !showNavigationRail),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => showNavigationRail = false),
                onPanUpdate: (details) {
                  if (details.delta.dx > 10) {
                    setState(() => showNavigationRail = true);
                  } else if (details.delta.dx < -10) {
                    setState(() => showNavigationRail = false);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.surface.withValues(),
                        Theme.of(context).colorScheme.surfaceBright,
                      ],
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildPage(),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar para dispositivos móveis
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: selectedIndex < 4 ? selectedIndex : 0,
              onTap: (index) {
                if (index == 4) {
                  // Se o usuário clicar no ícone "Mais"
                  _showMoreOptions();
                } else {
                  setState(() => selectedIndex = index);
                }
              },
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outlined),
                  activeIcon: Icon(Icons.favorite),
                  label: 'Favoritos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outlined),
                  activeIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notes_outlined),
                  activeIcon: Icon(Icons.notes),
                  label: 'Anotações',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz),
                  label: 'Mais',
                ),
              ],
            )
          : null,
    );
  }

  @override
  void dispose() {
    _railAnimationController.dispose();
    super.dispose();
  }
}