import 'package:flutter/material.dart';
import 'package:veridian/services/localization_service.dart';

class LocalizationProvider extends ChangeNotifier {
  final LocalizationService _localizationService = LocalizationService();

  AppLanguage get currentLanguage => _localizationService.currentLanguage;

  Future<void> init() async {
    await _localizationService.init();
  }

  Future<void> setLanguage(AppLanguage language) async {
    await _localizationService.setLanguage(language);
    notifyListeners();
  }

  String translate(String key) {
    return _localizationService.translate(key);
  }

  Map<String, String> getTranslations() {
    return _localizationService.getTranslations();
  }
}
