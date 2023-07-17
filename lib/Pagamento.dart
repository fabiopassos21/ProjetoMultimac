import 'dart:async';
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
  double progressValue = 0.0;
  int countdown = 300; // 5 minutos em segundos
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _byteImage = Uint8List(0);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
          progressValue = 1.0 - (countdown / 300);
        } else {
          timer.cancel();
          showPaymentResultScreen(); // Exibe a tela de resultado do pagamento
        }
      });
    });
  }

  void createCharge() {
    setState(() {
      countdown = 300; // Reinicia o contador regressivo
      progressValue = 0.0; // Reinicia o progresso
    });

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

        // Inicia a contagem regressiva
        startTimer();
      }).catchError((onError) {
        print('Erro ao gerar o QR code: $onError');
      });
    }).catchError((onError) {
      print('Erro ao criar a cobrança: $onError');
    });
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

    http.Response response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
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

    http.Response response = await http.get(Uri.parse(apiUrl), headers: headers);
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

        print('Pagamento confirmado: $cobrancaId'); // Print quando o pagamento for confirmado
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

  void showPaymentResultScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentResultScreen(),
      ),
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
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressValue,
          ),
          SizedBox(height: 16),
          Text(pixPart),
          SizedBox(height: 16),
          Text(
            '${(countdown ~/ 60).toString().padLeft(2, '0')}:${(countdown % 60).toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _qrCode() {
    return Image.memory(_byteImage.buffer.asUint8List());
  }
}

class PaymentResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resultado do Pagamento"),
      ),
      body: Center(
        child: Text(
          "O pagamento está pendente ou falhou.",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
