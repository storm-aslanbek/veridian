import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:veridian/providers/localization_provider.dart';
import 'package:veridian/services/transaction_service.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionService = context.watch<TransactionService>();
    final localization = context.watch<LocalizationProvider>();
    final transactions = transactionService.transactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(localization.translate('title_history') ?? "История операций", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: transactions.isEmpty
          ? const Center(child: Text("История пуста"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, i) {
          final t = transactions[i];
          final isCredit = t.type == 'credit';

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              title: Text(t.recipient ?? t.category, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(DateFormat('dd MMM, HH:mm').format(t.transactionDate), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              trailing: Text(
                "${isCredit ? '+' : '-'} ${t.amount.abs().toStringAsFixed(0)} ₸",
                style: TextStyle(
                  color: isCredit ? Colors.green : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}