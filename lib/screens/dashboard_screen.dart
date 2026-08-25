// Inside the ListView.builder for _history:
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
            senderPhone: tx['sender_phone'],
            receiverPhone: tx['receiver_phone'],
          ),
        ),
      );
    },
  ),
);
