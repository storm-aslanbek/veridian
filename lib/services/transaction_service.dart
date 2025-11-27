import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:veridian/models/transaction.dart';
import 'package:veridian/services/local_storage_service.dart';

class TransactionService extends ChangeNotifier {
  static const String _storageKey = 'transactions';
  final _uuid = const Uuid();
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions(String userId) async {
    try {
      final transactionsJson = LocalStorageService.getJsonList(_storageKey);

      if (transactionsJson == null || transactionsJson.isEmpty) {
        await _initializeSampleData(userId);
        return;
      }

      _transactions = transactionsJson
          .where((json) => json['userId'] == userId)
          .map((json) {
        try {
          return Transaction.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing transaction: $e');
          return null;
        }
      })
          .whereType<Transaction>()
          .toList();

      _transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      if (_transactions.isEmpty) {
        await _initializeSampleData(userId);
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      await _initializeSampleData(userId);
    }
  }

  Future<void> _initializeSampleData(String userId) async {
    try {
      final now = DateTime.now();
      final sampleTransactions = [
        Transaction(
          id: _uuid.v4(),
          userId: userId,
          accountId: 'sample-account-id',
          type: 'debit',
          category: 'Shopping',
          amount: 125.50,
          currency: 'USD',
          recipient: 'Amazon',
          description: 'Online shopping',
          status: 'completed',
          transactionDate: now.subtract(const Duration(hours: 2)),
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
        Transaction(
          id: _uuid.v4(),
          userId: userId,
          accountId: 'sample-account-id',
          type: 'debit',
          category: 'Food',
          amount: 45.80,
          currency: 'USD',
          recipient: 'Whole Foods',
          description: 'Groceries',
          status: 'completed',
          transactionDate: now.subtract(const Duration(days: 1)),
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        Transaction(
          id: _uuid.v4(),
          userId: userId,
          accountId: 'sample-account-id',
          type: 'credit',
          category: 'Salary',
          amount: 5500.00,
          currency: 'USD',
          recipient: 'Direct Deposit',
          description: 'Monthly salary',
          status: 'completed',
          transactionDate: now.subtract(const Duration(days: 2)),
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        Transaction(
          id: _uuid.v4(),
          userId: userId,
          accountId: 'sample-account-id',
          type: 'debit',
          category: 'Transport',
          amount: 65.00,
          currency: 'USD',
          recipient: 'Uber',
          description: 'Ride to airport',
          status: 'completed',
          transactionDate: now.subtract(const Duration(days: 3)),
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 3)),
        ),
        Transaction(
          id: _uuid.v4(),
          userId: userId,
          accountId: 'sample-account-id',
          type: 'debit',
          category: 'Utilities',
          amount: 120.00,
          currency: 'USD',
          recipient: 'Electric Company',
          description: 'Monthly electricity bill',
          status: 'completed',
          transactionDate: now.subtract(const Duration(days: 5)),
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
        Transaction(
          id: _uuid.v4(),
          userId: userId,
          accountId: 'sample-account-id',
          type: 'debit',
          category: 'Entertainment',
          amount: 35.99,
          currency: 'USD',
          recipient: 'Netflix',
          description: 'Monthly subscription',
          status: 'completed',
          transactionDate: now.subtract(const Duration(days: 7)),
          createdAt: now.subtract(const Duration(days: 7)),
          updatedAt: now.subtract(const Duration(days: 7)),
        ),
      ];

      final allTransactionsJson = LocalStorageService.getJsonList(_storageKey) ?? [];
      allTransactionsJson.addAll(sampleTransactions.map((t) => t.toJson()).toList());
      await LocalStorageService.saveJsonList(_storageKey, allTransactionsJson);
      _transactions = sampleTransactions;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing sample transactions: $e');
    }
  }

  Future<bool> addTransaction(Transaction transaction) async {
    try {
      final transactionsJson = LocalStorageService.getJsonList(_storageKey) ?? [];
      transactionsJson.add(transaction.toJson());
      await LocalStorageService.saveJsonList(_storageKey, transactionsJson);
      _transactions.insert(0, transaction);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      return false;
    }
  }

  List<Transaction> getTransactionsByAccount(String accountId) => _transactions.where((t) => t.accountId == accountId).toList();

  List<Transaction> getTransactionsByCategory(String category) => _transactions.where((t) => t.category == category).toList();

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) => _transactions.where((t) => t.transactionDate.isAfter(start) && t.transactionDate.isBefore(end)).toList();

  Map<String, double> getCategorySpending() {
    final Map<String, double> categoryTotals = {};
    for (var transaction in _transactions) {
      if (transaction.type == 'debit') {
        categoryTotals[transaction.category] = (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return categoryTotals;
  }
}
