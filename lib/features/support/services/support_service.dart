import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';

class SupportService {
  final ApiClient _apiClient = ApiClient();

  Future<void> sendSupportRequest({
    required String subject,
    required String message,
    required String phone,
  }) async {
    try {
      await _apiClient.post(
        '/support/contact',
        data: {
          'subject': subject,
          'message': message,
          'phone': phone,
        },
      );
    } catch (e) {
      // Save message locally if network fails
      if (e.toString().contains('network') || e.toString().contains('SocketException')) {
        await _saveOfflineMessage(subject, message, phone);
        throw Exception('network_error');
      }
      rethrow;
    }
  }

  Future<void> _saveOfflineMessage(String subject, String message, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final messages = prefs.getStringList('offline_support_messages') ?? [];
    messages.add(jsonEncode({
      'subject': subject,
      'message': message,
      'phone': phone,
      'timestamp': DateTime.now().toIso8601String(),
    }));
    await prefs.setStringList('offline_support_messages', messages);
  }

  Future<List<Map<String, dynamic>>> getOfflineMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messages = prefs.getStringList('offline_support_messages') ?? [];
    return messages.map((msg) => jsonDecode(msg) as Map<String, dynamic>).toList();
  }

  Future<void> clearOfflineMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('offline_support_messages');
  }
}
