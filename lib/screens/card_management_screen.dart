import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:veridian/providers/localization_provider.dart';
import 'package:veridian/services/card_service.dart';
import 'package:veridian/theme.dart';
import 'package:veridian/widgets/action_button.dart';
import 'package:veridian/widgets/bank_card_widget.dart';

class CardManagementScreen extends StatelessWidget {
  const CardManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardService = context.watch<CardService>();
    final localization = context.watch<LocalizationProvider>();
    final cards = cardService.cards;

    return Scaffold(
      appBar: AppBar(title: Text(localization.translate('my_cards'))),
      body: SafeArea(
        child: cards.isEmpty
            ? Center(
          child: Text(
            localization.translate('no_cards'),
            style: context.textStyles.bodyLarge?.withColor(
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        )
            : ListView.builder(
          padding: AppSpacing.paddingLg,
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  BankCardWidget(
                    card: card,
                    onTap: () => _showCardDetails(context, card),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          label: card.isBlocked ? localization.translate('unblock') : localization.translate('block'),
                          onPressed: () => _toggleCardBlock(context, card.id, localization),
                          icon: card.isBlocked ? Icons.lock_open : Icons.lock,
                          isPrimary: false,
                          isFullWidth: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ActionButton(
                          label: localization.translate('settings'),
                          onPressed: () => _showCardSettings(context, card),
                          icon: Icons.settings,
                          isPrimary: false,
                          isFullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _toggleCardBlock(BuildContext context, String cardId, LocalizationProvider localization) {
    context.read<CardService>().toggleCardBlock(cardId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localization.translate('cards'))),
    );
  }

  void _showCardDetails(BuildContext context, dynamic card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Card Details',
              style: context.textStyles.titleLarge?.bold,
            ),
            const SizedBox(height: 24),
            _buildDetailRow(context, 'Card Number', card.cardNumber),
            _buildDetailRow(context, 'Card Holder', card.cardHolderName),
            _buildDetailRow(context, 'Expiry Date', card.expiryDate),
            _buildDetailRow(context, 'CVV', card.cvv),
            _buildDetailRow(context, 'Type', card.cardType),
            _buildDetailRow(context, 'Spending Limit', '\$${NumberFormat('#,##0.00').format(card.spendingLimit)}'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCardSettings(BuildContext context, dynamic card) {
    final limitController = TextEditingController(text: card.spendingLimit.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Card Settings',
              style: context.textStyles.titleLarge?.bold,
            ),
            const SizedBox(height: 24),
            Text(
              'Spending Limit',
              style: context.textStyles.titleMedium?.semiBold,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ActionButton(
              label: 'Update Limit',
              onPressed: () {
                final newLimit = double.tryParse(limitController.text);
                if (newLimit != null) {
                  context.read<CardService>().updateSpendingLimit(card.id, newLimit);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Spending limit updated')),
                  );
                }
              },
              icon: Icons.check,
              isFullWidth: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.textStyles.bodyMedium?.withColor(
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: context.textStyles.bodyMedium?.semiBold,
          ),
        ],
      ),
    );
  }
}
