import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class CardScreen extends StatefulWidget {
  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  Map<String, dynamic>? _card;
  bool _loading = false;

  Future<void> _generateCard() async {
    setState(() => _loading = true);
    final phone = Provider.of<AuthProvider>(context, listen: false).phone!;
    final api = ApiService();
    try {
      final data = await api.generateCard(phone);
      setState(() {
        _card = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate card: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Virtual Card')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            if (_card != null)
              Card(
                color: Colors.blueGrey[900],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mastercard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 16),
                      Text('**** **** **** ${_card!['card_number'].toString().substring(12)}', style: TextStyle(fontSize: 22, color: Colors.white)),
                      SizedBox(height: 8),
                      Row(children: [
                        Text('CVV: ${_card!['cvv']}', style: TextStyle(color: Colors.white70)),
                        SizedBox(width: 20),
                        Text('Exp: ${_card!['expiry']}', style: TextStyle(color: Colors.white70)),
                      ]),
                    ],
                  ),
                ),
              )
            else
              Text('No card generated yet. Tap button below.'),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _generateCard,
                    icon: Icon(Icons.add_card),
                    label: Text('Generate New Card'),
                  ),
          ],
        ),
      ),
    );
  }
}
