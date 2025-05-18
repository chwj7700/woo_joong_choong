import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';

/// 도움말 화면
class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  /// 웹 URL 열기
  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL을 열 수 없습니다: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도움말'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 자주 묻는 질문 섹션
            _buildSection(
              title: '자주 묻는 질문',
              children: [
                _buildFaqItem(
                  context,
                  question: '위치 정보를 가져올 수 없어요',
                  answer: '앱 설정에서 위치 권한이 허용되어 있는지 확인해주세요. 설정 > 위치 > 우중충 앱에서 권한을 확인할 수 있습니다. 또한 기기의 위치 서비스가 켜져 있는지도 확인해주세요.',
                ),
                _buildFaqItem(
                  context,
                  question: '날씨 정보가 정확하지 않아요',
                  answer: '우중충 앱은 공개 API를 통해 날씨 정보를 제공합니다. 실시간 업데이트가 이루어지지만, 간혹 지연되거나 부정확할 수 있습니다. 새로고침을 통해 최신 정보를 확인해보세요.',
                ),
                _buildFaqItem(
                  context,
                  question: '알림이 오지 않아요',
                  answer: '설정 메뉴에서 알림이 활성화되어 있는지 확인해주세요. 또한 기기의 알림 설정에서 우중충 앱의 알림이 허용되어 있는지 확인해주세요. 배터리 절약 모드에서는 알림이 지연될 수 있습니다.',
                ),
                _buildFaqItem(
                  context,
                  question: '즐겨찾기는 어떻게 추가하나요?',
                  answer: '홈 화면에서 우측 상단의 검색 아이콘을 클릭하여 위치를 검색한 후, 결과 화면에서 즐겨찾기 아이콘을 클릭하면 추가됩니다. 즐겨찾기 메뉴에서 추가된 위치를 확인하고 관리할 수 있습니다.',
                ),
                _buildFaqItem(
                  context,
                  question: '캘린더 연동은 어떻게 하나요?',
                  answer: '설정 메뉴에서 캘린더 연동을 선택하고, 연동하고 싶은 캘린더를 선택해주세요. 캘린더 일정에 위치 정보가 있으면 자동으로 해당 일정의 날씨 정보를 제공합니다.',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 문의하기 섹션
            _buildSection(
              title: '문의하기',
              children: [
                ListTile(
                  title: const Text('이메일로 문의하기'),
                  subtitle: const Text('woojoongchoong@example.com'),
                  leading: const Icon(Icons.email),
                  onTap: () {
                    _launchUrl(context, 'mailto:woojoongchoong@example.com?subject=우중충 앱 문의');
                  },
                ),
                ListTile(
                  title: const Text('피드백 남기기'),
                  subtitle: const Text('앱 개선을 위한 의견을 보내주세요'),
                  leading: const Icon(Icons.feedback),
                  onTap: () {
                    _showFeedbackDialog(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 사용 가이드 섹션
            _buildSection(
              title: '사용 가이드',
              children: [
                ListTile(
                  title: const Text('앱 사용 방법'),
                  subtitle: const Text('우중충 앱 기본 사용법'),
                  leading: const Icon(Icons.help_outline),
                  onTap: () {
                    _showGuideDialog(context, '앱 사용 방법', _getBasicGuideText());
                  },
                ),
                ListTile(
                  title: const Text('알림 설정 가이드'),
                  subtitle: const Text('알림 설정 및 활용법'),
                  leading: const Icon(Icons.notifications),
                  onTap: () {
                    _showGuideDialog(context, '알림 설정 가이드', _getNotificationGuideText());
                  },
                ),
                ListTile(
                  title: const Text('캘린더 연동 가이드'),
                  subtitle: const Text('캘린더 연동 및 활용법'),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () {
                    _showGuideDialog(context, '캘린더 연동 가이드', _getCalendarGuideText());
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  /// 섹션 위젯
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
  
  /// FAQ 항목 위젯
  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
  
  /// 피드백 다이얼로그 표시
  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('피드백 남기기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('앱 개선을 위한 의견을 남겨주세요.'),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  hintText: '여기에 의견을 작성해주세요',
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
              child: const Text('보내기'),
              onPressed: () {
                // TODO: 피드백 전송 로직 구현
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('피드백이 전송되었습니다. 감사합니다!')),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  /// 가이드 다이얼로그 표시
  void _showGuideDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  /// 기본 사용 가이드 텍스트
  String _getBasicGuideText() {
    return '''
우중충 앱 기본 사용 가이드

1. 홈 화면
   - 현재 위치의 날씨 정보를 확인할 수 있습니다.
   - 시간별, 일별 예보를 확인할 수 있습니다.
   - 상단의 검색 아이콘을 통해 다른 지역의 날씨를 검색할 수 있습니다.

2. 즐겨찾기
   - 자주 확인하는 지역을 즐겨찾기에 추가할 수 있습니다.
   - 즐겨찾기 메뉴에서 추가된 위치의 날씨를 빠르게 확인할 수 있습니다.

3. 캘린더
   - 일정이 있는 날의 날씨를 미리 확인할 수 있습니다.
   - 캘린더 연동을 통해 일정에 맞는 날씨 정보를 제공받을 수 있습니다.

4. 설정
   - 알림, 단위, 위치 등 앱의 다양한 설정을 변경할 수 있습니다.
   - 사용자 프로필 정보를 설정하여 맞춤형 날씨 정보를 제공받을 수 있습니다.
''';
  }
  
  /// 알림 가이드 텍스트
  String _getNotificationGuideText() {
    return '''
알림 설정 가이드

1. 알림 활성화하기
   - 설정 > 알림 설정에서 알림을 활성화할 수 있습니다.
   - 날씨 변화, 미세먼지, 강수, 자외선, 캘린더 등 다양한 알림 유형을 선택할 수 있습니다.

2. 알림 시간대 설정
   - 알림을 받고 싶은 시간대를 설정할 수 있습니다.
   - 설정된 시간 외에는 알림이 전송되지 않습니다.

3. 미세먼지 알림 기준
   - 미세먼지 농도에 따른 알림 기준을 설정할 수 있습니다.
   - 설정한 기준치 이상일 때 알림을 받을 수 있습니다.

4. 문제 해결
   - 알림이 오지 않는 경우 기기의 알림 설정에서 우중충 앱의 알림이 허용되어 있는지 확인해주세요.
   - 배터리 절약 모드에서는 알림이 지연될 수 있습니다.
''';
  }
  
  /// 캘린더 가이드 텍스트
  String _getCalendarGuideText() {
    return '''
캘린더 연동 가이드

1. 캘린더 연동하기
   - 캘린더 메뉴 > 캘린더 연동에서 연동할 캘린더를 선택할 수 있습니다.
   - 기기의 캘린더 앱에 있는 일정들을 불러올 수 있습니다.

2. 일정별 날씨 확인
   - 연동된 캘린더의 일정 목록에서 각 일정의 날씨 정보를 확인할 수 있습니다.
   - 일정을 선택하면 상세 날씨 정보를 볼 수 있습니다.

3. 날씨 알림 설정
   - 중요한 일정에 대해 날씨 알림을 설정할 수 있습니다.
   - 일정 시작 시간 전에 날씨 정보와 준비물 추천을 받을 수 있습니다.

4. 주의사항
   - 일정에 위치 정보가 있어야 정확한 날씨 정보를 제공받을 수 있습니다.
   - 일부 캘린더 앱에서는 위치 정보가 제공되지 않을 수 있습니다.
''';
  }
} 