import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Pagamento.dart';

class TelaPrincipal extends StatefulWidget {
  final String saldo;

  const TelaPrincipal({Key? key, required this.saldo}) : super(key: key);

  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  late String saldoAtual;

  @override
  void initState() {
    super.initState();
    saldoAtual = widget.saldo;
  }

  Future<void> _atualizarSaldo() async {
    try {
      String novoSaldo = await getSaldoFromFirestore(FirebaseAuth.instance.currentUser!.email!);
      setState(() {
        saldoAtual = novoSaldo;
      });
    } catch (e) {
      print('Erro ao atualizar saldo: $e');
    }
  }

  Future<String> getSaldoFromFirestore(String email) async {
    String saldo = '0.00';

    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(email)
          .get();

      if (snapshot.exists) {
        saldo = snapshot.get('saldo').toString();
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
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 2,
            color: Colors.green,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Bem Vindo: Fabinho",
                    style: TextStyle(
                      fontSize: 26.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Roboto",
                    ),
                  ),
                  const Text(
                    'Bem-vindo à tela principal!',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Saldo: $saldoAtual',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PixChargeView(saldo: saldoAtual, onSaldoReceived: (int) {}
                                  )
                              )
                          );
                        },
                        child: Icon(Icons.attach_money),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        onPressed: () {
                          // Ação do botão Vídeos Tutoriais
                        },
                        child: Icon(Icons.play_arrow),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        onPressed: () {
                          // Ação do botão Produtos
                        },
                        child: Icon(Icons.shopping_cart),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ElevatedButton(
                        onPressed: () {
                          // Ação do botão Logout
                        },
                        child: Icon(Icons.logout),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
    );
  }
}
