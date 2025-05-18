import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_icons.dart';

/// 시간별 예보 위젯
class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecast> hourlyForecast;

  const HourlyForecastWidget({
    Key? key,
    required this.hourlyForecast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '시간별 예보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyForecast.length,
            itemBuilder: (context, index) {
              final hourly = hourlyForecast[index];
              return _buildHourlyItem(hourly, index == 0);
            },
          ),
        ),
      ],
    );
  }

  /// 시간별 예보 아이템 위젯
  Widget _buildHourlyItem(HourlyForecast hourly, bool isNow) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: isNow ? Colors.blue[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: isNow
            ? Border.all(color: Colors.blue.shade200, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatHour(hourly.dt),
            style: TextStyle(
              fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
              color: isNow ? Colors.blue[700] : Colors.black87,
            ),
          ),
          Image.asset(
            WeatherIcons.getIconPath(hourly.icon),
            width: 32,
            height: 32,
          ),
          Text(
            '${hourly.temp.round()}°',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isNow ? Colors.blue[700] : Colors.black87,
            ),
          ),
          _buildRainProbability(hourly.pop),
        ],
      ),
    );
  }

  /// 강수확률 위젯
  Widget _buildRainProbability(double? pop) {
    if (pop == null || pop <= 0) {
      return const SizedBox(height: 16);
    }

    final percentage = (pop * 100).round();
    
    // 10% 미만이면 표시하지 않음
    if (percentage < 10) {
      return const SizedBox(height: 16);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.water_drop,
          size: 12,
          color: Colors.blue[400],
        ),
        const SizedBox(width: 2),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[600],
          ),
        ),
      ],
    );
  }

  /// 시간 포맷팅
  String _formatHour(DateTime dateTime) {
    final now = DateTime.now();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    
    if (dateTime.day == now.day && dateTime.month == now.month) {
      if (dateTime.hour == now.hour) {
        return '지금';
      }
      return '$hour시';
    } else {
      return '내일\n$hour시';
    }
  }
} 