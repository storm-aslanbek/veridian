import 'package:flutter/foundation.dart';
import 'package:veridian/models/user.dart';
import 'package:veridian/services/api_client.dart';
import 'package:veridian/services/local_storage_service.dart';

class UserService extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  // Загрузка при старте
  Future<void> loadCurrentUser() async {
    try {
      final token = LocalStorageService.getString('auth_token');

      if (token == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }

      ApiClient.setToken(token);

      final userJson = await ApiClient.get('/users/me');

      if (userJson != null) {
        _currentUser = User.fromJson(userJson);
        notifyListeners();
      } else {
        await logout();
      }
    } catch (e) {
      debugPrint('Auto-login failed (token expired or network error): $e');
      await logout();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiClient.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      final token = response['token'];
      final userJson = response['user'];

      if (token != null && userJson != null) {
        await LocalStorageService.saveString('auth_token', token);
        ApiClient.setToken(token);

        _currentUser = User.fromJson(userJson);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String surname,
    String? patronymic,
    required String iin,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await ApiClient.post('/auth/register', body: {
        'firstName': firstName,
        'surname': surname,
        'patronymic': patronymic,
        'iin': iin,
        'email': email,
        'password': password,
        'phone': phone,
      });

      final token = response['token'];
      final userJson = response['user'];

      if (token != null && userJson != null) {
        await LocalStorageService.saveString('auth_token', token);
        ApiClient.setToken(token);

        _currentUser = User.fromJson(userJson);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await LocalStorageService.remove('auth_token');
    ApiClient.setToken(null);
    _currentUser = null;
    notifyListeners();
  }
}