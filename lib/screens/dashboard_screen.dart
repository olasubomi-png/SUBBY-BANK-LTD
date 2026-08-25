import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'card_screen.dart';
import 'payment_screen.dart'; // optional
import 'receipt_screen.dart';

const List<String> nigerianBanks = [
  'Access Bank',
  'First Bank',
  'GTBank',
  'UBA',
  'Zenith Bank',
  'Opay',
  'PalmPay',
  'Kuda Bank',
  'Moniepoint',
  'Stanbic IBTC',
  'Fidelity Bank',
  'Union Bank',
  'Wema Bank',
  'Sterling Bank',
  'Jaiz Bank',
  'Providus Bank',
  'Titan Trust Bank',
  'Parallex Bank',
];

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _balance = 0;
  double _dailyUsed = 0;
  double _dailyLimit = 500000;
  List<dynamic> _history = [];
  bool _loading = true;
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String _selectedBank = nigerianBanks.first;
  Map<String, dynamic>? _lookupResult;
  bool _isLookingUp = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final phone = Provider.of<AuthProvider>(context, listen: false).phone!;
    final api = ApiService();
    try {
      final balanceData = await api.getBalance(phone);
      final historyData = await api.getHistory(phone);
      final dailyData = await api.getDailyUsage(phone);
      setState(() {
        _balance = (balanceData['balance'] ?? 0).toDouble();
        _history = historyData;
        _dailyUsed = (dailyData['used'] ?? 0).toDouble();
        _dailyLimit = (dailyData['limit'] ?? 500000).toDouble();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load data: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _lookupAccount() async {
    final account = _accountController.text.trim();
    if (account.isEmpty) return;
    setState(() => _isLookingUp = true);
    final api = ApiService();
    try {
      final result = await api.lookupAccount(account);
      setState(() {
        _lookupResult = result;
        _isLookingUp = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account found: ${result['phone']}'), backgroundColor: Colors.green));
    } catch (e) {
      setState(() => _isLookingUp = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account not found'), backgroundColor: Colors.red));
    }
  }

  Future<void> _sendMoney() async {
    if (_lookupResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please lookup account first'), backgroundColor: Colors.orange));
      return;
    }
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    final phone = Provider.of<AuthProvider>(context, listen: false).phone!;
    final api = ApiService();
    try {
      await api.transfer(phone, _lookupResult!['phone'], amount, _selectedBank);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('₦$amount sent to ${_lookupResult!['phone']} ($_selectedBank)'), backgroundColor: Colors.green));
      _accountController.clear();
      _amountController.clear();
      setState(() => _lookupResult = null);
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transfer failed: $e'), backgroundColor: Colors.red));
    }
  }

  void _goToCard() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CardScreen()));
  }

  void _goToPayment() {
    // Optionally navigate to payment screen – we'll add a button in app bar or card screen
  }

  @override
  Widget build(BuildContext context) {
    final remainingDaily = _dailyLimit - _dailyUsed;
    return Scaffold(
      backgroundColor: Color(0xFF0B1A2D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('SUBBY Bank', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.card_membership, color: Colors.white), onPressed: _goToCard),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.cyanAccent,
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 20, offset: Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Balance', style: TextStyle(fontSize: 16, color: Colors.black45)),
                          SizedBox(height: 8),
                          Text(
                            '₦${_balance.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Resets daily', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                  Text('to ₦500,000', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Daily Transfer Limit', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                  Text('₦${remainingDaily.toStringAsFixed(0)} remaining', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: remainingDaily < 50000 ? Colors.red : Colors.black)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _dailyUsed / _dailyLimit,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(remainingDaily < 50000 ? Colors.red : Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),

                    // Send Money Section
                    Text('Send Money', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 12),
                    Card(
                      color: Colors.white.withOpacity(0.06),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedBank,
                              dropdownColor: Color(0xFF1A2F4A),
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Select Bank',
                                labelStyle: TextStyle(color: Colors.white54),
                                prefixIcon: Icon(Icons.account_balance, color: Colors.cyanAccent),
                                border: UnderlineInputBorder(),
                              ),
                              items: nigerianBanks.map((bank) {
                                return DropdownMenuItem<String>(
                                  value: bank,
                                  child: Text(bank, style: TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) setState(() => _selectedBank = value);
                              },
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _accountController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Account Number',
                                      labelStyle: TextStyle(color: Colors.white54),
                                      prefixIcon: Icon(Icons.person, color: Colors.cyanAccent),
                                      border: UnderlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: _isLookingUp ? CircularProgressIndicator() : Icon(Icons.search, color: Colors.cyanAccent),
                                  onPressed: _isLookingUp ? null : _lookupAccount,
                                ),
                              ],
                            ),
                            if (_lookupResult != null) ...[
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Sending to: ${_lookupResult!['phone']} ($_selectedBank)',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(height: 12),
                            TextField(
                              controller: _amountController,
                              style: TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Amount (₦)',
                                labelStyle: TextStyle(color: Colors.white54),
                                prefixIcon: Icon(Icons.money, color: Colors.cyanAccent),
                                border: UnderlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _lookupResult == null ? null : _sendMoney,
                              icon: Icon(Icons.send),
                              label: Text('Send Fake Transfer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _lookupResult == null ? Colors.grey : Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Transaction History
                    Text('Transaction History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 8),
                    _history.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text('No transactions yet.', style: TextStyle(color: Colors.white38)),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final tx = _history[index];
                              final isCredit = tx['sender_phone'] != Provider.of<AuthProvider>(context, listen: false).phone;
                              final color = isCredit ? Colors.green : Colors.red;
                              final amount = (tx['amount'] ?? 0).toDouble();
                              final bankName = tx['bank_name'] ?? '';
                              return Card(
                                color: Colors.white.withOpacity(0.04),
                                margin: EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: Icon(
                                    isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                    color: color,
                                  ),
                                  title: Text(
                                    isCredit ? 'From ${tx['sender_phone']}' : 'To ${tx['receiver_phone']}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    '${tx['status']}${bankName.isNotEmpty ? ' · $bankName' : ''}',
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  trailing: Text(
                                    '₦${amount.toStringAsFixed(2)}',
                                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                  ),
                                  onTap: () {
                                    final phone = Provider.of<AuthProvider>(context, listen: false).phone!;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReceiptScreen(
                                          transaction: tx,
                                          senderPhone: phone,
                                          receiverPhone: tx['receiver_phone'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}
