import 'package:flutter/foundation.dart';
import 'package:veridian/models/bank_account.dart';
import 'package:veridian/services/api_client.dart';

class AccountService extends ChangeNotifier {
  List<BankAccount> _accounts = [];

  List<BankAccount> get accounts => _accounts;

  double get totalBalance => _accounts.fold(0.0, (sum, account) => sum + account.balance);

  Future<void> loadAccounts(String userId) async {
    try {

      final response = await ApiClient.get('/accounts');

      if (response is List) {
        _accounts = response
            .map((json) => BankAccount.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading accounts from API: $e');
      // Здесь можно оставить пустой список или показать ошибку UI
      _accounts = [];
      notifyListeners();
    }
  }

  // Обновление конкретного счета (например, после перевода)
  Future<void> refreshAccount(String accountId) async {
    try {
      final response = await ApiClient.get('/accounts/$accountId');
      final updatedAccount = BankAccount.fromJson(response);

      final index = _accounts.indexWhere((a) => a.id == accountId);
      if (index != -1) {
        _accounts[index] = updatedAccount;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing account: $e');
    }
  }
}