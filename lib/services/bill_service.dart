import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:veridian/models/bill.dart';
import 'package:veridian/services/local_storage_service.dart';

class BillService extends ChangeNotifier {
  static const String _storageKey = 'bills';
  final _uuid = const Uuid();
  List<Bill> _bills = [];

  List<Bill> get bills => _bills;
  List<Bill> get upcomingBills => _bills.where((b) => !b.isPaid && b.dueDate.isAfter(DateTime.now())).toList();
  List<Bill> get overdueBills => _bills.where((b) => !b.isPaid && b.dueDate.isBefore(DateTime.now())).toList();

  Future<void> loadBills(String userId) async {
    try {
      final billsJson = LocalStorageService.getJsonList(_storageKey);

      if (billsJson == null || billsJson.isEmpty) {
        await _initializeSampleData(userId);
        return;
      }

      _bills = billsJson
          .where((json) => json['userId'] == userId)
          .map((json) {
        try {
          return Bill.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing bill: $e');
          return null;
        }
      })
          .whereType<Bill>()
          .toList();

      if (_bills.isEmpty) {
        await _initializeSampleData(userId);
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading bills: $e');
      await _initializeSampleData(userId);
    }
  }

  Future<void> _initializeSampleData(String userId) async {
    try {
      final now = DateTime.now();
      final sampleBills = [
        Bill(
          id: _uuid.v4(),
          userId: userId,
          billType: 'Electricity',
          provider: 'Power Company',
          accountNumber: 'PWR-123456',
          amount: 120.00,
          currency: 'USD',
          dueDate: DateTime(now.year, now.month, 15),
          isRecurring: true,
          createdAt: now.subtract(const Duration(days: 365)),
          updatedAt: now,
        ),
        Bill(
          id: _uuid.v4(),
          userId: userId,
          billType: 'Water',
          provider: 'Water Utilities',
          accountNumber: 'WTR-789012',
          amount: 45.50,
          currency: 'USD',
          dueDate: DateTime(now.year, now.month, 20),
          isRecurring: true,
          createdAt: now.subtract(const Duration(days: 365)),
          updatedAt: now,
        ),
        Bill(
          id: _uuid.v4(),
          userId: userId,
          billType: 'Internet',
          provider: 'ISP Provider',
          accountNumber: 'ISP-345678',
          amount: 79.99,
          currency: 'USD',
          dueDate: DateTime(now.year, now.month, 25),
          isRecurring: true,
          createdAt: now.subtract(const Duration(days: 365)),
          updatedAt: now,
        ),
        Bill(
          id: _uuid.v4(),
          userId: userId,
          billType: 'Gas',
          provider: 'Gas Company',
          accountNumber: 'GAS-567890',
          amount: 65.00,
          currency: 'USD',
          dueDate: DateTime(now.year, now.month, 10),
          isRecurring: true,
          createdAt: now.subtract(const Duration(days: 365)),
          updatedAt: now,
        ),
      ];

      final allBillsJson = LocalStorageService.getJsonList(_storageKey) ?? [];
      allBillsJson.addAll(sampleBills.map((b) => b.toJson()).toList());
      await LocalStorageService.saveJsonList(_storageKey, allBillsJson);
      _bills = sampleBills;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing sample bills: $e');
    }
  }

  Future<bool> payBill(String billId) async {
    try {
      final bill = _bills.firstWhere((b) => b.id == billId);
      final updatedBill = bill.copyWith(isPaid: true, updatedAt: DateTime.now());
      return await updateBill(updatedBill);
    } catch (e) {
      debugPrint('Error paying bill: $e');
      return false;
    }
  }

  Future<bool> updateBill(Bill bill) async {
    try {
      final billsJson = LocalStorageService.getJsonList(_storageKey) ?? [];
      final index = billsJson.indexWhere((json) => json['id'] == bill.id);

      if (index != -1) {
        billsJson[index] = bill.toJson();
        await LocalStorageService.saveJsonList(_storageKey, billsJson);

        final localIndex = _bills.indexWhere((b) => b.id == bill.id);
        if (localIndex != -1) {
          _bills[localIndex] = bill;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating bill: $e');
      return false;
    }
  }

  Future<bool> addBill(Bill bill) async {
    try {
      final billsJson = LocalStorageService.getJsonList(_storageKey) ?? [];
      billsJson.add(bill.toJson());
      await LocalStorageService.saveJsonList(_storageKey, billsJson);
      _bills.add(bill);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding bill: $e');
      return false;
    }
  }
}
