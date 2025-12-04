import 'package:flutter/material.dart';

import 'package:mood_tracker/features/analytics/analytics_screen.dart';
import 'package:mood_tracker/features/home/home_screen.dart';
import 'package:mood_tracker/features/post/post_screen.dart';
import 'package:mood_tracker/features/search/search_screen.dart';

/// 메인 탭 뷰 (PageView + BottomNavigationBar)
///
/// 구조:
/// - index 0: SearchScreen (검색)
/// - index 1: HomeScreen (홈, 초기 화면)
/// - index 2: PostScreen (작성)
/// - index 3: AnalyticsScreen (통계)
class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  static const String routeName = 'main';
  static const String routeURL = '/';

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  final PageController _pageController = PageController(
    initialPage: 1, // 홈 화면을 초기 페이지로 (index 1)
  );

  int _currentPage = 1;

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

  void _onBottomNavTapped(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          SearchScreen(), // index 0: 검색
          HomeScreen(), // index 1: 홈
          PostScreen(), // index 2: 작성
          AnalyticsScreen(), // index 3: 통계
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: '작성',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
          ),
        ],
      ),
    );
  }
}
