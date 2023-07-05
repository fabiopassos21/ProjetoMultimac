import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';


class TelaGeral extends StatelessWidget {
  final int saldo;

  TelaGeral({required this.saldo});

  Widget _renderBotaoAdicional() {
    return ElevatedButton(
      onPressed: () {
        // Ação ao pressionar o botão adicional
      },
      child: Text('Botão Adicional'),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    MaterialPageRoute(builder: (context) => Teste()),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 40,),
            Text(
              'Saldo: $saldo',
              style: TextStyle(fontSize: 24),


    ),
            SizedBox(
              width: 40,height: 40,
            ),
            if (saldo > 0) _renderBotaoAdicional(),

          ],
        ),
      ),
    );
  }
}
