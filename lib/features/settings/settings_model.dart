class SettingsModel {
  final bool darkMode;

  SettingsModel({
    required this.darkMode,
  });

  SettingsModel copyWith({
    bool? darkMode,
  }) {
    return SettingsModel(
      darkMode: darkMode ?? this.darkMode,
    );
  }
}