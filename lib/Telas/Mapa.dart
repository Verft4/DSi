import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:namer_app/bibliotecas.dart';
import 'package:http/http.dart' as http;



class MapaJogosScreen extends StatefulWidget {
  @override
  MapaJogosScreenState createState() => MapaJogosScreenState();
}

class MapaJogosScreenState extends State<MapaJogosScreen> {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  LatLng _currentLocation = LatLng(-8.0476, -34.8770); // Recife como ponto inicial
  bool _locationLoaded = false;

  // Lista fixa de localizações de jogos
  List<LatLng> _gameLocations = [
    LatLng(35.6895, 139.6917), // Tóquio (Nintendo, Sony)
    LatLng(47.4925, 19.0513),  // Budapeste (CD Projekt Red)
    LatLng(37.7749, -122.4194),// São Francisco (Ubisoft SF)
    LatLng(35.6895, 139.6917), // Tóquio (Nintendo, Sony)
    LatLng(47.4925, 19.0513),  // Budapeste (CD Projekt Red)
    LatLng(37.7749, -122.4194),// São Francisco (Ubisoft SF)
    LatLng(-8.0632, -34.8711), // Recife (CESAR)
    LatLng(-8.0522, -34.9027), // Recife (Porto Digital)
    LatLng(-8.0628, -34.8714), // Recife (JoyMasher)
    LatLng(-8.0476, -34.8770), // Recife (Ambev Tech)
    LatLng(-8.0591, -34.8860), // Recife (Recife Game Festival)
    LatLng(-8.0539, -34.8811), // Recife (Epic Game Jam)
  ];

  // Lista de detalhes para cada localização de jogo
  final List<String> _gameLocationDetails = [
    "Tóquio (Nintendo, Sony)",
    "Budapeste (CD Projekt Red)",
    "São Francisco (Ubisoft SF)",
    "Tóquio (Nintendo, Sony)",
    "Budapeste (CD Projekt Red)",
    "São Francisco (Ubisoft SF)",
    "Recife (CESAR - Centro de Estudos e Sistemas Avançados do Recife)",
    "Recife (Porto Digital - Polo de Tecnologia e Jogos)",
    "Recife (JoyMasher - Estúdio indie de games)",
    "Recife (Ambev Tech - Apoio a startups de jogos)",
    "Recife (Recife Game Festival - Evento de games)",
    "Recife (Epic Game Jam - Evento de desenvolvimento de jogos)",
  ];

  // Listas para pontos de interesse adicionados pelo usuário
  final List<LatLng> _userAddedMarkers = [];
  final List<String> _userAddedDetails = [];

