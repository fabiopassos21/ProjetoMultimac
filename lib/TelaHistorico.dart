import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';
class TelaHistorico extends StatelessWidget {

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        automaticallyImplyLeading:false,
        actions: [
        IconButton(onPressed:()  {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmação'),
            content: Text('Deseja sair?'),
            actions: [
              ElevatedButton(
                child: Text('Sim'),
                onPressed: () {
                  // Coloque aqui o código para realizar o logout do usuário
                  // e voltar para a tela de login
                  // Exemplo:
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
              ),
              ElevatedButton(
                child: Text('Não'),
                onPressed: () {
                },
              ),
            ],
          );
        },
      );

        },
            icon: Icon(Icons.logout)),
        ],
        title: Text('Bem Vindo'),
      ),
                  body: Center(
               child: Text('Conteúdo do histórico'),
      ),
    );
  }
}