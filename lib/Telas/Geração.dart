import 'package:namer_app/bibliotecas.dart'; 






class MyAppState extends ChangeNotifier {
  List<List<dynamic>> jogos = [];
  Set<int> favorites = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> adicionarAosFavoritos(int appid) async {
    if (!favorites.contains(appid)) {
      favorites.add(appid);
      notifyListeners();

      // Salva a lista atualizada de favoritos no Firestore
      await _salvarFavoritosNoFirestore();
    }
  }

  Future<void> removerDosFavoritos(int appid) async {
    if (favorites.contains(appid)) {
      favorites.remove(appid);
      notifyListeners();
      await _salvarFavoritosNoFirestore();
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

  Future<void> carregarFavoritosDoFirestore() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    if (uid != null) {
      final doc = await _firestore.collection('favoritos').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        favorites = Set<int>.from(data['favoritos']);
        notifyListeners();
      }
    }
  }

  Future<void> _salvarFavoritosNoFirestore() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');

    if (uid != null) {
      await _firestore.collection('favoritos').doc(uid).set({
        'favoritos': favorites.toList(),
      });
    }
  }
}



class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  List<String> recomendacoes = [];
  List<List<dynamic>> jogosRecomendados = [];
  bool usandoRecomendacoes = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    carregarDadosCsv();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    // Após o primeiro frame, define um índice aleatório para o jogo atual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<MyAppState>();
      if (appState.jogos.isNotEmpty) {
        setState(() {
          currentIndex = Random().nextInt(appState.jogos.length);
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> carregarDadosCsv() async {
    await context.read<MyAppState>().carregarDadosCsv();
  }

  // Busca as recomendações salvas no SharedPreferences
  Future<void> getRecomendacoesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Recupera a lista de recomendações ou retorna uma lista vazia
    final savedRecomendacoes = prefs.getStringList('recomendacoes') ?? [];
    setState(() {
      recomendacoes = savedRecomendacoes;
      if (recomendacoes.isNotEmpty) {
        final appState = context.read<MyAppState>();
        // Filtra os jogos do CSV que estão na lista de recomendações
        jogosRecomendados = appState.jogos.where((jogo) {
          final String nomeJogo = jogo[1]; // Supondo que o nome do jogo está no índice 1
          return recomendacoes.contains(nomeJogo);
        }).toList();
        usandoRecomendacoes = jogosRecomendados.isNotEmpty;
      } else {
        usandoRecomendacoes = false;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Em vez de receber a lista via argumentos, pega do SharedPreferences
    getRecomendacoesFromPrefs();
  }

  // Ao trocar de jogo, reinicia a animação
  void proximoJogo() {
    setState(() {
      final appState = context.read<MyAppState>();
      if (usandoRecomendacoes && jogosRecomendados.isNotEmpty) {
        currentIndex = (currentIndex + 1) % jogosRecomendados.length;
      } else {
        if (appState.jogos.isNotEmpty) {
          currentIndex = Random().nextInt(appState.jogos.length);
        }
      }
    });
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    // Define qual lista de jogos usar: os recomendados ou todos os jogos carregados
    final jogos = usandoRecomendacoes && jogosRecomendados.isNotEmpty
        ? jogosRecomendados
        : appState.jogos;

    // Se não houver jogos carregados, exibe um indicador de carregamento
    if (jogos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Gerador de Jogos")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Extração dos dados do jogo atual
    final jogoAtual = jogos[currentIndex];
    final int appid = int.tryParse(jogoAtual[0].toString()) ?? 0;
    final String header = jogoAtual[12];
    final String genres = jogoAtual[35];
    final String name = jogoAtual[1];
    bool isFavorito = appState.favorites.contains(appid);

    return Scaffold(
      appBar: AppBar(title: Text("Gerador de Jogos")),
      backgroundColor: Color(0xFFBCA9E1),
      body: SafeArea(
        child: Column(
          children: [
            // Exibe as recomendações em uma lista horizontal (utilizando Chips)
            if (recomendacoes.isNotEmpty)
              Container(
                height: 80,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recomendacoes.length,
                  separatorBuilder: (context, index) => SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return Chip(
                      label: Text(recomendacoes[index]),
                      backgroundColor: Colors.white70,
                    );
                  },
                ),
              ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: GestureDetector(
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity != null) {
                        // Se o gesto for para baixo, adiciona o jogo aos favoritos
                        if (details.primaryVelocity! > 0) {
                          appState.adicionarAosFavoritos(appid);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$name adicionado aos favoritos!')),
                          );
                        } else {
                          proximoJogo();
                        }
                      }
                    },
                    child: Container(
                      width: 320,
                      height: 520,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 4,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: NetworkImage(header),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Botão para favoritar o jogo, posicionado no canto superior direito
                          Positioned(
                            top: 16,
                            right: 16,
                            child: IconButton(
                              icon: Icon(
                                isFavorito ? Icons.favorite : Icons.favorite_border,
                                color: isFavorito ? Colors.red : Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                appState.adicionarAosFavoritos(appid);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('$name adicionado aos favoritos!')),
                                );
                              },
                            ),
                          ),
                          // Informações do jogo exibidas na parte inferior com fundo semitransparente
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    genres,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Botão para ir ao próximo jogo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: proximoJogo,
                icon: Icon(Icons.navigate_next),
                label: Text("Próximo Jogo"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}