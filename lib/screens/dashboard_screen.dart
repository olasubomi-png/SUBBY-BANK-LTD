import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'card_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _balance = 0;
  List<dynamic> _history = [];
  bool _loading = true;
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

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
      setState(() {
        _balance = (balanceData['balance'] ?? 0).toDouble();
        _history = historyData;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load data')));
    }
  }

  Future<void> _sendMoney() async {
    final receiver = _receiverController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (receiver.isEmpty || amount == null || amount <= 0) return;
    final phone = Provider.of<AuthProvider>(context, listen: false).phone!;
    final api = ApiService();
    try {
      await api.transfer(phone, receiver, amount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('₦$amount sent to $receiver'), backgroundColor: Colors.green),
      );
      _receiverController.clear();
      _amountController.clear();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transfer failed'), backgroundColor: Colors.red));
    }
  }

  void _goToCard() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CardScreen()));
  }

  @override
  Widget build(BuildContext context) {
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
                            TextField(
                              controller: _receiverController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Receiver Phone',
                                labelStyle: TextStyle(color: Colors.white54),
                                prefixIcon: Icon(Icons.person, color: Colors.cyanAccent),
                                border: UnderlineInputBorder(),
                              ),
                            ),
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
                              onPressed: _sendMoney,
                              icon: Icon(Icons.send),
                              label: Text('Send Fake Transfer'),
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
                                    'Status: ${tx['status']}',
                                    style: TextStyle(color: Colors.white54, fontSize: 12),
                                  ),
                                  trailing: Text(
                                    '₦${amount.toStringAsFixed(2)}',
                                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                  ),
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
