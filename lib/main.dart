import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseMessaging.instance.getToken(); // request permission
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'SUBBY Bank',
        theme: ThemeData.dark(),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/dashboard': (context) => DashboardScreen(),
        },
      ),
    );
  }
}
