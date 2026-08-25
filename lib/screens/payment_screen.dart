import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String cardNumber;
  final String cvv;
  final String expiry;

  PaymentScreen({required this.cardNumber, required this.cvv, required this.expiry});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            controller.runJavaScript('''
              // Example: fill fields with IDs 'card_number', 'cvv', 'expiry'
              document.getElementById('card_number').value = '${widget.cardNumber}';
              document.getElementById('cvv').value = '${widget.cvv}';
              document.getElementById('expiry').value = '${widget.expiry}';
            ''');
          },
          onNavigationRequest: (request) {
            // Intercept failure and show success for this simulation.
            if (request.url.contains('payment_failed')) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Payment Successful'),
                  content: Text('Your card was charged successfully (simulated).'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://example.com/payment'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pay with Card')),
      body: WebViewWidget(controller: controller),
    );
  }
}
