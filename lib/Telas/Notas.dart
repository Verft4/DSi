import 'package:namer_app/bibliotecas.dart'; 
import 'package:intl/intl.dart'; 
import 'package:namer_app/firebase.dart';

class Note {
  String? id;
  String title;
  String content;
  DateTime creationDate;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.creationDate,
  });
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? creationDate,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      creationDate: creationDate ?? this.creationDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'creationDate': creationDate.toIso8601String(),
    };
  }

  static Note fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'],
      content: data['content'],
      creationDate: DateTime.parse(data['creationDate']),
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final NoteService _noteService = NoteService();
  List<Note> notes = [];
  String searchQuery = '';
  late String uid;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() => uid = prefs.getString('uid') ?? '');
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    if (uid.isEmpty) return;
    try {
      List<Note> fetchedNotes = await _noteService.fetchNotes(uid);
      setState(() => notes = fetchedNotes);
    } catch (e) {
      print('Erro ao buscar notas: $e');
    }
  }

  void _showAddNoteDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildNoteEditor(
        title: 'Adicionar Nota',
        titleController: titleController,
        contentController: contentController,
        onSave: () async {
          if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
            await _noteService.saveNote(uid, Note(
              title: titleController.text,
              content: contentController.text,
              creationDate: DateTime.now(),
            ));
            _fetchNotes();
            if (mounted){
            Navigator.pop(context);}
          }
        },
      ),
    );
  }

  void _showEditNoteDialog(Note note) {
    TextEditingController titleController = TextEditingController(text: note.title);
    TextEditingController contentController = TextEditingController(text: note.content);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildNoteEditor(
        title: 'Editar Nota',
        titleController: titleController,
        contentController: contentController,
        onSave: () async {
          if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
            await _noteService.updateNote(uid, note.copyWith(
              title: titleController.text,
              content: contentController.text,
            ));
            _fetchNotes();
            if (mounted){
            Navigator.pop(context);}
          }
        },
      ),
    );
  }

  Widget _buildNoteEditor({
    required String title,
    required TextEditingController titleController,
    required TextEditingController contentController,
    required VoidCallback onSave,
  }) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets.add(EdgeInsets.all(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          TextField(controller: titleController, decoration: InputDecoration(labelText: 'Título')),
          SizedBox(height: 12),
          TextField(controller: contentController, maxLines: 3, decoration: InputDecoration(labelText: 'Conteúdo')),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 188, 185, 225),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
            ),
            child: Text(title.startsWith('Adicionar') ? 'Salvar Nota' : 'Atualizar Nota'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes.where((note) {
      return note.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Notas'),
        backgroundColor: Color.fromARGB(255, 188, 185, 225),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar notas...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(child: Text('Nenhuma nota encontrada'))
                : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) => _buildNoteItem(filteredNotes[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        backgroundColor: Color.fromARGB(255, 188, 185, 225),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteItem(Note note) {
    return Dismissible(
      key: Key(note.id!),
      background: Container(color: Colors.red, alignment: Alignment.centerLeft, child: Icon(Icons.delete)),
      onDismissed: (_) async {
        await _noteService.deleteNote(uid, note.id!);
        _fetchNotes();
      },
      child: Card(
        child: ListTile(
          title: Text(note.title),
          subtitle: Text(note.content),
          trailing: Text(DateFormat('dd/MM/yyyy').format(note.creationDate)),
          onTap: () => _showEditNoteDialog(note),
        ),
      ),
    );
  }
}