  // Lista de estilos do mapa com nome e URL do template de tiles
  final List<Map<String, String>> _mapStyles = [
    {
      "name": "OpenStreetMap",
      "url": "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    },
    {
      "name": "Stamen Toner",
      "url": "https://stamen-tiles.a.ssl.fastly.net/toner/{z}/{x}/{y}.png",
    },
    {
      "name": "Stamen Watercolor",
      "url": "https://stamen-tiles.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg",
    },
  ];
  int _selectedStyleIndex = 0;

  // Lista para armazenar os marcadores de POI relacionados a jogos obtidos do OpenStreetMap
  List<Marker> _gamePOIMarkers = [];

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Por favor, ative a localização")),
        );
      }
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Permissão negada permanentemente")),
          );
        }
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

        // Chama a função para buscar POIs relacionados a jogos
        _fetchGamePOIs();

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

  // Função para buscar POIs relacionados a jogos via Overpass API (OpenStreetMap)
  Future<void> _fetchGamePOIs() async {
    final double lat = _currentLocation.latitude;
    final double lon = _currentLocation.longitude;
    final int radius = 10000; // Raio de 5km
    final String query = """
      [out:json];
      (
        node["shop"="video_games"](around:$radius, $lat, $lon);
        node["amenity"="arcade"](around:$radius, $lat, $lon);
      );
      out body;
    """;
    final String url =
        "https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Marker> markers = [];
        for (var element in data["elements"]) {
          double elementLat = element["lat"];
          double elementLon = element["lon"];
          String name = element["tags"]?["name"] ?? "Local de Jogos";
          markers.add(
            Marker(
              width: 40.0,
              height: 40.0,
              point: LatLng(elementLat, elementLon),
              child: GestureDetector(
                onTap: () {
                  _showLocationDetails(name);
                },
                child: Icon(
                  Icons.videogame_asset,
                  color: Colors.purple,
                  size: 30.0,
                ),
              ),
            ),
          );
        }
        setState(() {
          _gamePOIMarkers = markers;
        });
      } else {
        print("Erro ao buscar POIs de jogos: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro ao buscar POIs de jogos: $e");
    }
  }

  void _showUserMarkerOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userAddedDetails[index],
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _userAddedMarkers.removeAt(index);
                    _userAddedDetails.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
                child: Text("Apagar ponto"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _searchLocation() async {
    // Aqui você pode implementar a busca de localização com geocoding
  }

  // Função para exibir detalhes da localização
  void _showLocationDetails(String detail) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Text(
            detail,
            style: TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }

  // Função para exibir diálogo e adicionar ponto de interesse
  Future<void> _showAddInterestDialog(LatLng latlng) async {
    // Calcula a distância em metros entre a localização atual e o ponto selecionado
    double distanceMeters = Geolocator.distanceBetween(
      _currentLocation.latitude,
      _currentLocation.longitude,
      latlng.latitude,
      latlng.longitude,
    );

    // Formata a distância para exibir em metros ou quilômetros
    String distanceText = distanceMeters > 1000
        ? '${(distanceMeters / 1000).toStringAsFixed(2)} km'
        : '${distanceMeters.toStringAsFixed(2)} m';

    String detail = "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Adicionar ponto de interesse"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Exibe a distância calculada
              Text("Distância do usuário: $distanceText"),
              SizedBox(height: 10),
              TextField(
                autofocus: true,
                decoration: InputDecoration(hintText: "Descrição do ponto"),
                onChanged: (value) {
                  detail = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (detail.isNotEmpty) {
                  setState(() {
                    _userAddedMarkers.add(latlng);
                    _userAddedDetails.add(detail);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text("Adicionar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa de Jogos")),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration:
                        InputDecoration(hintText: "Pesquisar localização"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          // Seletor de estilo do mapa
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text("Estilo do Mapa: "),
                DropdownButton<int>(
                  value: _selectedStyleIndex,
                  items: List.generate(_mapStyles.length, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(_mapStyles[index]["name"]!),
                    );
                  }),
                  onChanged: (int? newIndex) {
                    if (newIndex != null) {
                      setState(() {
                        _selectedStyleIndex = newIndex;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          // Mapa
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 12.0,
                // Ao pressionar por tempo longo, exibe diálogo para adicionar ponto de interesse
                onLongPress: (tapPosition, latlng) {
                  _showAddInterestDialog(latlng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _mapStyles[_selectedStyleIndex]["url"]!,
                ),
                MarkerLayer(
                  markers: [
                    if (_locationLoaded)
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: _currentLocation,
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                          size: 30.0,
                        ),
                      ),
                    // Marcadores fixos de jogos
                    ..._gameLocations.asMap().entries.map((entry) {
                      int index = entry.key;
                      LatLng location = entry.value;
                      return Marker(
                        width: 40.0,
                        height: 40.0,
                        point: location,
                        child: GestureDetector(
                          onTap: () {
                            _showLocationDetails(_gameLocationDetails[index]);
                          },
                          child: Icon(
                            Icons.videogame_asset,
                            color: Colors.red,
                            size: 30.0,
                          ),
                        ),
                      );
                    }),
                    // Marcadores de pontos de interesse adicionados pelo usuário
                    ..._userAddedMarkers.asMap().entries.map((entry) {
                      int index = entry.key;
                      LatLng location = entry.value;
                      return Marker(
                        width: 40.0,
                        height: 40.0,
                        point: location,
                        child: GestureDetector(
                          onTap: () {
                            _showUserMarkerOptions(index);
                          },
                          child: Icon(
                            Icons.star,
                            color: Colors.green,
                            size: 30.0,
                          ),
                        ),
                      );
                    }),
                    // Marcadores dos POIs obtidos do OpenStreetMap
                    ..._gamePOIMarkers,
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