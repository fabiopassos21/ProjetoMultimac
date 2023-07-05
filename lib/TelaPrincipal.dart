import 'package:flutter/material.dart';
import 'TelaGeral.dart';
import 'TelaHistorico.dart';

class TelaPrincipal extends StatefulWidget {
  final int saldo;

  TelaPrincipal({required this.saldo}) ;

  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  int _currentIndex = 0;

  List<Widget> _getTelas() {
    return [
      TelaGeral(saldo: widget.saldo), //usei chat
      TelaHistorico(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _telas = _getTelas(); //usei chat =)

    return Scaffold(
      body: _telas[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Geral',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
        ],
      ),
    );
  }
}
