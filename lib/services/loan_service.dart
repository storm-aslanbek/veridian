import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:veridian/models/loan.dart';
import 'package:veridian/services/local_storage_service.dart';

class LoanService extends ChangeNotifier {
  static const String _storageKey = 'loans';
  final _uuid = const Uuid();
  List<Loan> _loans = [];

  List<Loan> get loans => _loans;
  List<Loan> get activeLoans => _loans.where((l) => l.status == 'active').toList();

  Future<void> loadLoans(String userId) async {
    try {
      final loansJson = LocalStorageService.getJsonList(_storageKey);

      if (loansJson == null || loansJson.isEmpty) {
        await _initializeSampleData(userId);
        return;
      }

      _loans = loansJson
          .where((json) => json['userId'] == userId)
          .map((json) {
        try {
          return Loan.fromJson(json);
        } catch (e) {
          debugPrint('Error parsing loan: $e');
          return null;
        }
      })
          .whereType<Loan>()
          .toList();

      if (_loans.isEmpty) {
        await _initializeSampleData(userId);
      } else {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading loans: $e');
      await _initializeSampleData(userId);
    }
  }

  Future<void> _initializeSampleData(String userId) async {
    try {
      final now = DateTime.now();
      final sampleLoans = [
        Loan(
          id: _uuid.v4(),
          userId: userId,
          loanType: 'Personal Loan',
          principalAmount: 15000.00,
          interestRate: 5.5,
          termMonths: 36,
          monthlyPayment: 453.00,
          totalPaid: 5436.00,
          remainingAmount: 10890.00,
          status: 'active',
          startDate: now.subtract(const Duration(days: 365)),
          endDate: now.add(const Duration(days: 730)),
          nextPaymentDate: DateTime(now.year, now.month + 1, 1),
          createdAt: now.subtract(const Duration(days: 365)),
          updatedAt: now,
        ),
        Loan(
          id: _uuid.v4(),
          userId: userId,
          loanType: 'Auto Loan',
          principalAmount: 28000.00,
          interestRate: 3.9,
          termMonths: 60,
          monthlyPayment: 514.00,
          totalPaid: 12336.00,
          remainingAmount: 18480.00,
          status: 'active',
          startDate: now.subtract(const Duration(days: 730)),
          endDate: now.add(const Duration(days: 1095)),
          nextPaymentDate: DateTime(now.year, now.month + 1, 1),
          createdAt: now.subtract(const Duration(days: 730)),
          updatedAt: now,
        ),
      ];

      final allLoansJson = LocalStorageService.getJsonList(_storageKey) ?? [];
      allLoansJson.addAll(sampleLoans.map((l) => l.toJson()).toList());
      await LocalStorageService.saveJsonList(_storageKey, allLoansJson);
      _loans = sampleLoans;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing sample loans: $e');
    }
  }

  Future<bool> applyForLoan(Loan loan) async {
    try {
      final loansJson = LocalStorageService.getJsonList(_storageKey) ?? [];
      loansJson.add(loan.toJson());
      await LocalStorageService.saveJsonList(_storageKey, loansJson);
      _loans.add(loan);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error applying for loan: $e');
      return false;
    }
  }

  Future<bool> makePayment(String loanId, double amount) async {
    try {
      final loan = _loans.firstWhere((l) => l.id == loanId);
      final updatedLoan = loan.copyWith(
        totalPaid: loan.totalPaid + amount,
        remainingAmount: loan.remainingAmount - amount,
        nextPaymentDate: loan.nextPaymentDate?.add(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
      return await updateLoan(updatedLoan);
    } catch (e) {
      debugPrint('Error making payment: $e');
      return false;
    }
  }

  Future<bool> updateLoan(Loan loan) async {
    try {
      final loansJson = LocalStorageService.getJsonList(_storageKey) ?? [];
      final index = loansJson.indexWhere((json) => json['id'] == loan.id);

      if (index != -1) {
        loansJson[index] = loan.toJson();
        await LocalStorageService.saveJsonList(_storageKey, loansJson);

        final localIndex = _loans.indexWhere((l) => l.id == loan.id);
        if (localIndex != -1) {
          _loans[localIndex] = loan;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating loan: $e');
      return false;
    }
  }
}
