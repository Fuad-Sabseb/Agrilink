import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/policy_model.dart';
import '../network/api_client.dart';

class PolicyService {
  final ApiClient _apiClient = ApiClient();
  static const String _cacheBoxName = 'policy_cache';

  Future<PolicyModel> getPrivacyPolicy() async {
    return _fetchPolicy(PolicyType.privacy, '/settings/privacy-policy');
  }

  Future<PolicyModel> getTermsOfService() async {
    return _fetchPolicy(PolicyType.terms, '/settings/terms-of-service');
  }

  Future<PolicyModel> _fetchPolicy(PolicyType type, String endpoint) async {
    try {
      final response = await _apiClient.get(endpoint);
      final policy = PolicyModel.fromJson(response.data as Map<String, dynamic>);
      
      // Cache the policy
      await _cachePolicy(type, policy);
      
      return policy;
    } catch (e) {
      // Return cached version if backend fails
      final cached = await _getCachedPolicy(type);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  Future<void> _cachePolicy(PolicyType type, PolicyModel policy) async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      await box.put(type.toString(), jsonEncode(policy.toJson()));
      await box.close();
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<PolicyModel?> _getCachedPolicy(PolicyType type) async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      final cached = box.get(type.toString());
      await box.close();
      
      if (cached != null) {
        return PolicyModel.fromJson(jsonDecode(cached as String) as Map<String, dynamic>);
      }
    } catch (e) {
      // Ignore cache errors
    }
    return null;
  }

  Future<void> acceptPolicy({
    required String userId,
    required PolicyType policyType,
    required String version,
  }) async {
    final acceptance = PolicyAcceptance(
      userId: userId,
      policyType: policyType,
      version: version,
      acceptedAt: DateTime.now(),
    );

    await _apiClient.post(
      '/users/policy-acceptance',
      data: acceptance.toJson(),
    );

    // Cache acceptance locally
    await _cacheAcceptance(acceptance);
  }

  Future<void> _cacheAcceptance(PolicyAcceptance acceptance) async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      final key = '${acceptance.userId}_${acceptance.policyType.toString()}_acceptance';
      await box.put(key, jsonEncode(acceptance.toJson()));
      await box.close();
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<PolicyAcceptance?> getAcceptance(String userId, PolicyType policyType) async {
    try {
      final box = await Hive.openBox(_cacheBoxName);
      final key = '${userId}_${policyType.toString()}_acceptance';
      final cached = box.get(key);
      await box.close();
      
      if (cached != null) {
        return PolicyAcceptance.fromJson(
          jsonDecode(cached as String) as Map<String, dynamic>,
        );
      }
    } catch (e) {
      // Ignore cache errors
    }
    return null;
  }

  Future<bool> hasAcceptedVersion(String userId, PolicyType policyType, String version) async {
    final acceptance = await getAcceptance(userId, policyType);
    return acceptance?.version == version;
  }
}
