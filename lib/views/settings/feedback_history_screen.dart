import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../utils/colors.dart';

/// 피드백 내역 데이터 모델
class FeedbackItem {
  final String id;
  final String content;
  final DateTime date;
  final String? response;
  final String status; // 'pending', 'answered', 'resolved'
  
  FeedbackItem({
    required this.id,
    required this.content,
    required this.date,
    this.response,
    required this.status,
  });
  
  /// JSON으로 변환
  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'date': date.toIso8601String(),
    'response': response,
    'status': status,
  };
  
  /// JSON에서 객체 생성
  factory FeedbackItem.fromJson(Map<String, dynamic> json) => FeedbackItem(
    id: json['id'],
    content: json['content'],
    date: DateTime.parse(json['date']),
    response: json['response'],
    status: json['status'],
  );
}

/// 피드백 내역 화면
class FeedbackHistoryScreen extends StatefulWidget {
  const FeedbackHistoryScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackHistoryScreen> createState() => _FeedbackHistoryScreenState();
}

class _FeedbackHistoryScreenState extends State<FeedbackHistoryScreen> {
  List<FeedbackItem> _feedbackItems = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadFeedbackHistory();
  }
  
  /// 피드백 내역 로드
  Future<void> _loadFeedbackHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final feedbackJson = prefs.getString('feedback_history');
      
      if (feedbackJson != null) {
        final List<dynamic> decodedList = jsonDecode(feedbackJson);
        _feedbackItems = decodedList
            .map((item) => FeedbackItem.fromJson(item))
            .toList();
      } else {
        // 데모 데이터 생성
        _generateDemoFeedback();
      }
    } catch (e) {
      // 오류 발생 시 데모 데이터로 대체
      _generateDemoFeedback();
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  /// 데모 피드백 데이터 생성
  void _generateDemoFeedback() {
    _feedbackItems = [
      FeedbackItem(
        id: '1',
        content: '앱에서 일부 지역의 날씨 정보가 부정확해요. 확인 부탁드립니다.',
        date: DateTime.now().subtract(const Duration(days: 3)),
        response: '안녕하세요, 피드백 감사합니다. 해당 지역의 날씨 정보 제공자를 확인하고 있습니다. 빠른 시일 내에 개선하겠습니다.',
        status: 'answered',
      ),
      FeedbackItem(
        id: '2',
        content: '알림 소리를 사용자가 선택할 수 있었으면 좋겠어요.',
        date: DateTime.now().subtract(const Duration(days: 10)),
        response: '소중한 의견 감사합니다. 다음 업데이트에 알림 소리 설정 기능을 추가할 예정입니다.',
        status: 'resolved',
      ),
      FeedbackItem(
        id: '3',
        content: '날씨에 맞는 옷차림 추천 기능이 있으면 좋겠어요.',
        date: DateTime.now().subtract(const Duration(days: 15)),
        status: 'pending',
      ),
    ];
  }
  
  /// 새 피드백 추가
  Future<void> _addNewFeedback(String content) async {
    final newFeedback = FeedbackItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      date: DateTime.now(),
      status: 'pending',
    );
    
    setState(() {
      _feedbackItems.insert(0, newFeedback);
    });
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedList = jsonEncode(_feedbackItems.map((item) => item.toJson()).toList());
      await prefs.setString('feedback_history', encodedList);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('피드백 저장 중 오류 발생: $e')),
        );
      }
    }
  }
  
  /// 피드백 작성 다이얼로그 표시
  void _showAddFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('피드백 작성'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('앱 개선을 위한 의견을 남겨주세요.'),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  hintText: '의견을 작성해주세요',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('제출'),
              onPressed: () {
                final feedbackText = feedbackController.text.trim();
                if (feedbackText.isNotEmpty) {
                  _addNewFeedback(feedbackText);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('피드백이 제출되었습니다. 감사합니다.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('피드백 내역'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedbackItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.feedback,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '작성한 피드백이 없습니다',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('피드백 작성하기'),
                        onPressed: _showAddFeedbackDialog,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _feedbackItems.length,
                        itemBuilder: (context, index) {
                          final item = _feedbackItems[index];
                          return _buildFeedbackCard(item);
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFeedbackDialog,
        child: const Icon(Icons.add),
        tooltip: '새 피드백 작성',
      ),
    );
  }
  
  /// 피드백 카드 위젯
  Widget _buildFeedbackCard(FeedbackItem feedback) {
    // 상태에 따른 색상 정의
    Color statusColor;
    String statusText;
    
    switch (feedback.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = '처리 중';
        break;
      case 'answered':
        statusColor = Colors.blue;
        statusText = '답변 완료';
        break;
      case 'resolved':
        statusColor = Colors.green;
        statusText = '해결됨';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '알 수 없음';
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (날짜 및 상태)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Text(
                  '${feedback.date.year}.${feedback.date.month.toString().padLeft(2, '0')}.${feedback.date.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        feedback.status == 'pending'
                            ? Icons.schedule
                            : feedback.status == 'answered'
                                ? Icons.chat
                                : Icons.check_circle,
                        color: statusColor,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 피드백 내용
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              feedback.content,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          
          // 관리자 답변 (있는 경우)
          if (feedback.response != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '관리자 답변',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    feedback.response!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 