import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:veridian/providers/localization_provider.dart';
import 'package:veridian/services/loan_service.dart';
import 'package:veridian/theme.dart';
import 'package:veridian/widgets/action_button.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loanService = context.watch<LoanService>();
    final localization = context.watch<LocalizationProvider>();
    final activeLoans = loanService.activeLoans;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(title: Text(localization.translate('loans'))),
      body: SafeArea(
        child: activeLoans.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              Text(
                localization.translate('no_active_loans'),
                style: context.textStyles.titleLarge?.semiBold,
              ),
              const SizedBox(height: 8),
              Text(
                localization.translate('apply_for_new_loan'),
                style: context.textStyles.bodyMedium?.withColor(
                  Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: ActionButton(
                  label: localization.translate('apply_for_loan'),
                  onPressed: () {},
                  icon: Icons.add,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: AppSpacing.paddingLg,
          itemCount: activeLoans.length,
          itemBuilder: (context, index) {
            final loan = activeLoans[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loan.loanType,
                                style: context.textStyles.titleMedium?.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                loan.status.toUpperCase(),
                                style: context.textStyles.labelSmall?.withColor(
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormat.format(loan.principalAmount),
                          style: context.textStyles.titleMedium?.bold.withColor(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoColumn(
                            context,
                            'Monthly Payment',
                            currencyFormat.format(loan.monthlyPayment),
                          ),
                        ),
                        Expanded(
                          child: _buildInfoColumn(
                            context,
                            'Interest Rate',
                            '${loan.interestRate.toStringAsFixed(1)}%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoColumn(
                            context,
                            'Total Paid',
                            currencyFormat.format(loan.totalPaid),
                          ),
                        ),
                        Expanded(
                          child: _buildInfoColumn(
                            context,
                            'Remaining',
                            currencyFormat.format(loan.remainingAmount),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Progress',
                      style: context.textStyles.labelSmall?.withColor(
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: loan.progressPercentage / 100,
                        minHeight: 8,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${loan.progressPercentage.toStringAsFixed(1)}% Complete',
                      style: context.textStyles.labelSmall?.withColor(
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (loan.nextPaymentDate != null)
                      Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Next Payment: ${dateFormat.format(loan.nextPaymentDate!)}',
                              style: context.textStyles.bodyMedium?.semiBold.withColor(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    ActionButton(
                      label: 'Make Payment',
                      onPressed: () => _makePayment(context, loan.id, loan.monthlyPayment),
                      icon: Icons.payment,
                      isFullWidth: true,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Loan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyles.labelSmall?.withColor(
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textStyles.bodyLarge?.semiBold,
        ),
      ],
    );
  }

  void _makePayment(BuildContext context, String loanId, double amount) {
    context.read<LoanService>().makePayment(loanId, amount);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment successful!'), backgroundColor: Color(0xFF10B981)),
    );
  }
}
