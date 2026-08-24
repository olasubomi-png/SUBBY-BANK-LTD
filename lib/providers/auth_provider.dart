import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _phone;
  String? _fcmToken;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get phone => _phone;

  Future<void> login(String phone) async {
    _phone = phone;
    _fcmToken = 'dummy_fcm';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
    await prefs.setString('fcmToken', _fcmToken!);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('phone');
    await prefs.remove('fcmToken');
    _isLoggedIn = false;
    _phone = null;
    notifyListeners();
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _phone = prefs.getString('phone');
    _fcmToken = prefs.getString('fcmToken');
    if (_phone != null) _isLoggedIn = true;
    notifyListeners();
  }
}
