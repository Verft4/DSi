import 'package:namer_app/bibliotecas.dart'; 
import 'Geração.dart';


class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    final appState = context.read<MyAppState>();
    appState.carregarFavoritosDoFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final favoritos = appState.favorites;
    final jogos = appState.jogos;

    var filteredFavorites = jogos.where((jogo) => favoritos.contains(jogo[0])).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar favoritos...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: filteredFavorites.isEmpty
              ? Center(child: Text('Nenhum favorito encontrado.'))
              : ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: filteredFavorites.length,
                  itemBuilder: (context, index) {
                    var jogo = filteredFavorites[index];
                    var header = jogo[12];
                    var name = jogo[1];
                    var appid = jogo[0];

                    return Dismissible(
                      key: Key(appid.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        final appState = context.read<MyAppState>();
                        await appState.removerDosFavoritos(appid);
                      },
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(header),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await appState.removerDosFavoritos(appid);
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageFullScreen(header: header, name: name),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}


class ImageFullScreen extends StatelessWidget {
  final String header;
  final String name;

  ImageFullScreen({required this.header, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(header, fit: BoxFit.contain),
        ),
      ),
    );
  }
}