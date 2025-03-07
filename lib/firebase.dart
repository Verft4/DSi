
import 'bibliotecas.dart';
import 'Telas/Notas.dart';



class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> cadastrarUsuario(String email, String senha) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      return null; // Retorna null se o cadastro for bem-sucedido
    } catch (e) {
      return e.toString(); // Retorna o erro como string
    }
  }
}



class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> verifyUserExists(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.exists; // Verifica se o documento existe
    } catch (e) {
      print("Erro ao verificar usuário no Firestore: $e");
      return false;
    }
  }
}



class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }
}



class FirebaseServiceQUiz {
  // Função para salvar as respostas do quiz no Firestore
  Future<void> salvarRespostas(String? plataforma, String? preferenciaJogos,
      String? generoJogo, String? tagJogo) async {
    String? uid = await _obterUid();
    if (uid == null) {
      // UID não encontrado no SharedPreferences, talvez redirecionar para a página de login.
      return;
    }

    // Instância do Firestore
    final firestore = FirebaseFirestore.instance;

    // Salvar os dados no Firestore
    await firestore.collection('usuarios').doc(uid).set({
      'plataforma': plataforma,
      'preferenciaJogos': preferenciaJogos,
      'generoJogo': generoJogo,
      'tagJogo': tagJogo,
    });
  }

  // Função para obter o UID do usuário armazenado no SharedPreferences
  Future<String?> _obterUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }
}

class NoteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteNote(String uid, String noteId) async {
    await _firestore
        .collection('notas')
        .doc(uid)
        .collection('userNotes')
        .doc(noteId)
        .delete();
  }

  Future<void> saveNote(String uid, Note note) async {
    await _firestore
        .collection('notas')
        .doc(uid)
        .collection('userNotes')
        .add(note.toMap());
  }

  Future<void> updateNote(String uid, Note note) async {
    await _firestore
        .collection('notas')
        .doc(uid)
        .collection('userNotes')
        .doc(note.id)
        .update(note.toMap());
  }

  Future<List<Note>> fetchNotes(String uid) async {
    QuerySnapshot snapshot = await _firestore
        .collection('notas')
        .doc(uid)
        .collection('userNotes')
        .get();
    return snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList();
  }
}


