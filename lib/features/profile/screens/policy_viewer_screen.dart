import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/models/policy_model.dart';
import '../../../core/services/policy_service.dart';
import '../../../core/providers/auth_provider.dart';

class PolicyViewerScreen extends StatefulWidget {
  final PolicyType policyType;
  final bool requireAcceptance;

  const PolicyViewerScreen({
    super.key,
    required this.policyType,
    this.requireAcceptance = false,
  });

  @override
  State<PolicyViewerScreen> createState() => _PolicyViewerScreenState();
}

class _PolicyViewerScreenState extends State<PolicyViewerScreen> {
  final PolicyService _policyService = PolicyService();
  final ScrollController _scrollController = ScrollController();
  
  PolicyModel? _policy;
  bool _isLoading = true;
  String? _error;
  bool _hasScrolledToBottom = false;
  bool _isAccepting = false;

  @override
  void initState() {
    super.initState();
    _loadPolicy();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = maxScroll * 0.9; // 90% scrolled

      if (currentScroll >= threshold && !_hasScrolledToBottom) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  Future<void> _loadPolicy() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final policy = widget.policyType == PolicyType.privacy
          ? await _policyService.getPrivacyPolicy()
          : await _policyService.getTermsOfService();

      if (mounted) {
        setState(() {
          _policy = policy;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _acceptPolicy() async {
    if (_policy == null) return;

    setState(() => _isAccepting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.user?.id ?? '';

      await _policyService.acceptPolicy(
        userId: userId,
        policyType: widget.policyType,
        version: _policy!.version,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getPolicyName()} accepted'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept policy: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  String _getPolicyName() {
    return widget.policyType == PolicyType.privacy
        ? 'Privacy Policy'
        : 'Terms of Service';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPolicyName()),
      ),
      body: _buildBody(),
      bottomNavigationBar: widget.requireAcceptance && _policy != null
          ? _buildAcceptButton()
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load policy',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!.contains('network') || _error!.contains('SocketException')
                  ? 'No internet connection'
                  : 'An error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _loadPolicy,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_policy == null) {
      return const Center(child: Text('No policy available'));
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Version and date info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Version ${_policy!.version}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Updated: ${_formatDate(_policy!.lastUpdated)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Policy content
          Text(
            _policy!.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 80), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildAcceptButton() {
    final canAccept = _hasScrolledToBottom && !_isAccepting;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_hasScrolledToBottom)
              Text(
                'Please scroll to the bottom to accept',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: canAccept ? _acceptPolicy : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isAccepting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Accept ${_getPolicyName()}'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
