class AboutContent {
  static const String appName = 'Mood Tracker';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  static const String developer = 'Taeun Lee';
  static const String description = 'Track your daily moods and emotions with beautiful visualizations.';

  static const List<String> features = [
    'Daily mood tracking',
    'Emotion visualization',
    'Timeline view',
    'Data export',
    'Dark mode support',
  ];

  static const List<LicenseInfo> licenses = [
    LicenseInfo(
      name: 'Flutter',
      version: '3.x',
      license: 'BSD-3-Clause',
    ),
    LicenseInfo(
      name: 'Firebase',
      version: '10.x',
      license: 'Apache-2.0',
    ),
    LicenseInfo(
      name: 'Riverpod',
      version: '2.x',
      license: 'MIT',
    ),
  ];
}

class LicenseInfo {
  final String name;
  final String version;
  final String license;

  const LicenseInfo({
    required this.name,
    required this.version,
    required this.license,
  });
}