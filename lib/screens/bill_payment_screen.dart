import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:veridian/providers/localization_provider.dart';
import 'package:veridian/services/bill_service.dart';
import 'package:veridian/theme.dart';
import 'package:veridian/widgets/action_button.dart';
import 'package:veridian/widgets/category_icon.dart';

class BillPaymentScreen extends StatelessWidget {
  const BillPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final billService = context.watch<BillService>();
    final localization = context.watch<LocalizationProvider>();
    final upcomingBills = billService.upcomingBills;
    final overdueBills = billService.overdueBills;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(title: Text(localization.translate('bill_payments'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickPayCard(
                      context,
                      icon: Icons.flash_on,
                      title: localization.translate('electricity'),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickPayCard(
                      context,
                      icon: Icons.water_drop,
                      title: localization.translate('water'),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickPayCard(
                      context,
                      icon: Icons.wifi,
                      title: localization.translate('internet'),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickPayCard(
                      context,
                      icon: Icons.phone_android,
                      title: localization.translate('phone'),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (overdueBills.isNotEmpty) ...[
                Text(
                  localization.translate('overdue_bills'),
                  style: context.textStyles.titleLarge?.semiBold.withColor(
                    Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                ...overdueBills.map((bill) => _buildBillCard(
                  context,
                  bill: bill,
                  isOverdue: true,
                  onPay: () => _payBill(context, bill.id, localization),
                  currencyFormat: currencyFormat,
                  dateFormat: dateFormat,
                  localization: localization,
                )),
                const SizedBox(height: 24),
              ],
              Text(
                localization.translate('upcoming_bills'),
                style: context.textStyles.titleLarge?.semiBold,
              ),
              const SizedBox(height: 16),
              if (upcomingBills.isEmpty)
                Center(
                  child: Padding(
                    padding: AppSpacing.verticalXl,
                    child: Text(
                      localization.translate('no_bills'),
                      style: context.textStyles.bodyLarge?.withColor(
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...upcomingBills.map((bill) => _buildBillCard(
                  context,
                  bill: bill,
                  isOverdue: false,
                  onPay: () => _payBill(context, bill.id, localization),
                  currencyFormat: currencyFormat,
                  dateFormat: dateFormat,
                  localization: localization,
                )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPayCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: context.textStyles.bodyMedium?.semiBold,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillCard(
      BuildContext context, {
        required dynamic bill,
        required bool isOverdue,
        required VoidCallback onPay,
        required NumberFormat currencyFormat,
        required DateFormat dateFormat,
        required LocalizationProvider localization,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CategoryIcon(
                    category: bill.billType,
                    color: isOverdue
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.provider,
                        style: context.textStyles.titleMedium?.semiBold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bill.billType,
                        style: context.textStyles.bodySmall?.withColor(
                          Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormat.format(bill.amount),
                  style: context.textStyles.titleMedium?.bold.withColor(
                    isOverdue ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.translate('due_date'),
                        style: context.textStyles.labelSmall?.withColor(
                          Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(bill.dueDate),
                        style: context.textStyles.bodyMedium?.semiBold,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.translate('from_account'),
                        style: context.textStyles.labelSmall?.withColor(
                          Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bill.accountNumber,
                        style: context.textStyles.bodyMedium?.semiBold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ActionButton(
              label: localization.translate('bills'),
              onPressed: onPay,
              icon: Icons.payment,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  void _payBill(BuildContext context, String billId, LocalizationProvider localization) {
    context.read<BillService>().payBill(billId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localization.translate('bills')), backgroundColor: const Color(0xFF10B981)),
    );
  }
}
