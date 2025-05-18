import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../utils/weather_icons.dart';

/// 일별 예보 위젯
class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecast> dailyForecast;

  const DailyForecastWidget({
    Key? key,
    required this.dailyForecast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '주간 예보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: dailyForecast.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final daily = dailyForecast[index];
              return _buildDailyItem(context, daily, index == 0);
            },
          ),
        ),
      ],
    );
  }

  /// 일별 예보 항목 위젯
  Widget _buildDailyItem(BuildContext context, DailyForecast daily, bool isToday) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 날짜
          SizedBox(
            width: 60,
            child: Text(
              _formatDay(daily.dt, isToday),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
          ),
          
          // 날씨 아이콘
          Row(
            children: [
              Image.asset(
                WeatherIcons.getIconPath(daily.icon),
                width: 36,
                height: 36,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: Text(
                  daily.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          
          // 강수확률
          if (daily.pop != null && daily.pop! > 0)
            Row(
              children: [
                Icon(
                  Icons.water_drop,
                  size: 14,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 2),
                Text(
                  '${(daily.pop! * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            )
          else
            const SizedBox(width: 45),
          
          // 온도
          Row(
            children: [
              Text(
                '${daily.temp.max.round()}°',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${daily.temp.min.round()}°',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 날짜 포맷팅
  String _formatDay(DateTime date, bool isToday) {
    if (isToday) {
      return '오늘';
    }
    
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    
    if (date.year == tomorrow.year && 
        date.month == tomorrow.month && 
        date.day == tomorrow.day) {
      return '내일';
    }
    
    // 요일 표시
    final formatter = DateFormat('E', 'ko');
    return '${date.day}일 (${formatter.format(date)})';
  }
} 