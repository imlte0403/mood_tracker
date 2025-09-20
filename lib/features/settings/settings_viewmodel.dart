import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_tracker/features/settings/settings_model.dart';
import 'package:mood_tracker/features/settings/settings_repo.dart';
import 'package:mood_tracker/core/providers/theme_mode_provider.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._ref) {
    _loadSettings();
  }

  final Ref _ref;
  final SettingsRepository _repository = SettingsRepository();
  SettingsModel _settings = SettingsModel(darkMode: false);

  SettingsModel get settings => _settings;
  bool get darkMode => _settings.darkMode;
  bool get followSystem => _settings.followSystem;

  Future<void> _loadSettings() async {
    try {
      final mode = await _repository.loadThemeMode();
      _settings = mode;
      _applyThemeMode(mode);
    } catch (e) {
      _settings = const SettingsModel(darkMode: false, followSystem: true);
      _applyThemeMode(_settings);
    }
  }

  Future<void> setThemeMode({
    required bool followSystem,
    required bool darkMode,
  }) async {
    final updated = _settings.copyWith(
      followSystem: followSystem,
      darkMode: darkMode,
    );
    await _repository.saveThemeMode(updated);
    _settings = updated;
    _applyThemeMode(updated);
    notifyListeners();
  }

  void _applyThemeMode(SettingsModel model) {
    final controller = _ref.read(themeModeProvider.notifier);
    if (model.followSystem) {
      controller.setThemeMode(ThemeMode.system);
    } else {
      controller.setThemeMode(model.darkMode ? ThemeMode.dark : ThemeMode.light);
    }
  }
}

final settingsViewModelProvider = ChangeNotifierProvider<SettingsViewModel>((ref) {
  return SettingsViewModel(ref);
});
