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

  Future<Map<String, dynamic>> lookupAccount(String accountNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/lookup_account'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'account_number': accountNumber}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> transfer(
    String senderPhone,
    String receiverPhone,
    double amount,
    String bankName,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender_phone': senderPhone,
        'receiver_phone': receiverPhone,
        'amount': amount,
        'bank_name': bankName,
      }),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Transfer failed');
    }
    return body;
  }

  Future<List<dynamic>> getHistory(String phone) async {
    final response = await http.get(Uri.parse('$baseUrl/api/history?phone=$phone'));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch history');
    }
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
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch balance');
    }
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getDailyUsage(String phone) async {
    final response = await http.get(Uri.parse('$baseUrl/api/daily_usage?phone=$phone'));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch daily usage');
    }
    return jsonDecode(response.body);
  }
}
