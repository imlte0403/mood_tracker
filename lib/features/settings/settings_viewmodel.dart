import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_tracker/features/settings/settings_model.dart';
import 'package:mood_tracker/features/settings/settings_repo.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();
  SettingsModel _settings = SettingsModel(darkMode: false);

  SettingsModel get settings => _settings;
  bool get darkMode => _settings.darkMode;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final isDarkMode = await _repository.isDarkMode();
      _settings = SettingsModel(darkMode: isDarkMode);
      notifyListeners();
    } catch (e) {
      _settings = SettingsModel(darkMode: false);
      notifyListeners();
    }
  }

  Future<void> setDarkMode(bool darkMode) async {
    await _repository.setDarkMode(darkMode);
    _settings = _settings.copyWith(darkMode: darkMode);
    notifyListeners();
  }
}

final settingsViewModelProvider = ChangeNotifierProvider<SettingsViewModel>((ref) {
  return SettingsViewModel();
});
