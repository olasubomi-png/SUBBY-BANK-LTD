import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B1A2D), Color(0xFF1A2F4A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 80,
                  color: Colors.cyanAccent[200],
                ),
                SizedBox(height: 16),
                Text(
                  'SUBBY Bank',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Secure • Instant • Reliable',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 48),
                TextField(
                  controller: _phoneController,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter Phone Number',
                    hintStyle: TextStyle(color: Colors.white38),
                    prefixIcon: Icon(Icons.phone_android, color: Colors.cyanAccent),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.cyanAccent, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                _loading
                    ? CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                          child: Text(
                            'Login / Register',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 24),
                Text(
                  'By continuing you agree to our Terms & Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a phone number'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final api = ApiService();
      await api.register(phone, 'dummy_fcm');
      await Provider.of<AuthProvider>(context, listen: false).login(phone);
      Navigator.pushReplacementNamed(context, '/dashboard');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
}
