import 'package:flutter/material.dart';
class TelaHistorico extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:false,
        title: Text('Tela Histórico'),
      ),
      body: Center(
        child: Text('Conteúdo do histórico'),
      ),
    );
  }
}