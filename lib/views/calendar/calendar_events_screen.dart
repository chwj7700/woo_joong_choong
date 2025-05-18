import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../models/calendar_event_model.dart';
import '../../utils/colors.dart';
import '../../widgets/weather_icon.dart';
import 'calendar_sync_screen.dart';
import 'calendar_event_detail_screen.dart';

/// 캘린더 이벤트 목록 화면
class CalendarEventsScreen extends StatefulWidget {
  const CalendarEventsScreen({super.key});

  @override
  State<CalendarEventsScreen> createState() => _CalendarEventsScreenState();
}

class _CalendarEventsScreenState extends State<CalendarEventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // 캘린더 이벤트 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
      calendarProvider.loadAllEvents();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일정 날씨'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: '캘린더 연동',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarSyncScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: '오늘'),
            Tab(text: '예정된 일정'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayEventsTab(),
          _buildUpcomingEventsTab(),
        ],
      ),
    );
  }
  
  /// 오늘 일정 탭
  Widget _buildTodayEventsTab() {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.hasError) {
          return _buildErrorView(provider.errorMessage);
        }
        
        final events = provider.todayEvents;
        
        if (events.isEmpty) {
          return _buildEmptyView('오늘 예정된 일정이 없습니다.');
        }
        
        return RefreshIndicator(
          onRefresh: () => provider.loadTodayEvents(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _buildEventCard(event);
            },
          ),
        );
      },
    );
  }
  
  /// 예정된 일정 탭
  Widget _buildUpcomingEventsTab() {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.hasError) {
          return _buildErrorView(provider.errorMessage);
        }
        
        final events = provider.upcomingEvents;
        
        if (events.isEmpty) {
          return _buildEmptyView('예정된 일정이 없습니다.');
        }
        
        // 일자별로 이벤트 그룹화
        final Map<String, List<CalendarEvent>> groupedEvents = {};
        final dateFormat = DateFormat('yyyy-MM-dd');
        
        for (final event in events) {
          final dateKey = dateFormat.format(event.startTime);
          if (!groupedEvents.containsKey(dateKey)) {
            groupedEvents[dateKey] = [];
          }
          groupedEvents[dateKey]!.add(event);
        }
        
        // 정렬된 날짜 키 목록
        final sortedDates = groupedEvents.keys.toList()
          ..sort();
        
        return RefreshIndicator(
          onRefresh: () => provider.loadUpcomingEvents(15),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final dateKey = sortedDates[index];
              final dayEvents = groupedEvents[dateKey]!;
              final date = dateFormat.parse(dateKey);
              
              return _buildDayEventsGroup(date, dayEvents);
            },
          ),
        );
      },
    );
  }
  
  /// 일자별 이벤트 그룹 위젯
  Widget _buildDayEventsGroup(DateTime date, List<CalendarEvent> events) {
    final koreanDateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    final dayString = koreanDateFormat.format(date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            dayString,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...events.map((event) => _buildEventCard(event)).toList(),
        const SizedBox(height: 8),
      ],
    );
  }
  
  /// 이벤트 카드 위젯
  Widget _buildEventCard(CalendarEvent event) {
    // 시간 형식
    final timeFormat = DateFormat('a h:mm', 'ko_KR');
    final startTimeString = timeFormat.format(event.startTime);
    final endTimeString = timeFormat.format(event.endTime);
    
    // 날씨 정보 표시 여부
    final hasWeather = event.weatherIcon != null && event.temperature != null;
    
    // 진행 중 이벤트 표시
    final isOngoing = event.isOngoing();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOngoing 
            ? BorderSide(color: AppColors.primary, width: 2) 
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CalendarEventDetailScreen(event: event),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 캘린더 색상 표시
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(top: 4, right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  
                  // 일정 제목 및 시간
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$startTimeString - $endTimeString',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 날씨 정보
                  if (hasWeather)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        WeatherIcon(
                          iconCode: event.weatherIcon!,
                          size: 32,
                        ),
                        Text(
                          '${event.temperature!.round()}°',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              // 장소 정보 (있는 경우)
              if (event.location != null && event.location!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.address ?? event.location!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // 알림 설정 표시
              if (event.hasNotification)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_active,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.notificationLeadTime}시간 전 알림',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 에러 표시 위젯
  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final calendarProvider = Provider.of<CalendarProvider>(
                  context, 
                  listen: false,
                );
                calendarProvider.loadAllEvents();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 빈 목록 표시 위젯
  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.sync),
            label: const Text('캘린더 연동하기'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarSyncScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 