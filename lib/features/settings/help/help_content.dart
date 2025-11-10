class HelpContent {
  static const List<HelpSection> sections = [
    HelpSection(
      title: '처음 시작하기',
      items: [
        HelpItem(
          question: '감정은 어떻게 기록하나요?',
          answer:
              '홈 화면의 + 버튼을 누르면 새 기록을 만들 수 있어요. 지금 느끼는 감정을 고르고 마음에 남은 이야기를 적어주세요.',
        ),
        HelpItem(
          question: '기록을 나중에 다시 고칠 수 있나요?',
          answer:
              '타임라인에서 수정하고 싶은 기록을 눌러 감정, 시간, 메모를 차분하게 다시 손볼 수 있습니다.',
        ),
        HelpItem(
          question: '지난 기록은 어디에서 볼 수 있나요?',
          answer:
              '홈 화면 아래로 스크롤하면 하루하루 남겨둔 감정 기록을 시간 순으로 살펴볼 수 있어요.',
        ),
      ],
    ),
    HelpSection(
      title: '주요 기능',
      items: [
        HelpItem(
          question: '색과 도형은 무엇을 의미하나요?',
          answer:
              '각 감정마다 고유한 색과 모양을 사용해요. 기쁜 감정은 밝고 따뜻하게, 힘든 감정은 차분한 색으로 표현됩니다.',
        ),
        HelpItem(
          question: '데이터를 내보내고 싶어요.',
          answer: '향후 업데이트에서 감정 기록 내보내기 기능을 준비하고 있습니다.',
        ),
        HelpItem(
          question: '다크 모드는 어떻게 켜나요?',
          answer:
              '환경설정의 화면 표현 섹션에서 다크 모드를 켜거나 시스템 설정에 맞출 수 있어요.',
        ),
      ],
    ),
    HelpSection(
      title: '계정과 안전',
      items: [
        HelpItem(
          question: '내 데이터는 안전하게 보관되나요?',
          answer:
              '감정 데이터는 암호화되어 저장되며, 회원님만 접근할 수 있도록 보호하고 있습니다.',
        ),
        HelpItem(
          question: '계정을 삭제하고 싶어요.',
          answer:
              '환경설정의 계정 관리 또는 개인정보 메뉴에서 계정 삭제를 진행할 수 있어요.',
        ),
        HelpItem(
          question: '비밀번호는 어디에서 바꿀 수 있나요?',
          answer:
              '계정 관리 화면에서 현재 비밀번호를 확인한 뒤 새 비밀번호로 변경할 수 있습니다.',
        ),
      ],
    ),
    HelpSection(
      title: '문제 해결',
      items: [
        HelpItem(
          question: '데이터가 불러와지지 않아요.',
          answer:
              '네트워크 상태를 확인한 뒤 앱을 다시 실행해 보세요. 계속 어려움이 있다면 아래 연락처로 알려주세요.',
        ),
        HelpItem(
          question: '비밀번호를 잊어버렸어요.',
          answer:
              '로그인 화면의 비밀번호 재설정 기능을 이용하면 이메일로 새 비밀번호를 만들 수 있어요.',
        ),
        HelpItem(
          question: '어디로 문의하면 되나요?',
          answer:
              '앱의 도움말 섹션이나 support@moodtracker.com으로 메일을 보내주시면 천천히 답변드릴게요.',
        ),
      ],
    ),
  ];

  static const ContactInfo contactInfo = ContactInfo(
    email: 'support@moodtracker.com',
    website: 'https://moodtracker.com',
  );
}

class HelpSection {
  final String title;
  final List<HelpItem> items;

  const HelpSection({
    required this.title,
    required this.items,
  });
}

class HelpItem {
  final String question;
  final String answer;

  const HelpItem({
    required this.question,
    required this.answer,
  });
}

class ContactInfo {
  final String email;
  final String website;

  const ContactInfo({
    required this.email,
    required this.website,
  });
}
