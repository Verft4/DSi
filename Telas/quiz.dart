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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState?.save();
                            // _salvarRespostas(); // Chame a função quando necessário
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          backgroundColor: Color.fromARGB(255, 188, 185, 225)                          
                          
                        ),
                        child: Text('Salvar e Continuar', style: TextStyle(fontSize: 18, color: Colors.white)),
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

