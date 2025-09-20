class HelpContent {
  static const List<HelpSection> sections = [
    HelpSection(
      title: 'Getting Started',
      items: [
        HelpItem(
          question: 'How do I record my mood?',
          answer: 'Tap the "+" button on the home screen to create a new mood entry. Select your emotion and add a note about your day.',
        ),
        HelpItem(
          question: 'Can I edit my mood entries?',
          answer: 'Yes! Tap on any mood entry in your timeline to edit the emotion, time, or note.',
        ),
        HelpItem(
          question: 'How do I view my mood history?',
          answer: 'Your mood timeline is displayed on the home screen. Scroll down to see older entries.',
        ),
      ],
    ),
    HelpSection(
      title: 'Features',
      items: [
        HelpItem(
          question: 'What do the different colors mean?',
          answer: 'Each emotion has a unique color and shape. Happy moods are brighter colors, while sad moods use cooler tones.',
        ),
        HelpItem(
          question: 'Can I export my data?',
          answer: 'Currently, data export is not available but is planned for future updates.',
        ),
        HelpItem(
          question: 'How does dark mode work?',
          answer: 'You can enable dark mode in Settings. It will change the app\'s appearance to be easier on your eyes in low light.',
        ),
      ],
    ),
    HelpSection(
      title: 'Account & Privacy',
      items: [
        HelpItem(
          question: 'Is my data secure?',
          answer: 'Yes, your mood data is securely stored and encrypted. Only you can access your personal information.',
        ),
        HelpItem(
          question: 'Can I delete my account?',
          answer: 'You can delete your account and all associated data from the Privacy settings.',
        ),
        HelpItem(
          question: 'How do I change my password?',
          answer: 'Go to Account settings to update your email or password.',
        ),
      ],
    ),
    HelpSection(
      title: 'Troubleshooting',
      items: [
        HelpItem(
          question: 'The app is not loading my data',
          answer: 'Make sure you have an internet connection and try restarting the app. If the problem persists, contact support.',
        ),
        HelpItem(
          question: 'I forgot my password',
          answer: 'Use the "Forgot Password" option on the login screen to reset your password via email.',
        ),
        HelpItem(
          question: 'How do I contact support?',
          answer: 'You can reach out to our support team at support@moodtracker.com for any issues or questions.',
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