import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veridian/providers/localization_provider.dart';
import 'package:veridian/providers/theme_provider.dart';
import 'package:veridian/screens/app_wrapper.dart';
import 'package:veridian/services/account_service.dart';
import 'package:veridian/services/bill_service.dart';
import 'package:veridian/services/card_service.dart';
import 'package:veridian/services/loan_service.dart';
import 'package:veridian/services/local_storage_service.dart';
import 'package:veridian/services/transaction_service.dart';
import 'package:veridian/services/transfer_service.dart';
import 'package:veridian/services/user_service.dart';
import 'package:veridian/theme.dart';
import 'package:veridian/services/support_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalStorageService.init();
  final themeProvider = ThemeProvider();
  await themeProvider.init();
  final localizationProvider = LocalizationProvider();
  await localizationProvider.init();

  runApp(MyApp(
    themeProvider: themeProvider,
    localizationProvider: localizationProvider,
  ));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LocalizationProvider localizationProvider;

  const MyApp({
    super.key,
    required this.themeProvider,
    required this.localizationProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localizationProvider),

        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => AccountService()),
        ChangeNotifierProvider(create: (_) => CardService()),
        ChangeNotifierProvider(create: (_) => TransactionService()),
        ChangeNotifierProvider(create: (_) => BillService()),
        ChangeNotifierProvider(create: (_) => LoanService()),
        ChangeNotifierProvider(create: (_) => TransferService()),
        ChangeNotifierProvider(create: (_) => SupportService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'Veridian Banking',
          debugShowCheckedModeBanner: false,

          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,

          home: const AppInitializer(),
        ),
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final userService = context.read<UserService>();

    await userService.loadCurrentUser();

    if (userService.currentUser != null) {
      final userId = userService.currentUser!.id;

      await Future.wait([
        context.read<AccountService>().loadAccounts(userId),
        context.read<CardService>().loadCards(userId),
        context.read<TransactionService>().loadTransactions(userId),
        context.read<BillService>().loadBills(userId),
        context.read<LoanService>().loadLoans(userId),
        context.read<TransferService>().loadRecipients(userId),
      ]);
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return const AppWrapper();
  }
}