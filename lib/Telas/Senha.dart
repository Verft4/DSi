import 'package:namer_app/bibliotecas.dart'; 



class SenhaPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário
  final _senhaController = TextEditingController(); // Controlador para o campo de senha
  final _emailController = TextEditingController(); // Controlador para o campo de email
  final imagebookshelf = "https://icon-library.com/images/bookshelf-icon-png/bookshelf-icon-png-6.jpg";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 188, 185, 225),
      body: SingleChildScrollView( // Tornar a tela rolável
        child: Column(
          children: <Widget>[
            // Cabeçalho com título e imagem
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 188, 185, 225),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "GAME LIBRARY",
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                    ),
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
            // Corpo da página
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
                        'Recuperação de Senha',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 20),

                      // Campo Email
                      TextFormField(
                        controller: _emailController, // Controlador para email
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

                      // Campo Nova Senha
                      TextFormField(
                        obscureText: true,
                        controller: _senhaController, // Controlador do campo de senha
                        decoration: InputDecoration(
                          labelText: 'Nova Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe a nova senha';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Campo Confirmar Senha
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirme sua senha';
                          }
                          if (value != _senhaController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      // Botão Confirmar
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            try {
                              // Atualiza a senha do usuário
                              User? user = _auth.currentUser;
                              await user?.updatePassword(_senhaController.text);

                              

                              // Exemplo de ação ao confirmar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Senha atualizada com sucesso!')),
                              );

                              Navigator.pop(context); // Voltar para a tela anterior
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro: ${e.toString()}')),
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
                        child: Text('Confirmar'),
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
