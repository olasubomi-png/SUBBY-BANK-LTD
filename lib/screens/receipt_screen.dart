import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String senderPhone;
  final String receiverPhone;

  const ReceiptScreen({
    Key? key,
    required this.transaction,
    required this.senderPhone,
    required this.receiverPhone,
  }) : super(key: key);

  double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  DateTime _createdAt() {
    final parsed = DateTime.tryParse(transaction['created_at']?.toString() ?? '');
    return parsed ?? DateTime.now();
  }

  String _recipientName() {
    return (transaction['account_name'] ??
            transaction['accountName'] ??
            transaction['name'] ??
            transaction['full_name'] ??
            transaction['customer_name'] ??
            '')
        .toString();
  }

  Future<void> _downloadReceipt() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final amount = _asDouble(transaction['amount']);
    final status = transaction['status']?.toString() ?? 'pending';
    final bankName = transaction['bank_name']?.toString() ?? '';
    final recipientName = _recipientName();
    final accountNumber = transaction['account_number']?.toString() ?? '';

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('SUBBY Bank', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Transaction Receipt'),
            pw.SizedBox(height: 10),
            pw.Text('Date: ${dateFormat.format(_createdAt())}'),
            pw.Text('Status: $status'),
            if (bankName.isNotEmpty) pw.Text('Bank: $bankName'),
            if (accountNumber.isNotEmpty) pw.Text('Account number: $accountNumber'),
            if (recipientName.isNotEmpty) pw.Text('Recipient name: $recipientName'),
            pw.Divider(),
            pw.Text('Sender: $senderPhone'),
            pw.Text('Receiver: $receiverPhone'),
            pw.Text('Amount: ₦${amount.toStringAsFixed(2)}'),
            pw.Divider(),
            pw.Text('Thank you for using SUBBY Bank.'),
          ],
        ),
      ),
    );

    final bytes = await pdf.save();
    final tempFile = File('${Directory.systemTemp.path}/subby_bank_receipt.pdf');
    await tempFile.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles(
      [XFile(tempFile.path, mimeType: 'application/pdf')],
      text: 'Here is your receipt from SUBBY Bank.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final amount = _asDouble(transaction['amount']);
    final status = transaction['status']?.toString() ?? 'pending';
    final bankName = transaction['bank_name']?.toString() ?? '';
    final recipientName = _recipientName();
    final accountNumber = transaction['account_number']?.toString() ?? '';
    final isCredit = transaction['sender_phone']?.toString() != senderPhone;

    return Scaffold(
      appBar: AppBar(title: Text('Receipt')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SUBBY Bank', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
            SizedBox(height: 20),
            Text('Transaction Receipt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 10),
            _infoRow('Date', dateFormat.format(_createdAt())),
            _infoRow('Status', status.toUpperCase()),
            if (bankName.isNotEmpty) _infoRow('Bank', bankName),
            if (accountNumber.isNotEmpty) _infoRow('Account', accountNumber),
            if (recipientName.isNotEmpty) _infoRow('Recipient name', recipientName),
            Divider(color: Colors.white38),
            _infoRow('Sender', isCredit ? 'You' : transaction['sender_phone']?.toString() ?? ''),
            _infoRow('Receiver', isCredit ? transaction['receiver_phone']?.toString() ?? '' : 'You'),
            _infoRow('Amount', '₦${amount.toStringAsFixed(2)}', isBold: true),
            Divider(color: Colors.white38),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _downloadReceipt,
              icon: Icon(Icons.download),
              label: Text('Download / Share Receipt'),
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

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 16)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isBold ? Colors.cyanAccent : Colors.white,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
