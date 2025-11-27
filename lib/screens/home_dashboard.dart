import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veridian/providers/localization_provider.dart';
import 'package:veridian/providers/theme_provider.dart'; // Добавлен импорт темы
import 'package:veridian/screens/auth/login_screen.dart';
import 'package:veridian/screens/auth/register_screen.dart';
import 'package:veridian/screens/bill_payment_screen.dart';
import 'package:veridian/screens/card_management_screen.dart';
import 'package:veridian/screens/loan_screen.dart';
import 'package:veridian/screens/mobile_payment_screen.dart';
import 'package:veridian/screens/transactions_screen.dart';
import 'package:veridian/screens/transfer_screen.dart';
import 'package:veridian/services/account_service.dart';
import 'package:veridian/services/transaction_service.dart';
import 'package:veridian/services/user_service.dart';
import 'package:veridian/theme.dart';
import 'package:veridian/widgets/account_card.dart';
import 'package:veridian/widgets/balance_display.dart';
import 'package:veridian/widgets/quick_action_button.dart';
import 'package:veridian/widgets/transaction_tile.dart';

import '../services/localization_service.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final accountService = context.watch<AccountService>();
    final transactionService = context.watch<TransactionService>();
    final localization = context.watch<LocalizationProvider>();

    final user = userService.currentUser;
    final accounts = accountService.accounts;
    final totalBalance = accountService.totalBalance;
    final transactions = transactionService.transactions;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.horizontalLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 1. ШАПКА (С кнопкой настроек)
              if (!userService.isAuthenticated)
                _buildGuestHeader(context, localization)
              else
                _buildUserHeader(context, user?.firstName ?? 'User', localization),

              const SizedBox(height: 32),

              // 2. БАЛАНС
              if (userService.isAuthenticated)
                BalanceDisplay(balance: totalBalance),

              const SizedBox(height: 32),

              // 3. СЕРВИСЫ (Кнопки быстрого доступа)
              _buildQuickActions(context, localization, userService),

              const SizedBox(height: 32),

              // 4. СЧЕТА
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization.translate('my_accounts'),
                    style: context.textStyles.titleLarge?.semiBold,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!userService.isAuthenticated)
                _buildAuthPlaceholder(context, "Войдите для просмотра счетов")
              else if (accounts.isEmpty)
                const Center(child: Text("Нет счетов"))
              else
                ...accounts.take(2).map((account) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AccountCard(account: account),
                )),

              const SizedBox(height: 24),

              // 5. ИСТОРИЯ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization.translate('recent_transactions'),
                    style: context.textStyles.titleLarge?.semiBold,
                  ),
                  if (userService.isAuthenticated)
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
                      child: Text(localization.translate('see_all')),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (!userService.isAuthenticated)
                const SizedBox.shrink()
              else if (transactions.isEmpty)
                const Center(child: Text("Нет транзакций"))
              else
                ...transactions.take(5).map((transaction) => TransactionTile(transaction: transaction)),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, LocalizationProvider localization, UserService userService) {
    void handleAction(VoidCallback action) {
      if (userService.isAuthenticated) {
        action();
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          child: QuickActionButton(
            icon: Icons.send,
            label: localization.translate('transfer'),
            onTap: () => handleAction(() => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()))),
          ),
        ),
        Flexible(
          child: QuickActionButton(
            icon: Icons.receipt_long,
            label: localization.translate('bills'),
            onTap: () => handleAction(() => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillPaymentScreen()))),
          ),
        ),
        Flexible(
          child: QuickActionButton(
            icon: Icons.qr_code_scanner,
            label: localization.translate('scan'),
            onTap: () => handleAction(() => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobilePaymentScreen()))),
          ),
        ),
        Flexible(
          child: QuickActionButton(
            icon: Icons.credit_card,
            label: localization.translate('cards'),
            onTap: () => handleAction(() => Navigator.push(context, MaterialPageRoute(builder: (_) => const CardManagementScreen()))),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestHeader(BuildContext context, LocalizationProvider localization) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Добро пожаловать!',
            style: context.textStyles.headlineSmall?.bold.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Войдите в аккаунт или создайте новый.'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Вход'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: const Text('Регистрация'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === ЗАГОЛОВОК С КНОПКОЙ НАСТРОЕК ===
  Widget _buildUserHeader(BuildContext context, String userName, LocalizationProvider localization) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.translate('welcome_back'),
                style: context.textStyles.bodyLarge?.withColor(
                  Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                userName,
                style: context.textStyles.headlineSmall?.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Кнопка настроек (восстановлена)
        IconButton(
          onPressed: () => _showSettingsModal(context, localization),
          icon: const Icon(Icons.settings),
          iconSize: 28,
        ),
      ],
    );
  }

  Widget _buildAuthPlaceholder(BuildContext context, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(text, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }

  // === МОДАЛЬНОЕ ОКНО НАСТРОЕК ===
  void _showSettingsModal(BuildContext context, LocalizationProvider localization) {
    final themeProvider = context.read<ThemeProvider>();
    final userService = context.read<UserService>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.translate('settings'),
              style: context.textStyles.headlineSmall?.semiBold,
            ),
            const SizedBox(height: 24),

            Text(
              localization.translate('language'),
              style: context.textStyles.titleMedium?.semiBold,
            ),
            const SizedBox(height: 12),
            ..._buildLanguageOptions(context, localization),

            const SizedBox(height: 24),
            Text(
              localization.translate('theme'),
              style: context.textStyles.titleMedium?.semiBold,
            ),
            const SizedBox(height: 12),
            _buildThemeOptions(context, themeProvider, localization),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  userService.logout();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text("Выйти из аккаунта"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLanguageOptions(BuildContext context, LocalizationProvider localization) {
    final languages = [
      ('English', AppLanguage.en),
      ('Русский', AppLanguage.ru),
      ('Қазақша', AppLanguage.kk),
    ];

    return languages.map((lang) {
      final isSelected = localization.currentLanguage == lang.$2;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            localization.setLanguage(lang.$2);
            Navigator.pop(context);
          },
          child: Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang.$1,
                  style: context.textStyles.bodyLarge?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildThemeOptions(BuildContext context, ThemeProvider themeProvider, LocalizationProvider localization) {
    final themes = [
      (localization.translate('light'), ThemeMode.light),
      (localization.translate('dark'), ThemeMode.dark),
    ];

    return Column(
      children: themes.map((theme) {
        final isSelected = themeProvider.themeMode == theme.$2;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              themeProvider.setThemeMode(theme.$2);
              Navigator.pop(context);
            },
            child: Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).colorScheme.surface,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    theme.$1,
                    style: context.textStyles.bodyLarge?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}