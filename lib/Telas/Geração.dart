import 'package:namer_app/bibliotecas.dart'; 




class MyAppState extends ChangeNotifier {
  List<List<dynamic>> jogos = [];
  Set<int> favorites = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> adicionarAosFavoritos(int appid) async {
    if (!favorites.contains(appid)) {
      favorites.add(appid);
      notifyListeners();

      // Salvar a lista atualizada de favoritos no Firestore
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
  Future<void> removerDosFavoritos(int appid) async {
    if (favorites.contains(appid)) {
      favorites.remove(appid);
      notifyListeners();

      // Atualizar o Firestore
      await _salvarFavoritosNoFirestore();
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
      // Carregar a lista de favoritos existente no Firestore
      final doc = await _firestore.collection('favoritos').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        Set<int> existingFavorites = Set<int>.from(data['favoritos']);
        existingFavorites.addAll(favorites); // Adiciona os favoritos novos à lista existente
        // Atualiza o Firestore com a lista combinada
        await _firestore.collection('favoritos').doc(uid).set({
          'favoritos': existingFavorites.toList(),
        });
      } else {
        // Se não houver favoritos no Firestore, criar a nova lista
        await _firestore.collection('favoritos').doc(uid).set({
          'favoritos': favorites.toList(),
        });
      }
    }
  }
}



class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  int currentIndex = 0;
  late List<String> recomendacoes = [];
  late List<List<dynamic>> jogosRecomendados = [];
  bool usandoRecomendacoes = false;

  @override
  void initState() {
    super.initState();
    carregarDadosCsv();
    // Definindo o índice inicial aleatório
    final appState = context.read<MyAppState>();
    currentIndex = (appState.jogos.isNotEmpty) ? Random().nextInt(appState.jogos.length) : 0;
  }

  // Função para carregar os dados CSV
  Future<void> carregarDadosCsv() async {
    await context.read<MyAppState>().carregarDadosCsv();
  }

  // Função para mostrar o próximo jogo
  void proximoJogo() {
    setState(() {
      final appState = context.read<MyAppState>();
      if (usandoRecomendacoes && jogosRecomendados.isNotEmpty) {
        currentIndex = (currentIndex + 1) % jogosRecomendados.length;
      } else {
        currentIndex = (appState.jogos.isNotEmpty) ? Random().nextInt(appState.jogos.length) : 0;
      }
    });
  }

  @override
  void didChangeDependencies() {
  super.didChangeDependencies();

  // Pegando as recomendações passadas via argumentos
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  if (args != null && args['recomendacoes'] != null) {
    setState(() {
      recomendacoes = List<String>.from(args['recomendacoes']);
      if (recomendacoes.isNotEmpty) {
        // Filtrar os jogos recomendados na lista completa de jogos
        final appState = context.read<MyAppState>();
        jogosRecomendados = appState.jogos.where((jogo) {
          final String name = jogo[1]; // Supondo que o nome do jogo está no índice 1
          return recomendacoes.contains(name);
        }).toList();
        usandoRecomendacoes = true;
      } else {
        usandoRecomendacoes = false;
      }
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final jogos = usandoRecomendacoes && jogosRecomendados.isNotEmpty ? jogosRecomendados : appState.jogos;

    // Verificando se há jogos disponíveis
    if (jogos.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final jogoAtual = usandoRecomendacoes && jogosRecomendados.isNotEmpty
    ? jogosRecomendados[currentIndex]
    : appState.jogos[currentIndex];

    final int appid = int.tryParse(jogoAtual[0].toString()) ?? 0;
    final String header = jogoAtual[12]; 
    final String genres = jogoAtual[35]; 
    final String name = jogoAtual[1]; 

    bool isFavorito = appState.favorites.contains(appid);

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          // Se o gesto for para cima, adiciona aos favoritos
          if (details.primaryVelocity! > 0) {
            appState.adicionarAosFavoritos(appid);
          } else {
            proximoJogo();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 188, 185, 225),
        appBar: AppBar(title: Text("Gerador de Jogos")),
        body: Column(
          children: [
            // Exibindo as recomendações na parte superior
            if (recomendacoes.isNotEmpty)
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: recomendacoes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(recomendacoes[index]),
                    );
                  },
                ),
              ),
            
            // Exibindo o jogo atual
            Expanded(
              flex: 2,
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
            ),
          ],
        ),
      ),
    );
  }
}