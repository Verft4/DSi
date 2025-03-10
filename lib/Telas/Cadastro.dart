import 'package:namer_app/bibliotecas.dart'; 
import 'package:namer_app/firebase.dart';



class CadastroPage extends StatefulWidget {
  @override
  State <CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  final imagebookshelf = "https://th.bing.com/th/id/OIP.qGu31yC_X4ZoXeqmoOxy2wHaHa?rs=1&pid=ImgDetMain";

  // Controladores para os campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

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
                        'Crie sua conta!',
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

                      // Botão Cadastrar
                      ElevatedButton(
  onPressed: () async {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final senha = _senhaController.text;

      final authService = AuthService();
      final errorMessage = await authService.cadastrarUsuario(email, senha);

      if (errorMessage == null) {
        // Sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
        Navigator.pop(context); // Volta para a tela de login
      } else {
        // Exibe mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
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
  child: Text('Cadastrar'),
),

                      SizedBox(height: 20),

                      // Texto clicável "Já tem uma conta?"
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Volta para a tela de login
                        },
                        child: Text(
                          'Já tem uma conta? Entrar',
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