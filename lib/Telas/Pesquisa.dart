import 'package:namer_app/bibliotecas.dart'; 
import 'package:url_launcher/url_launcher.dart';

class Pesquisa extends StatefulWidget {
  @override
  State<Pesquisa> createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  String searchQuery = '';
  List<List<dynamic>> jogos = [];
  List<List<dynamic>> jogosFiltrados = [];

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
    });
  }

  void filtrarJogos(String query) {
    setState(() {
      searchQuery = query;
      jogosFiltrados = jogos
          .where((jogo) => jogo[1].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisar Jogos'),
        backgroundColor:Color.fromARGB(255, 188, 185, 225),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar jogo...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filtrarJogos,
            ),
          ),
          Expanded(
            child: jogosFiltrados.isNotEmpty
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: jogosFiltrados.length,
                    itemBuilder: (context, index) {
                      final jogo = jogosFiltrados[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalhesJogo(jogo: jogo),
                          ),
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              jogo[12],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.broken_image,
                                size: 100,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(child: Text('Nenhum jogo encontrado.')),
          ),
        ],
      ),
    );
  }
}

class DetalhesJogo extends StatelessWidget {
  final List<dynamic> jogo;

  DetalhesJogo({required this.jogo});

  Future<void> _abrirLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir o link: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final header = jogo[12];
    final name = jogo[1];
    final about = jogo[8];
    final price = jogo[6];
    final genres = jogo[35];
    final link = jogo[13];

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Color.fromARGB(255, 188, 185, 225),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              header,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.broken_image,
                size: 100,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.blue),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          genres,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.green),
                      SizedBox(width: 5),
                      Text(price.toString()),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    about,
                    textAlign: TextAlign.justify,
                    style: TextStyle(height: 1.5),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _abrirLink(link),
                      child: Text('Acessar Página do Jogo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}