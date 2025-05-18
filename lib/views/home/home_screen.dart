import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../utils/colors.dart';
import '../../routes.dart';
import '../profile/profile_menu_screen.dart';
import 'tabs/weather_tab.dart';
import 'tabs/places_tab.dart';
import '../calendar/calendar_events_screen.dart';

/// 앱의 메인 화면 (탭 기반 네비게이션)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // 탭 페이지들
  late final List<Widget> _tabPages;
  
  // 탭 아이템 정보
  late final List<BottomNavigationBarItem> _navItems;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 지역화된 문자열을 가져오기 위해 didChangeDependencies에서 초기화
    final localizations = AppLocalizations.of(context)!;
    
    // 탭 페이지 초기화
    _tabPages = [
      // 날씨 탭
      const WeatherTab(),
      
      // 장소 탭
      const PlacesTab(),
      
      // 캘린더 탭
      const CalendarEventsScreen(),
      
      // 프로필 탭
      const ProfileMenuScreen(),
    ];
    
    // 하단 탭 아이템 초기화
    _navItems = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.wb_sunny_outlined),
        activeIcon: const Icon(Icons.wb_sunny),
        label: '날씨',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.place_outlined),
        activeIcon: const Icon(Icons.place),
        label: '장소',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.calendar_today_outlined),
        activeIcon: const Icon(Icons.calendar_today),
        label: '캘린더',
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: '프로필',
      ),
    ];
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _tabPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 8,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
} 