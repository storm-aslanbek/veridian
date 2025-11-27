import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:veridian/models/transaction.dart';
import 'package:veridian/theme.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '', decimalDigits: 2, locale: 'ru_RU');
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isDebit = transaction.type == 'debit';
    final sign = isDebit ? '-' : '+';
    final formattedAmount = "$sign${currencyFormat.format(transaction.amount.abs())} ₸";

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(_getCategoryIcon(), color: Theme.of(context).colorScheme.primary, size: 24),
      ),
      title: Text(
        transaction.recipient ?? transaction.category,
        style: context.textStyles.bodyLarge?.semiBold,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            transaction.category,
            style: context.textStyles.bodySmall?.withColor(
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            dateFormat.format(transaction.transactionDate),
            style: context.textStyles.labelSmall?.withColor(
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Text(
        formattedAmount,
        style: context.textStyles.titleMedium?.semiBold.withColor(
          isDebit ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (transaction.category.toLowerCase()) {
      case 'shopping':
        return Icons.shopping_bag;
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'utilities':
        return Icons.lightbulb;
      case 'entertainment':
        return Icons.movie;
      case 'salary':
        return Icons.account_balance_wallet;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}