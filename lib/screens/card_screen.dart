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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate card')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0B1A2D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Virtual Card', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_card != null)
              Card(
                color: Color(0xFF1A2F4A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mastercard', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          Icon(Icons.credit_card, color: Colors.cyanAccent, size: 40),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        '**** **** **** ${_card!['card_number'].toString().substring(12)}',
                        style: TextStyle(fontSize: 24, letterSpacing: 2, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text('CVV: ${_card!['cvv']}', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          SizedBox(width: 24),
                          Text('Exp: ${_card!['expiry']}', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('No card generated yet.', style: TextStyle(color: Colors.white38)),
              ),
            SizedBox(height: 30),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _generateCard,
                    icon: Icon(Icons.add_card),
                    label: Text('Generate New Card'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
