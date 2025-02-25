
import 'bibliotecas.dart';
import 'package:http/http.dart' as http;


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


class RecomendacaoService {
  final String baseUrl = "http://127.0.0.1:5000";

  Future<List<String>> buscarRecomendacoes({
    required String plataforma,
    required String categoria,
    required String genero,
    required String tag,
  }) async {
    final url = Uri.parse('$baseUrl/recomendar');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "plataforma": plataforma,
        "categoria": categoria,
        "genero": genero,
        "tag": tag,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data["recomendacoes"]);
    } else {
      throw Exception("Erro ao buscar recomendações");
    }
  }
}

