import 'package:namer_app/bibliotecas.dart'; 
import 'package:namer_app/firebase.dart';



class LoginPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService(); // Instância do FirebaseAuthService
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instância do Firestore
  final imagebookshelf = "https://th.bing.com/th/id/OIP.qGu31yC_X4ZoXeqmoOxy2wHaHa?rs=1&pid=ImgDetMain";

  Future<void> _saveUserId(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid); // Salva o UID
  }

  Future<void> _checkUserAndRedirect(String uid, BuildContext context) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('usuarios').doc(uid).get();
      

      if (userDoc.exists) {
        
        // Se o documento do usuário existir, redireciona para /home
        
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Se o documento não existir, redireciona para /criacao
        Navigator.pushReplacementNamed(context, '/criacao');
      }
    } catch (e) {
      // Exibe mensagem de erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar o usuário: ${e.toString()}')),
      );
    }
  }

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
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(color: Color.fromARGB(255, 188, 185, 225)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "GAME LIBRARY",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Image.network(
                      imagebookshelf,
                      width: 150,
                      height: 150,
                      colorBlendMode: BlendMode.modulate,
                      color: Color.fromARGB(255, 193, 190, 227),
                    ),
                  ],
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Bem-vindo!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 20),

                      // Campo Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o email';
                          }
                          final RegExp regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                          if (!regex.hasMatch(value)) {
                            return 'Informe um email válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Campo Senha
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a senha';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Botão Entrar
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            try {
                              final userCredential = await _authService.signInWithEmailAndPassword(
                                _emailController.text.trim(),
                                _senhaController.text.trim(),
                              );
                              
                              if (userCredential != null) {
                                final uid = userCredential.user?.uid;
                                if (uid != null) {
                                  await _saveUserId(uid);  // Salva o UID do usuário
                                  await _checkUserAndRedirect(uid, context);  // Verifica o Firestore
                                }
                              }
                            
                            }  catch (e) {
                              
                              
                              // Exibe mensagem de erro caso o login falhe
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro ao fazer login: ${e.toString()}')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                        ),
                        child: Text('Entrar'),
                      ),
                      SizedBox(height: 20),

                      // Texto clicável "Esqueceu a senha?"
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/reset');
                        },
                        child: Text(
                          'Esqueceu a senha?',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/cadastro');
                        },
                        child: Text(
                          'Criar conta?',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/apagar');
                        },
                        child: Text(
                          'Apagar conta?',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
}