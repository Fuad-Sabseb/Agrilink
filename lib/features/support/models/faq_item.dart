/// FAQ Item Model
class FAQItem {
  final String id;
  final String question;
  final String answer;
  final String category;
  final List<String> tags;

  const FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.tags = const [],
  });
}

/// FAQ Categories
class FAQCategory {
  static const String general = 'General';
  static const String account = 'Account';
  static const String orders = 'Orders';
  static const String payments = 'Payments';
  static const String technical = 'Technical';
}

/// Sample FAQ Data
class SampleFAQData {
  static List<FAQItem> get items => [
    FAQItem(
      id: 'faq_001',
      question: 'What is AgroLink?',
      answer: 'AgroLink is a digital platform connecting farmers, buyers, transporters, and agricultural bureau officers in Ethiopia.',
      category: FAQCategory.general,
    ),
    FAQItem(
      id: 'faq_002',
      question: 'How do I create an account?',
      answer: 'Download the app, tap "Register", select your role, and complete the registration form.',
      category: FAQCategory.account,
    ),
    FAQItem(
      id: 'faq_003',
      question: 'I forgot my password',
      answer: 'On login screen, tap "Forgot Password", enter phone number, and follow OTP verification.',
      category: FAQCategory.account,
    ),
    FAQItem(
      id: 'faq_004',
      question: 'Can I have multiple roles?',
      answer: 'Yes! Switch between roles in Settings if you have multiple.',
      category: FAQCategory.account,
    ),
    FAQItem(
      id: 'faq_005',
      question: 'How do I change language?',
      answer: 'Go to Settings > Language, select English, አማርኛ, or Afaan Oromoo.',
      category: FAQCategory.technical,
    ),
  ];
}
