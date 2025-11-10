import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';

class PrivacyScreen extends StatelessWidget {
  static const routeName = 'privacy';
  static const routeURL = '/settings/privacy';

  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "개인 정보",
          style: AppTextStyles.authAppBar(
            Theme.of(context).textTheme,
          )?.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.0,
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.size20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "개인정보 보호 안내",
                style: AppTextStyles.authAppBar(
                  Theme.of(context).textTheme,
                )?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Gaps.v20,
              Text(
                "마지막 업데이트: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                style: AppTextStyles.settings(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              Gaps.v32,

              _buildSection(
                context,
                "우리가 수집하는 정보",
                "회원 가입과 감정 기록 과정에서 입력한 이름, 이메일, 감정 기록과 같은 데이터를 안전하게 보관합니다.",
              ),

              _buildSection(
                context,
                "정보 활용 방법",
                "수집된 정보는 기록을 저장하고 더 나은 서비스를 제공하기 위한 분석에만 사용됩니다. 축적된 감정 데이터는 오직 회원님의 마음 흐름을 이해하는 데 쓰입니다.",
              ),

              _buildSection(
                context,
                "데이터 보안",
                "암호화와 접근 제한을 포함한 여러 보안 장치를 통해 허가되지 않은 접근이나 노출로부터 정보를 보호합니다.",
              ),

              _buildSection(
                context,
                "정보 공유 여부",
                "회원님의 데이터를 제3자에게 판매하거나 공유하지 않습니다. 모든 감정 기록과 메모는 회원님만 확인할 수 있습니다.",
              ),

              _buildSection(
                context,
                "회원님의 권리",
                "언제든지 정보를 조회하거나 수정하고, 필요하다면 앱 설정에서 데이터를 내보내거나 계정을 삭제할 수 있습니다.",
              ),

              _buildSection(
                context,
                "문의 방법",
                "개인정보 보호와 관련한 궁금증은 도움말 메뉴 또는 support@moodtracker.app으로 편하게 연락해 주세요.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.authAppBar(
            Theme.of(context).textTheme,
          )?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Gaps.v12,
        Text(
          content,
          style: AppTextStyles.settings(
            context,
          ).copyWith(fontSize: 16, height: 1.5),
        ),
        Gaps.v24,
      ],
    );
  }
}
