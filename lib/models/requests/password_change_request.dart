/// Request model for changing password
/// SECURITY: Never log or expose password values
class PasswordChangeRequest {
  final String currentPassword;
  final String newPassword;

  PasswordChangeRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }

  /// Secure toString - never expose passwords
  @override
  String toString() => 'PasswordChangeRequest{***}';
}
