class SettingsModel {
  const SettingsModel({
    required this.darkMode,
    this.followSystem = true,
  });

  final bool darkMode;
  final bool followSystem;

  SettingsModel copyWith({
    bool? darkMode,
    bool? followSystem,
  }) {
    return SettingsModel(
      darkMode: darkMode ?? this.darkMode,
      followSystem: followSystem ?? this.followSystem,
    );
  }
}
