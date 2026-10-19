import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/faq_item.dart';
import '../widgets/faq_list.dart';
import '../widgets/contact_support_form.dart';
import '../widgets/app_tutorial.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'FAQ', icon: Icon(Icons.question_answer)),
            Tab(text: 'Contact', icon: Icon(Icons.contact_support)),
            Tab(text: 'Tutorial', icon: Icon(Icons.school)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FAQList(items: SampleFAQData.items),
                const ContactSupportForm(),
                const AppTutorial(),
              ],
            ),
          ),
          if (_appVersion.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Version $_appVersion',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
