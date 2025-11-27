import 'package:flutter/material.dart';
import 'package:veridian/models/card.dart';
import 'package:veridian/theme.dart';

class BankCardWidget extends StatelessWidget {
  final BankCard card;
  final VoidCallback? onTap;

  const BankCardWidget({super.key, required this.card, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 340,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card.cardType.toLowerCase() == 'credit'
                ? [
              const Color(0xFF059669),
              const Color(0xFF047857),
            ]
                : [
              const Color(0xFF10B981),
              const Color(0xFF059669),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (card.isBlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white, size: 48),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.cardType,
                        style: context.textStyles.titleMedium?.semiBold.withColor(Colors.white),
                      ),
                      Icon(
                        card.cardType.toLowerCase() == 'credit'
                            ? Icons.credit_card
                            : Icons.payment,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 32,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    card.maskedCardNumber,
                    style: context.textStyles.titleLarge?.semiBold.withColor(Colors.white).copyWith(letterSpacing: 2),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CARD HOLDER',
                            style: context.textStyles.labelSmall?.withColor(
                              Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.cardHolderName,
                            style: context.textStyles.bodyMedium?.semiBold.withColor(Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EXPIRES',
                            style: context.textStyles.labelSmall?.withColor(
                              Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.expiryDate,
                            style: context.textStyles.bodyMedium?.semiBold.withColor(Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
