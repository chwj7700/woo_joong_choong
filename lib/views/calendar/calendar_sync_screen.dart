import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../utils/colors.dart';

/// 캘린더 연동 화면
class CalendarSyncScreen extends StatefulWidget {
  const CalendarSyncScreen({super.key});

  @override
  State<CalendarSyncScreen> createState() => _CalendarSyncScreenState();
}

class _CalendarSyncScreenState extends State<CalendarSyncScreen> {
  bool _permissionGranted = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  /// 권한 확인
  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });
    
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    final granted = await calendarProvider.requestCalendarPermissions();
    
    setState(() {
      _permissionGranted = granted;
      _isLoading = false;
    });
    
    if (granted) {
      await calendarProvider.loadCalendars();
    }
  }
  
  /// 권한 요청
  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });
    
    final calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    final granted = await calendarProvider.requestCalendarPermissions();
    
    setState(() {
      _permissionGranted = granted;
      _isLoading = false;
    });
    
    if (granted) {
      await calendarProvider.loadCalendars();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더 연동'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
  
  /// 화면 내용 구성
  Widget _buildContent() {
    if (!_permissionGranted) {
      return _buildPermissionRequest();
    }
    
    return _buildCalendarList();
  }
  
  /// 권한 요청 화면
  Widget _buildPermissionRequest() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_month,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              '캘린더 접근 권한이 필요합니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              '우중충 앱은 당신의 일정과 약속에 맞는 날씨 정보를 제공하기 위해 캘린더 접근 권한이 필요합니다. 약속 시간과 장소에 맞는 날씨 정보를 받아보세요.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _requestPermissions,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '권한 요청하기', 
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 캘린더 목록 화면
  Widget _buildCalendarList() {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (provider.hasError) {
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
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await provider.loadCalendars();
                    },
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }
        
        final calendars = provider.calendars;
        
        if (calendars.isEmpty) {
          return const Center(
            child: Text('사용 가능한 캘린더가 없습니다.'),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '연동할 캘린더 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '선택한 캘린더의 일정에 대해 날씨 정보 및 알림을 받을 수 있습니다.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: calendars.length,
                itemBuilder: (context, index) {
                  final calendar = calendars[index];
                  final isSelected = provider.isCalendarSelected(
                    calendar.id ?? '',
                  );
                  
                  return _buildCalendarTile(calendar, isSelected, provider);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '캘린더를 추가하거나 관리하려면 기기의 캘린더 앱을 이용하세요.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await provider.loadAllEvents();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('완료'),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// 캘린더 항목 위젯
  Widget _buildCalendarTile(
    Calendar calendar, 
    bool isSelected, 
    CalendarProvider provider
  ) {
    // 색상 처리
    Color calendarColor = AppColors.primary;
    
    if (calendar.color != null && calendar.color is String && (calendar.color as String).isNotEmpty) {
      try {
        final colorStr = calendar.color as String;
        calendarColor = Color(
          int.parse(
            colorStr.startsWith('#') 
              ? 'FF${colorStr.substring(1)}' 
              : 'FF$colorStr',
            radix: 16,
          ));
      } catch (e) {
        if (kDebugMode) {
          print('색상 변환 오류: $e');
        }
        calendarColor = AppColors.primary;
      }
    }
        
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: calendarColor,
        child: Icon(
          Icons.calendar_today,
          color: Colors.white,
          size: 18,
        ),
      ),
      title: Text(
        calendar.name ?? '이름 없는 캘린더',
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        calendar.accountName ?? '',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: isSelected,
        activeColor: AppColors.primary,
        onChanged: (selected) async {
          await provider.toggleCalendarSelection(
            calendar.id ?? '',
            selected,
          );
        },
      ),
      onTap: () async {
        await provider.toggleCalendarSelection(
          calendar.id ?? '',
          !isSelected,
        );
      },
    );
  }
} 