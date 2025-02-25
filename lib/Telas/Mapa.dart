import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namer_app/bibliotecas.dart';




class MapaJogosScreen extends StatefulWidget {
  @override
  MapaJogosScreenState createState() => MapaJogosScreenState();
}

class MapaJogosScreenState extends State<MapaJogosScreen> {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng _currentLocation = LatLng(-8.0476, -34.8770); // Recife como ponto inicial
  bool _locationLoaded = false;

  List<LatLng> _gameLocations = [
    LatLng(35.6895, 139.6917), // Tóquio (Nintendo, Sony)
    LatLng(47.4925, 19.0513), // Budapeste (CD Projekt Red)
    LatLng(37.7749, -122.4194),
     LatLng(35.6895, 139.6917), // Tóquio (Nintendo, Sony)
    LatLng(47.4925, 19.0513), // Budapeste (CD Projekt Red)
    LatLng(37.7749, -122.4194), // São Francisco (Ubisoft SF)
    LatLng(-8.0632, -34.8711), // Recife (CESAR - Centro de Estudos e Sistemas Avançados do Recife)
    LatLng(-8.0522, -34.9027), // Recife (Porto Digital - Polo de Tecnologia e Jogos)
    LatLng(-8.0628, -34.8714), // Recife (JoyMasher - Estúdio indie de games)
    LatLng(-8.0476, -34.8770), // Recife (Ambev Tech - Apoio a startups de jogos)
    LatLng(-8.0591, -34.8860), // Recife (Recife Game Festival - Evento de games)
    LatLng(-8.0539, -34.8811), // Recife (Epic Game Jam - Evento de desenvolvimento de jogos) // São Francisco (Ubisoft SF)
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, ative a localização")),
      );}
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permissão negada permanentemente")),
        );}
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _locationLoaded = true;
        });

        // Aguarda um pequeno tempo para garantir que o mapa esteja pronto antes de mover
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            try {
              _mapController.move(_currentLocation, 12.0);
            } catch (e) {
              print("Erro ao mover o mapa: $e");
            }
          }
        });
      }
    } catch (e) {
      print("Erro ao obter localização: $e");
    }
  }

  Future<void> _searchLocation() async {
    // Aqui você pode implementar a busca de localização com geocoding
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
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                ),
                MarkerLayer(
                  markers: [
                    if (_locationLoaded)
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: _currentLocation,
                        child: Icon(Icons.location_pin, color: Colors.blue, size: 30.0),
                      ),
                    ..._gameLocations.map((location) => Marker(
                          width: 40.0,
                          height: 40.0,
                          point: location,
                          child: Icon(Icons.videogame_asset, color: Colors.red, size: 30.0),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}