import 'package:flutter/foundation.dart';
import '../models/policy_model.dart';
import '../services/policy_service.dart';

class PolicyProvider extends ChangeNotifier {
  final PolicyService _policyService = PolicyService();

  PolicyModel? _privacyPolicy;
  PolicyModel? _termsOfService;
  
  Map<PolicyType, PolicyAcceptance?> _acceptances = {};

  PolicyModel? get privacyPolicy => _privacyPolicy;
  PolicyModel? get termsOfService => _termsOfService;

  Future<void> loadPolicies() async {
    try {
      _privacyPolicy = await _policyService.getPrivacyPolicy();
      _termsOfService = await _policyService.getTermsOfService();
      notifyListeners();
    } catch (e) {
      // Policies will remain null if loading fails
      debugPrint('Failed to load policies: $e');
    }
  }

  Future<void> loadAcceptances(String userId) async {
    try {
      final privacyAcceptance = await _policyService.getAcceptance(
        userId,
        PolicyType.privacy,
      );
      final termsAcceptance = await _policyService.getAcceptance(
        userId,
        PolicyType.terms,
      );

      _acceptances = {
        PolicyType.privacy: privacyAcceptance,
        PolicyType.terms: termsAcceptance,
      };
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load acceptances: $e');
    }
  }

  bool hasAcceptedPolicy(PolicyType type) {
    final acceptance = _acceptances[type];
    if (acceptance == null) return false;

    final policy = type == PolicyType.privacy ? _privacyPolicy : _termsOfService;
    if (policy == null) return true; // If no policy loaded, assume accepted

    return acceptance.version == policy.version;
  }

  bool get needsPolicyAcceptance {
    return !hasAcceptedPolicy(PolicyType.privacy) ||
        !hasAcceptedPolicy(PolicyType.terms);
  }

  Future<void> acceptPolicy(String userId, PolicyType type, String version) async {
    await _policyService.acceptPolicy(
      userId: userId,
      policyType: type,
      version: version,
    );

    _acceptances[type] = PolicyAcceptance(
      userId: userId,
      policyType: type,
      version: version,
      acceptedAt: DateTime.now(),
    );
    notifyListeners();
  }

  PolicyAcceptance? getAcceptance(PolicyType type) {
    return _acceptances[type];
  }
}
