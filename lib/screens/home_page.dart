import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veridian/screens/auth/login_screen.dart';
import 'package:veridian/screens/auth/register_screen.dart';
import 'package:veridian/services/account_service.dart';
import 'package:veridian/services/local_storage_service.dart';
import 'package:veridian/services/transaction_service.dart';
import 'package:veridian/services/user_service.dart';
import 'package:veridian/theme.dart';
import 'package:veridian/widgets/account_card.dart';
import 'package:veridian/widgets/balance_display.dart';
import 'package:veridian/widgets/quick_action_button.dart';
import 'package:veridian/widgets/transaction_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userService = context.watch<UserService>();
    final accountService = context.watch<AccountService>();
    final transactionService = context.watch<TransactionService>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.read<UserService>().logout();
          await LocalStorageService.clear();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ВСЕ ДАННЫЕ СБРОШЕНЫ!'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        label: const Text("СБРОСИТЬ ВСЁ"),
        icon: const Icon(Icons.delete_forever),
        backgroundColor: Colors.red,
      ),

      body: _selectedIndex == 0
          ? _buildHomeContent(
        context,
        userService,
        accountService.totalBalance,
        accountService.accounts,
        transactionService.transactions,
      )
          : _buildPlaceholder('Coming Soon'),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHomeContent(
      BuildContext context,
      UserService userService,
      double totalBalance,
      List accounts,
      List transactions,
      ) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.horizontalLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              _buildHeader(context, userService),
              // ============

              const SizedBox(height: 32),

              BalanceDisplay(balance: totalBalance),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  QuickActionButton(
                    icon: Icons.send,
                    label: 'Transfer',
                    onTap: () => _requireAuth(context, userService, '/transfer'),
                  ),
                  QuickActionButton(
                    icon: Icons.receipt_long,
                    label: 'Bills',
                    onTap: () => _requireAuth(context, userService, '/bills'),
                  ),
                  QuickActionButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan',
                    onTap: () => _requireAuth(context, userService, '/mobile-payment'),
                  ),
                  QuickActionButton(
                    icon: Icons.credit_card,
                    label: 'Cards',
                    onTap: () => _requireAuth(context, userService, '/cards'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Мои счета', style: context.textStyles.titleLarge?.semiBold),
                ],
              ),
              const SizedBox(height: 16),

              if (!userService.isAuthenticated)
                _buildAuthPlaceholder(context)
              else if (accounts.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Счета не найдены"),
                ))
              else
                ...accounts.take(2).map((account) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AccountCard(account: account),
                )),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('История', style: context.textStyles.titleLarge?.semiBold),
                  if (userService.isAuthenticated)
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/transactions'),
                      child: const Text('Все'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (!userService.isAuthenticated)
                const SizedBox.shrink()
              else if (transactions.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Нет операций"),
                ))
              else
                ...transactions.take(5).map((transaction) => TransactionTile(transaction: transaction)),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserService userService) {
    if (!userService.isAuthenticated) {
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
            Text(
              'Войдите в аккаунт или создайте новый.',
              style: context.textStyles.bodyMedium?.withColor(
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Вход'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Регистрация'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // 2. ПОЛЬЗОВАТЕЛЬ
      final user = userService.currentUser!;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'С возвращением,',
                  style: context.textStyles.bodyLarge?.withColor(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: context.textStyles.headlineSmall?.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showLogoutDialog(context),
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Выйти",
          ),
        ],
      );
    }
  }

  Widget _buildAuthPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2), style: BorderStyle.none),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            "Данные скрыты",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text("Авторизуйтесь для просмотра", style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _requireAuth(BuildContext context, UserService userService, String route) {
    if (userService.isAuthenticated) {
      Navigator.pushNamed(context, route);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Выйти из аккаунта?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Нет')),
          TextButton(
            onPressed: () {
              context.read<UserService>().logout();
              Navigator.pop(context);
            },
            child: const Text('Да', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String text) => Center(child: Text(text));

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppSpacing.verticalSm,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, 'Home', 0, null),
              _buildNavItem(context, Icons.swap_horiz, 'Transfer', 1, '/transfer'),
              _buildNavItem(context, Icons.account_balance, 'Loans', 2, '/loans'),
              _buildNavItem(context, Icons.history, 'History', 3, '/transactions'),
              _buildNavItem(context, Icons.credit_card, 'Cards', 4, '/cards'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, String? route) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
        else setState(() => _selectedIndex = index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
            Text(label, style: TextStyle(color: isSelected ? Theme.of(context).primaryColor : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}