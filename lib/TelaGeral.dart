import 'package:flutter/material.dart';


class TelaGeral extends StatefulWidget {
  const TelaGeral({Key? key}) : super(key: key);

  @override
  State<TelaGeral> createState() => _TelaGeralState();
}

class _TelaGeralState extends State<TelaGeral> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela Geral po'),
      ),
      body: Center(
        child: Text('Conteúdo do histórico'),
      ),
    );
  }
}
