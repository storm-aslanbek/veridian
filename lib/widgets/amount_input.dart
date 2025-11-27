import 'package:flutter/material.dart';
import 'package:veridian/theme.dart';

class AmountInput extends StatelessWidget {
  final TextEditingController controller;
  final String currencySymbol;

  const AmountInput({
    super.key,
    required this.controller,
    this.currencySymbol = '₸', // По умолчанию тенге
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: context.textStyles.headlineMedium?.bold,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            currencySymbol,
            style: context.textStyles.headlineMedium?.bold.withColor(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}