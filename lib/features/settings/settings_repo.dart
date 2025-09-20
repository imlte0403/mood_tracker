import 'package:shared_preferences/shared_preferences.dart';

import 'package:mood_tracker/features/settings/settings_model.dart';

class SettingsRepository {
  static const String _darkModeKey = 'darkMode';
  static const String _followSystemKey = 'followSystemTheme';

  Future<SettingsModel> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final followSystem = prefs.getBool(_followSystemKey) ?? true;
    final darkMode = prefs.getBool(_darkModeKey) ?? false;
    return SettingsModel(darkMode: darkMode, followSystem: followSystem);
  }

  Future<void> saveThemeMode(SettingsModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_followSystemKey, model.followSystem);
    await prefs.setBool(_darkModeKey, model.darkMode);
  }
}
