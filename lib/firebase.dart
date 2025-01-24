import 'bibliotecas.dart';



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
