import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  static Future<bool> saveString(String key, String value) async {
    try {
      return await instance.setString(key, value);
    } catch (e) {
      debugPrint('Error saving string: $e');
      return false;
    }
  }

  static String? getString(String key) {
    try {
      return instance.getString(key);
    } catch (e) {
      debugPrint('Error getting string: $e');
      return null;
    }
  }

  static Future<bool> saveList(String key, List<String> value) async {
    try {
      return await instance.setStringList(key, value);
    } catch (e) {
      debugPrint('Error saving list: $e');
      return false;
    }
  }

  static List<String>? getList(String key) {
    try {
      return instance.getStringList(key);
    } catch (e) {
      debugPrint('Error getting list: $e');
      return null;
    }
  }

  static Future<bool> saveBool(String key, bool value) async {
    try {
      return await instance.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving bool: $e');
      return false;
    }
  }

  static bool? getBool(String key) {
    try {
      return instance.getBool(key);
    } catch (e) {
      debugPrint('Error getting bool: $e');
      return null;
    }
  }

  static Future<bool> saveInt(String key, int value) async {
    try {
      return await instance.setInt(key, value);
    } catch (e) {
      debugPrint('Error saving int: $e');
      return false;
    }
  }

  static int? getInt(String key) {
    try {
      return instance.getInt(key);
    } catch (e) {
      debugPrint('Error getting int: $e');
      return null;
    }
  }

  static Future<bool> saveDouble(String key, double value) async {
    try {
      return await instance.setDouble(key, value);
    } catch (e) {
      debugPrint('Error saving double: $e');
      return false;
    }
  }

  static double? getDouble(String key) {
    try {
      return instance.getDouble(key);
    } catch (e) {
      debugPrint('Error getting double: $e');
      return null;
    }
  }

  static Future<bool> remove(String key) async {
    try {
      return await instance.remove(key);
    } catch (e) {
      debugPrint('Error removing key: $e');
      return false;
    }
  }

  static Future<bool> clear() async {
    try {
      return await instance.clear();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
      return false;
    }
  }

  static Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    try {
      return await saveString(key, jsonEncode(value));
    } catch (e) {
      debugPrint('Error saving JSON: $e');
      return false;
    }
  }

  static Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting JSON: $e');
      return null;
    }
  }

  static Future<bool> saveJsonList(String key, List<Map<String, dynamic>> value) async {
    try {
      return await saveString(key, jsonEncode(value));
    } catch (e) {
      debugPrint('Error saving JSON list: $e');
      return false;
    }
  }

  static List<Map<String, dynamic>>? getJsonList(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) return null;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Error getting JSON list: $e');
      return null;
    }
  }
}
