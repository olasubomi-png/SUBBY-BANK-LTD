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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transfer sent: ₦$amount')));
      _receiverController.clear();
      _amountController.clear();
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transfer failed: $e')));
    }
  }

  void _goToCard() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SUBBY Bank'),
        actions: [
          IconButton(
            icon: Icon(Icons.card_membership),
            onPressed: _goToCard,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.green[900],
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text('Balance', style: TextStyle(fontSize: 16, color: Colors.white70)),
                            SizedBox(height: 4),
                            Text('₦${_balance.toStringAsFixed(2)}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Send Money', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: _receiverController,
                      decoration: InputDecoration(labelText: 'Receiver Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: _amountController,
                      decoration: InputDecoration(labelText: 'Amount (₦)'),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _sendMoney,
                      icon: Icon(Icons.send),
                      label: Text('Send Fake Transfer'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _history.isEmpty
                        ? Text('No transactions yet.')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final tx = _history[index];
                              final isCredit = tx['sender_phone'] != Provider.of<AuthProvider>(context, listen: false).phone;
                              final color = isCredit ? Colors.green : Colors.red;
                              final amount = (tx['amount'] ?? 0).toDouble();
                              return ListTile(
                                leading: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: color),
                                title: Text(isCredit ? 'From ${tx['sender_phone']}' : 'To ${tx['receiver_phone']}'),
                                subtitle: Text('Status: ${tx['status']}'),
                                trailing: Text('₦${amount.toStringAsFixed(2)}', style: TextStyle(color: color)),
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
