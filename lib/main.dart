import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Pagamento.dart';
import 'TelaPrincipal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyText1: TextStyle(
            fontSize: 18,
            color: Colors.white54,
          ),
        ),
      ),
      home: const LoginScreen(),

    );
  }
}

class LoginScreen extends StatefulWidget {
const LoginScreen({Key? key}) : super(key: key);

@override
State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
String errorMessage = '';
String saldo = '0.00';

Future<bool> checkLoginState() async {
SharedPreferences prefs = await SharedPreferences.getInstance();
bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
String savedEmail = prefs.getString('email') ?? '';
String savedPassword = prefs.getString('password') ?? '';

if (isLoggedIn) {
emailController.text = savedEmail;
passwordController.text = savedPassword;

try {
await FirebaseAuth.instance.signInWithEmailAndPassword(
email: savedEmail,
password: savedPassword,
);

// Força a atualização dos dados do Firestore
await FirebaseFirestore.instance.collection('Usuarios').doc(savedEmail).get();

// Obtém o saldo do usuário do Firestore
saldo = await getSaldoFromFirestore(savedEmail);

return true; // Indica que o usuário está logado
} on FirebaseAuthException catch (e) {
// Lidar com o erro de autenticação, se necessário
print('Erro durante o login: ${e.message}');
} catch (e) {
// Lidar com outros erros, se necessário
print('Erro durante o login: $e');
}
}

return false; // Indica que o usuário não está logado
}

Future<void> saveLoginState(String email, String password) async {
SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setBool('isLoggedIn', true);
await prefs.setString('email', email);
await prefs.setString('password', password);
}

  Future<void> _login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Força a atualização dos dados do Firestore
      await FirebaseFirestore.instance.collection('Usuarios').snapshots().first;

      // Obtém o saldo do usuário do Firestore
      saldo = await getSaldoFromFirestore(emailController.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaPrincipal(saldo: saldo)),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage = 'Usuário não encontrado.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Senha incorreta.';
      } else {
        errorMessage = 'Erro durante o login: ${e.message}';
      }
      setState(() {});
    } catch (e) {
      errorMessage = 'Erro durante o login: $e';
      setState(() {});
    }
  }

  Future<void> _register(BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Obtém o saldo do usuário do Firestore
      saldo = await getSaldoFromFirestore(emailController.text);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaPrincipal(saldo: saldo)),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        errorMessage = 'Senha fraca. Escolha uma senha mais segura.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'O email já está sendo usado por outra conta.';
      } else {
        errorMessage = 'Erro durante o cadastro: ${e.message}';
      }
      setState(() {});
    } catch (e) {
      errorMessage = 'Erro durante o cadastro: $e';
      setState(() {});
    }
  }

  Future<String> getSaldoFromFirestore(String email) async {
    String saldo = '0.00';

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = snapshot.docs.first;
        saldo = userDoc.get('saldo').toString();
      }
    } catch (e) {
      print('Erro ao obter saldo do Firestore: $e');
    }

    return saldo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  'Multimac'.toUpperCase(),
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(
                  'Pagina de Login',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Senha',
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () {}, // SEM USO
                      child: const Text('Esqueceu a senha?'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _login(context),
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Não possui uma conta?"),
                      TextButton(
                        onPressed: () => _register(context),
                        child: const Text('Criar conta'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

  }

}




