import 'package:flutter/foundation.dart';
import 'package:veridian/models/support_chat.dart';
import 'package:veridian/services/api_client.dart';

class SupportService extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> sendMessage(String message, String language) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('SupportService: Отправка сообщения: "$message" ($language)');

      final request = SupportChatRequest(message: message, language: language);

      final response = await ApiClient.post(
          '/support/chat',
          body: request.toJson()
      );

      if (response != null) {
        final chatResponse = SupportChatResponse.fromJson(response);
        debugPrint('SupportService: Получен ответ: "${chatResponse.reply}"');
        return chatResponse.reply;
      } else {
        debugPrint('SupportService: Ответ от сервера пустой (null)');
        return null;
      }
    } catch (e) {
      debugPrint('SupportService Error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}