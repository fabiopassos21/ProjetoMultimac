import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gerencianet/gerencianet.dart';
import 'package:http/http.dart' as http;

import 'Pix/OPTIONS.dart' as PixOptions;

class PixChargeView extends StatefulWidget {
  final String saldo;
  final Function(String) onSaldoReceived;

  const PixChargeView({Key? key, required this.saldo, required this.onSaldoReceived}) : super(key: key);

  @override
  _PixChargeViewState createState() => _PixChargeViewState();
}

class _PixChargeViewState extends State<PixChargeView> {
  late Uint8List _byteImage;
  String pixPart = '';

  @override
  void initState() {
    super.initState();
    _byteImage = Uint8List(0);
  }

  void createCharge() {
    Gerencianet gerencianet = Gerencianet(PixOptions.OPTIONS);
    Map<String, dynamic> body = {
      "calendario": {
        "expiracao": 3600,
      },
      "valor": {
        "original": double.parse(widget.saldo).toStringAsFixed(2),
      },
      "chave": "sei_la97@hotmail.com",
    };

    gerencianet.call("pixCreateImmediateCharge", body: body).then((value) {
      gerencianet.call("pixGenerateQRCode", params: {"id": value['loc']['id']}).then((value) {
        setState(() {
          _byteImage = Base64Decoder().convert(value['imagemQrcode'].split(',').last);

          String pixLine = value['qrcode'];
          int startIndex = pixLine.indexOf('padrao') + 6;
          int endIndex = pixLine.length < startIndex + 10 ? pixLine.length : startIndex + 10;
          pixPart = pixLine.substring(startIndex, endIndex);
        });
        print(value);

        // Verifica o status do pagamento
        checkPaymentStatus(value['loc']['id']);
      }).catchError((onError) => print(onError));
    }).catchError((onError) => print(onError));
  }

  Future<String> getAccessToken() async {
    String apiUrl = 'https://api.gerencianet.com.br/v1/token';
    Object? clientId = PixOptions.OPTIONS['Client_Id_de294f072c7102f4270d359d53d8e988c48a9142'];
    Object? clientSecret = PixOptions.OPTIONS['Client_Secret_a2bb690838c361d473ed27c5f8365576b19bfcbc'];

    String auth = base64Encode(utf8.encode('$clientId:$clientSecret'));
    Map<String, String> headers = {
      'Authorization': 'Basic $auth',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    String body = 'grant_type=client_credentials';

    http.Response response = await http.post(apiUrl as Uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      String accessToken = responseBody['access_token'];
      return accessToken;
    } else {
      throw Exception('Falha ao obter o token de acesso: ${response.statusCode}');
    }
  }

  void checkPaymentStatus(String cobrancaId) async {
    String accessToken = await getAccessToken();
    String apiUrl = 'https://api.gerencianet.com.br/v2/pix/$cobrancaId';
    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(apiUrl as Uri, headers: headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> paymentStatus = jsonDecode(response.body);
      String status = paymentStatus['status'];

      // Tratamento do status do pagamento
      if (status == 'pago') {
        // O Pix foi pago
        showPaymentSuccessDialog(); // Exibe um diálogo ou uma mensagem de sucesso
        updateOrderStatus(); // Atualiza o estado do pedido ou transação
        sendPaymentConfirmationEmail(); // Envia um e-mail de confirmação ao usuário
        // Outras ações adicionais que você deseja executar
      } else if (status == 'pendente') {
        // O pagamento está pendente
        showPendingPaymentDialog(); // Exibe um diálogo ou uma mensagem informando ao usuário que o pagamento está pendente
        // Outras ações adicionais que você deseja executar
      } else {
        // O pagamento não foi realizado com sucesso
        showPaymentFailureDialog(); // Exibe um diálogo ou uma mensagem informando ao usuário que o pagamento falhou
        // Outras ações adicionais que você deseja executar
      }
    } else {
      // Erro na chamada à API
      print('Erro ao verificar o status do pagamento: ${response.statusCode}');
    }
  }

  void showPaymentSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pagamento Confirmado'),
          content: Text('Seu pagamento foi confirmado com sucesso.'),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateOrderStatus() {
    // Aqui você implementa a lógica para atualizar o estado do pedido ou transação
  }

  void sendPaymentConfirmationEmail() {
    // Aqui você implementa a lógica para enviar um e-mail de confirmação ao usuário
  }

  void showPendingPaymentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pagamento Pendente'),
          content: Text('Seu pagamento está pendente de confirmação.'),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showPaymentFailureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Falha no Pagamento'),
          content: Text('Ocorreu uma falha ao processar seu pagamento.'),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cobrança Pix"),
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: createCharge,
      ),
    );
  }

  Widget _body() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          _qrCode(),
          Text(pixPart),
        ],
      ),
    );
  }

  Widget _qrCode() {
    return Image.memory(_byteImage.buffer.asUint8List());
  }
}
