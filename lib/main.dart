import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projetoudemy/TelaPrincipal.dart';
import 'package:shared_preferences/shared_preferences.dart';

final CollectionReference usuariosCollection =
FirebaseFirestore.instance.collection('Usuarios');

class Teste extends StatefulWidget {
  const Teste({Key? key}) : super(key: key);

  @override
  State<Teste> createState() => _TesteState();
}

class _TesteState extends State<Teste> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  void adicionarUsuario() {
    String email = emailController.text;
    String senha = passwordController.text;

    usuariosCollection.add({
      'email': email,
      'senha': senha,
    }).then((value) {
      print('Usuário $email adicionado com ID: ${value.id}');
    }).catchError((error) {
      print('Erro ao adicionar o usuário: $error');
    });
  }

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      print("DEU CERTO UHULLL");
      print('Usuário logado: ${userCredential.user!.email}');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TelaPrincipal()),
      );
      // Chamar a função adicionarUsuario após o login ser bem-sucedido
      adicionarUsuario();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: 'E-mail ou senha incorretos');
        errorMessage = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: 'E-mail ou senha incorretos');
        errorMessage = 'Senha incorreta.';
      } else {
        errorMessage = 'Erro durante o login: ${e.message}';
        Fluttertoast.showToast(msg: 'E-mail ou senha incorretos');
      }
    } catch (e) {
      errorMessage = 'Erro durante o login: $e';
      Fluttertoast.showToast(msg: 'E-mail ou senha incorretos');
    }
  }

  Future<void> _register(BuildContext context) async {
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      print('Usuário cadastrado: ${userCredential.user!.email}');
      Fluttertoast.showToast(msg: 'Login realizado com sucesso');

      // Chamar a função adicionarUsuario após o registro ser bem-sucedido
      adicionarUsuario();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorMessage = 'Senha fraca. Escolha uma senha mais segura.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'O email já está sendo usado por outra conta.';
      } else {
        errorMessage = 'Erro durante o cadastro: ${e.message}';
      }
      setState(() {
        Fluttertoast.showToast(msg: 'E-mail ou senha incorretos');
      });
    } catch (e) {
      errorMessage = 'Erro durante o cadastro: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login e Cadastro'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Entrar'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () => _register(context),
              child: Text('Cadastrar'),
            ),
            SizedBox(height: 16.0),
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: Teste(),
  ));
}
