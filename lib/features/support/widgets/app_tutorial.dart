import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class AppTutorial extends StatefulWidget {
  const AppTutorial({super.key});

  @override
  State<AppTutorial> createState() => _AppTutorialState();
}

class _AppTutorialState extends State<AppTutorial> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialPage> _pages = [
    TutorialPage(
      title: 'Welcome to AgroLink',
      description: 'Connect with farmers, buyers, and transporters across Ethiopia',
      icon: Icons.agriculture,
      color: AppColors.primary,
    ),
    TutorialPage(
      title: 'Registration',
      description: '1. Download the app\n2. Select your role\n3. Complete registration\n4. Wait for verification',
      icon: Icons.app_registration,
      color: AppColors.secondary,
    ),
    TutorialPage(
      title: 'For Farmers',
      description: '1. Add your farms\n2. Post produce listings\n3. Receive orders\n4. Track deliveries',
      icon: Icons.yard,
      color: AppColors.primaryDark,
    ),
    TutorialPage(
      title: 'For Buyers',
      description: '1. Browse marketplace\n2. Place orders\n3. Track shipments\n4. Leave reviews',
      icon: Icons.shopping_cart,
      color: AppColors.accent,
    ),
    TutorialPage(
      title: 'For Transporters',
      description: '1. View available jobs\n2. Accept transport requests\n3. Update delivery status\n4. Track earnings',
      icon: Icons.local_shipping,
      color: AppColors.secondaryLight,
    ),
    TutorialPage(
      title: 'For Bureau Officers',
      description: '1. Switch woreda if needed\n2. Review inspection requests\n3. Conduct inspections\n4. Track compliance',
      icon: Icons.verified_user,
      color: AppColors.tertiaryDark,
    ),
    TutorialPage(
      title: 'Quick Support',
      description: 'Need help? Call us or send WhatsApp message anytime!',
      icon: Icons.support_agent,
      color: AppColors.primary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _TutorialPageWidget(page: _pages[index]);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.secondary),
                    )
                  else
                    const SizedBox(),
                  if (_currentPage < _pages.length - 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TutorialPageWidget extends StatelessWidget {
  final TutorialPage page;

  const _TutorialPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: page.color,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: page.color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TutorialPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TutorialPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
