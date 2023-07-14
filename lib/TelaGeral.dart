import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Pagamento.dart';

class TelaGeral extends StatefulWidget {
  final String saldo;

  TelaGeral({required this.saldo});

  @override
  _TelaGeralState createState() => _TelaGeralState();
}

class _TelaGeralState extends State<TelaGeral> {
  String saldo = '0.00';

  @override
  void initState() {
    super.initState();
    saldo = widget.saldo;
  }

  Widget _renderBotaoAdicional() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PixChargeView(
              saldo: saldo,
              onSaldoReceived: (value) {
                setState(() {
                  saldo = value;
                });
              },
            ),
          ),
        );
      },
      child: const Text('PAGAR'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        title: const Text('Bem-vindo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'Saldo: $saldo',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(
              width: 40,
              height: 40,
            ),
            if (saldo != '0.00') _renderBotaoAdicional(),
          ],
        ),
      ),
    );
  }
}
