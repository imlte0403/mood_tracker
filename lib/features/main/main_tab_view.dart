import 'package:flutter/material.dart';
import 'package:mood_tracker/features/analytics/analytics_screen.dart';
import 'package:mood_tracker/features/home/home_screen.dart';

/// 메인 탭 뷰 (PageView로 홈과 통계를 스와이프로 전환)
///
/// 구조:
/// - 중앙 (index 0): HomeScreen (초기 화면)
/// - 오른쪽 스와이프 (index 1): AnalyticsScreen
/// - 왼쪽 스와이프 (index -1): SearchScreen (향후 추가)
class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  static const String routeName = 'main';
  static const String routeURL = '/';

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  final PageController _pageController = PageController(
    initialPage: 0, // 홈 화면을 초기 페이지로
  );

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      children: const [
        HomeScreen(), // 중앙: 홈 화면
        AnalyticsScreen(), // 오른쪽: 통계 화면
        // SearchScreen(), // 왼쪽: 검색 화면 (향후 추가)
      ],
    );
  }
}
