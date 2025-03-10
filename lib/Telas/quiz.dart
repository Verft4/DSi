import 'package:namer_app/bibliotecas.dart';
import 'package:namer_app/main.dart'; 











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

  final List<String> plataformas = ['Windows', 'Linux', 'Mac'];
  final List<String> preferenciasJogos = ['Single-Player', 'Multi-Player'];
  final List<String> gameGenres = [
    'Action',
    'Adventure',
    'RPG',
    'Strategy',
    'Horror',
    'Racing',
    'Sports',
    'Simulation',
    'Puzzle',
    'FPS',
    'Open World'
  ];
  final List<String> gameTags = [
    'Retro',
    'Co-op',
    'Battle Royale',
    'Rich Story',
    'Online Multiplayer',
    'Casual',
    'Indie',
    'Exploration',
    'Survival',
    'Hack and Slash'
  ];

  void _buscarRecomendacoes() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      // Instancia o serviço e busca as recomendações conforme os parâmetros selecionados
      final recomendacaoService = RecomendacaoService();
      final recomendacoes = await recomendacaoService.buscarRecomendacoes(
        plataforma: plataforma!,
        categoria: preferenciaJogos!,
        genero: generoJogo!,
        tag: tagJogo!,
      );

      // Salva a lista de recomendações no SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recomendacoes', recomendacoes);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            // Não passamos mais as recomendações como argumento
            builder: (context) => MyHomePage(),
          ),
        );
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
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 188, 185, 225),
                ),
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
                      _buildDropdownField("Plataforma", plataformas,
                          (value) => plataforma = value),
                      SizedBox(height: 20),
                      _buildDropdownField("Tipo de Jogo", preferenciasJogos,
                          (value) => preferenciaJogos = value),
                      SizedBox(height: 20),
                      _buildDropdownField("Gênero do Jogo", gameGenres,
                          (value) => generoJogo = value),
                      SizedBox(height: 20),
                      _buildDropdownField(
                          "Tags", gameTags, (value) => tagJogo = value),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _buscarRecomendacoes,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          backgroundColor:
                              Color.fromARGB(255, 188, 185, 225),
                        ),
                        child: Text(
                          'Buscar Recomendações',
                          style: TextStyle(fontSize: 18, color: Colors.white),
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

  Widget _buildDropdownField(
      String label, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      value: null,
      onChanged: onChanged,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: TextStyle(fontSize: 16)),
            ),
          )
          .toList(),
    );
  }
}

class RecomendacaoService {
  /// Busca recomendações filtrando os dados do CSV pelos critérios:
  /// [plataforma], [categoria] (tipo de jogo), [genero] e [tag].
  Future<List<String>> buscarRecomendacoes({
    required String plataforma,
    required String categoria,
    required String genero,
    required String tag,
  }) async {
    // Carrega o CSV dos assets
    final String csvString =
        await rootBundle.loadString('assets/dataset_filtrado.csv');

    // Converte o CSV para uma lista de listas.
    final List<List<dynamic>> csvTable =
        CsvToListConverter().convert(csvString, eol: '\n');

    // Filtro os dados do CSV pelos critérios
    final headers = csvTable.first;
    final int indexNome = headers.indexOf('Name');
    // Índices para as três colunas de plataformas
    final int indexWindows = headers.indexOf('Windows');
    final int indexLinux = headers.indexOf('Linux');
    final int indexMac = headers.indexOf('Mac');
    final int indexCategoria = headers.indexOf('Categories');
    final int indexGenero = headers.indexOf('Genres');
    final int indexTag = headers.indexOf('Tags');

    List<String> recomendacoes = [];

    // Percorre as linhas a partir da segunda (index 1) e filtra as recomendações
    for (int i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];

      // Verifica se a plataforma informada está presente em alguma das três colunas
      bool plataformaValida =
          row[indexWindows].toString().toLowerCase() == plataforma.toLowerCase() ||
          row[indexLinux].toString().toLowerCase() == plataforma.toLowerCase() ||
          row[indexMac].toString().toLowerCase() == plataforma.toLowerCase();

      // Verifica se a categoria bate (assumindo que a célula contém somente um valor)
      bool categoriaValida = row[indexCategoria]
          .toString()
          .toLowerCase()
          .trim() == categoria.toLowerCase().trim();

      // Para gêneros, divide a string (supondo que os gêneros são separados por vírgula)
      List<String> listaGeneros = row[indexGenero]
          .toString()
          .toLowerCase()
          .split(',')
          .map((g) => g.trim())
          .toList();
      bool generoValido = listaGeneros.contains(genero.toLowerCase().trim());

      // Para tags, faz o mesmo procedimento
      List<String> listaTags = row[indexTag]
          .toString()
          .toLowerCase()
          .split(',')
          .map((t) => t.trim())
          .toList();
      bool tagValido = listaTags.contains(tag.toLowerCase().trim());

      if (plataformaValida && categoriaValida && generoValido && tagValido) {
        recomendacoes.add(row[indexNome].toString());
      }
    }

    return recomendacoes;
  }
}