import 'package:namer_app/bibliotecas.dart'; 





class Note {
  String title;
  String content;
  DateTime creationDate;

  Note({
    required this.title,
    required this.content,
    required this.creationDate,
  });

  // Converte uma nota para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'creationDate': creationDate.toIso8601String(),
    };
  }

  // Cria uma nota a partir de um Map (para ler do Firestore)
  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      content: map['content'],
      creationDate: DateTime.parse(map['creationDate']),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> notes = [];
  String searchQuery = '';
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  late String uid;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Carrega o UID do usuário
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString('uid') ?? '';
    });
    _fetchNotes();
  }

  // Função para salvar uma nota no Firebase
  Future<void> _saveNoteToFirestore(Note note) async {
    if (uid.isEmpty) return; // Certifique-se de que o UID foi carregado

    try {
      await FirebaseFirestore.instance
          .collection('notas')
          .doc(uid)
          .collection('userNotes')
          .add(note.toMap());
      _fetchNotes(); // Atualiza as notas após salvar
    } catch (e) {
      print('Erro ao salvar nota: $e');
    }
  }

  // Função para buscar notas do Firebase
  Future<void> _fetchNotes() async {
    if (uid.isEmpty) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('notas')
          .doc(uid)
          .collection('userNotes')
          .get();

      setState(() {
        notes = snapshot.docs.map((doc) => Note.fromMap(doc.data() as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      print('Erro ao buscar notas: $e');
    }
  }

  void addNote() {
    if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
      Note newNote = Note(
        title: titleController.text,
        content: contentController.text,
        creationDate: DateTime.now(),
      );
      _saveNoteToFirestore(newNote);
      titleController.clear();
      contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    var filteredNotes = notes.where((note) {
      return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Notas'),
        backgroundColor: Color.fromARGB(255, 188, 185, 225),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 188, 185, 225),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 123, 115, 115).withValues(),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Pesquisar Notas...',
                  border:  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                String previewContent = note.content.length > 30
                    ? '${note.content.substring(0, 30)}...'
                    : note.content;
                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    '$previewContent | ${note.creationDate.toLocal()}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título da Nota',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: InputDecoration(labelText: 'Conteúdo da Nota'),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: addNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 188, 185, 225),
                  ),
                  child: Text(
                    'Adicionar Nota',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}