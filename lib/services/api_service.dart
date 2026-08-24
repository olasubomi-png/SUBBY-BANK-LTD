import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://54.167.96.219:3001';

  Future<Map<String, dynamic>> register(String phone, String fcmToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'fcm_token': fcmToken}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> transfer(String senderPhone, String receiverPhone, double amount) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender_phone': senderPhone,
        'receiver_phone': receiverPhone,
        'amount': amount,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getHistory(String phone) async {
    final response = await http.get(Uri.parse('$baseUrl/api/history?phone=$phone'));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> generateCard(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/generate_card'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getBalance(String phone) async {
    final response = await http.get(Uri.parse('$baseUrl/api/balance?phone=$phone'));
    return jsonDecode(response.body);
  }
}
