import 'package:flutter/foundation.dart';
import 'package:veridian/models/transfer_recipient.dart';
import 'package:veridian/services/api_client.dart';

class TransferService extends ChangeNotifier {
  List<TransferRecipient> _recipients = [];

  List<TransferRecipient> get recipients => _recipients;

  Future<void> loadRecipients(String userId) async {
    try {
      final response = await ApiClient.get('/recipients');
      if (response is List) {
        _recipients = response.map((json) => TransferRecipient.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading recipients: $e');
    }
  }

  Future<bool> performCardTransfer({
    required String sourceAccountId,
    required String targetCardNumber,
    required double amount,
    String? description,
  }) async {
    try {
      await ApiClient.post('/transfers/card', body: {
        'accountId': sourceAccountId,
        'cardNumber': targetCardNumber,
        'amount': amount,
        'description': description,
      });
      return true;
    } catch (e) {
      debugPrint('Card Transfer failed: $e');
      return false;
    }
  }

  Future<Map<String, String>?> searchUserByPhone(String phone) async {
    try {
      final response = await ApiClient.post('/users/search', body: {
        'phone': phone,
      });

      if (response != null) {
        return {
          'firstName': response['firstName'],
          'surname': response['surname'],
          'patronymic': response['patronymic'] ?? '',
        };
      }
      return null;
    } catch (e) {
      debugPrint('User search failed: $e');
      return null;
    }
  }

  Future<bool> performPhoneTransfer({
    required String sourceAccountId,
    required String phoneNumber,
    required double amount,
    String? description,
  }) async {
    try {
      await ApiClient.post('/transfers/phone', body: {
        'accountId': sourceAccountId,
        'phoneNumber': phoneNumber,
        'amount': amount,
        'description': description,
      });
      return true;
    } catch (e) {
      debugPrint('Phone Transfer failed: $e');
      return false;
    }
  }

  Future<bool> addRecipient(TransferRecipient recipient) async {
    try {
      final response = await ApiClient.post('/recipients', body: recipient.toJson());
      final newRecipient = TransferRecipient.fromJson(response);
      _recipients.add(newRecipient);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding recipient: $e');
      return false;
    }
  }
}