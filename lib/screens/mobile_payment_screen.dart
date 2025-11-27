import 'package:flutter/material.dart';
import 'package:veridian/theme.dart';
import 'package:veridian/widgets/action_button.dart';

class MobilePaymentScreen extends StatelessWidget {
  const MobilePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Payment')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              _buildPaymentOption(
                context,
                icon: Icons.qr_code_scanner,
                title: 'Scan QR Code',
                description: 'Scan a QR code to make payment',
                onTap: () => _showQRScanner(context),
              ),
              const SizedBox(height: 16),
              _buildPaymentOption(
                context,
                icon: Icons.nfc,
                title: 'NFC Payment',
                description: 'Tap your phone to pay',
                onTap: () => _showNFCPayment(context),
              ),
              const SizedBox(height: 16),
              _buildPaymentOption(
                context,
                icon: Icons.qr_code,
                title: 'Show My QR',
                description: 'Show your QR code to receive payment',
                onTap: () => _showMyQR(context),
              ),
              const SizedBox(height: 32),
              Text(
                'Quick Payments',
                style: context.textStyles.titleLarge?.semiBold,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    children: [
                      _buildQuickPaymentTile(
                        context,
                        icon: Icons.coffee,
                        name: 'Coffee Shop',
                        amount: '\$5.50',
                        onTap: () {},
                      ),
                      Divider(color: Theme.of(context).colorScheme.outline),
                      _buildQuickPaymentTile(
                        context,
                        icon: Icons.local_gas_station,
                        name: 'Gas Station',
                        amount: '\$45.00',
                        onTap: () {},
                      ),
                      Divider(color: Theme.of(context).colorScheme.outline),
                      _buildQuickPaymentTile(
                        context,
                        icon: Icons.restaurant,
                        name: 'Restaurant',
                        amount: '\$32.00',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required VoidCallback onTap,
      }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.titleMedium?.semiBold),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: context.textStyles.bodySmall?.withColor(
                        Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPaymentTile(
      BuildContext context, {
        required IconData icon,
        required String name,
        required String amount,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.verticalMd,
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, style: context.textStyles.bodyLarge?.semiBold),
            ),
            Text(
              amount,
              style: context.textStyles.titleMedium?.semiBold.withColor(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQRScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: AppSpacing.paddingLg,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Scan QR Code',
              style: context.textStyles.titleLarge?.bold,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 120,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Position QR code within the frame',
              style: context.textStyles.bodyMedium?.withColor(
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showNFCPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('NFC Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.nfc,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Hold your phone near the payment terminal to complete the transaction',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showMyQR(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'My QR Code',
              style: context.textStyles.titleLarge?.bold,
            ),
            const SizedBox(height: 32),
            Container(
              padding: AppSpacing.paddingXl,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.qr_code,
                size: 200,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Show this code to receive payment',
              style: context.textStyles.bodyMedium?.withColor(
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
