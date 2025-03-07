import 'package:namer_app/bibliotecas.dart'; 





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
  List<String> recomendacoes = [];

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

  Future<void> _buscarRecomendacoes() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();
      try {
        recomendacoes = await RecomendacaoService().buscarRecomendacoes(
          plataforma: plataforma!,
          categoria: preferenciaJogos!,
          genero: generoJogo!,
          tag: tagJogo!,
        );
        setState(() {});

        if (mounted){

        Navigator.pushNamed(
          
          context,
          '/generator',
          arguments: {'recomendacoes': recomendacoes},
        );}


      } catch (e) {
        print("Erro ao buscar recomendações: $e");
      }
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
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Color.fromARGB(255, 188, 185, 225)),
                child: Text(
                  "Quiz de Preferências",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
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
                      _buildDropdownField("Plataforma", plataformas, (value) => plataforma = value),
                      SizedBox(height: 20),
                      _buildDropdownField("Tipo de Jogo", preferenciasJogos, (value) => preferenciaJogos = value),
                      SizedBox(height: 20),
                      _buildDropdownField("Gênero do Jogo", gameGenres, (value) => generoJogo = value),
                      SizedBox(height: 20),
                      _buildDropdownField("Tags", gameTags, (value) => tagJogo = value),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _buscarRecomendacoes,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          backgroundColor: Color.fromARGB(255, 188, 185, 225)
                        ),
                        child: Text('Buscar Recomendações', style: TextStyle(fontSize: 18, color: Colors.white)),
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

  Widget _buildDropdownField(String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      value: null,
      onChanged: onChanged,
      items: items.map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(item, style: TextStyle(fontSize: 16)),
      )).toList(),
    );
  }
}


class RecomendacaoService {
  List<List<dynamic>>? _csvData;
  List<String>? _headers;

  /// Carrega e processa o CSV uma única vez.
  Future<void> _loadCsvData() async {
    if (_csvData != null) return;
    try {
      final String csvContent = await rootBundle.loadString('assets/dataset_filtrado.csv');
      _csvData = CsvToListConverter().convert(csvContent);
      if (_csvData != null && _csvData!.isNotEmpty) {
        _headers = _csvData!.first.map((e) => e.toString().trim()).toList();
      }
    } catch (e) {
      print("Erro ao carregar CSV: $e");
      rethrow;
    }
  }

  /// Busca recomendações de jogos baseados em múltiplos critérios.
  /// 
  /// O sistema utiliza um algoritmo de pontuação para permitir correspondências parciais.
  /// Cada critério bem correspondido recebe 2 pontos, enquanto correspondências parciais recebem 1 ponto.
  /// As recomendações são ordenadas pela pontuação e os [topN] resultados são retornados.
  Future<List<String>> buscarRecomendacoes({
    required String plataforma,
    required String categoria,
    required String genero,
    required String tag,
    int topN = 5,
  }) async {
    await _loadCsvData();
    if (_csvData == null || _headers == null) return [];

    // Obter índices das colunas relevantes
    final plataformaIndex = _headers!.indexOf("Plataforma");
    final categoriaIndex = _headers!.indexOf("Categoria");
    final generoIndex = _headers!.indexOf("Genero");
    final tagIndex = _headers!.indexOf("Tag");
    final nomeJogoIndex = _headers!.indexOf("Nome");

    if ([plataformaIndex, categoriaIndex, generoIndex, tagIndex, nomeJogoIndex].contains(-1)) {
      throw Exception("Cabeçalhos inválidos no arquivo CSV");
    }

    final List<Map<String, dynamic>> jogosPontuados = [];

    // Iterar pelas linhas, ignorando o cabeçalho
    for (var row in _csvData!.skip(1)) {
      // Verificar se a linha possui colunas suficientes
      if (row.length <= [plataformaIndex, categoriaIndex, generoIndex, tagIndex, nomeJogoIndex]
          .reduce((a, b) => a > b ? a : b)) {
        continue;
      }
      
      int score = 0;
      
      // Avaliar correspondência para cada critério
      score += _calcularScore(row[plataformaIndex], plataforma);
      score += _calcularScore(row[categoriaIndex], categoria);
      score += _calcularScore(row[generoIndex], genero);
      score += _calcularScore(row[tagIndex], tag);

      if (score > 0) {
        jogosPontuados.add({
          'nome': row[nomeJogoIndex].toString(),
          'score': score,
        });
      }
    }

    // Ordenar jogos por pontuação decrescente
    jogosPontuados.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    // Retornar os [topN] nomes recomendados
    return jogosPontuados.take(topN).map((jogo) => jogo['nome'] as String).toList();
  }

  /// Calcula a pontuação para um critério, comparando o valor do CSV com o valor desejado.
  /// Retorna 2 pontos para correspondência exata e 1 ponto se o valor contiver a string buscada.
  int _calcularScore(dynamic valorCsv, String criterio) {
    final valorStr = valorCsv.toString().toLowerCase();
    final criterioStr = criterio.toLowerCase();
    if (valorStr == criterioStr) {
      return 2;
    } else if (valorStr.contains(criterioStr)) {
      return 1;
    }
    return 0;
  }
}