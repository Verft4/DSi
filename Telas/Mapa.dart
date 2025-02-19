import 'package:namer_app/bibliotecas.dart';

import 'package:latlong2/latlong.dart';



class MapaJogosScreen extends StatefulWidget {
  @override
  _MapaJogosScreenState createState() => _MapaJogosScreenState();
}

class _MapaJogosScreenState extends State<MapaJogosScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  LatLng _currentLocation = LatLng(-8.0476, -34.8770); // Recife como ponto central
  List<LatLng> _gameLocations = [
    LatLng(35.6895, 139.6917), // Tóquio (Sede da Nintendo, Sony)
    LatLng(47.4925, 19.0513), // Budapeste (Sede da CD Projekt Red)
    LatLng(37.7749, -122.4194), // São Francisco (Sede da Ubisoft SF)
  ];

  Future<void> _searchLocation() async {
    String query = _searchController.text;
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        setState(() {
          _currentLocation = LatLng(locations.first.latitude, locations.first.longitude);
          _mapController.move(_currentLocation, 12.0);
        });
      }
    } catch (e) {
      if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Local não encontrado")),
      );}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa de Jogos")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(hintText: "Pesquisar localização"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(initialCenter: _currentLocation, initialZoom: 5.0),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _gameLocations.map((location) => Marker(
                        width: 40.0,
                        height: 40.0,
                        point: location,
                        child: Icon(Icons.videogame_asset, color: Colors.red, size: 30.0),
                      )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}