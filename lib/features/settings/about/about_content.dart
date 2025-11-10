class AboutContent {
  static const String appName = '무드 트래커';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  static const String developer = 'bimong';
  static const String description =
      '하루의 마음과 감정을 잔잔한 시각화로 기록하며 스스로를 돌볼 수 있는 공간입니다.';

  static const List<String> features = [
    '하루 감정 기록과 회고',
    '감정 색상과 도형 시각화',
    '타임라인에서 흐름 돌아보기',
    '데이터 내보내기(예정)',
    '다크 모드 지원',
  ];

  static const List<LicenseInfo> licenses = [
    LicenseInfo(name: 'Flutter', version: '3.x', license: 'BSD-3-Clause'),
    LicenseInfo(name: 'Firebase', version: '10.x', license: 'Apache-2.0'),
    LicenseInfo(name: 'Riverpod', version: '2.x', license: 'MIT'),
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
