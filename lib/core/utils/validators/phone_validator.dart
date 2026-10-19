/// Validator for phone number inputs
class PhoneValidator {
  /// Validate Ethiopian phone number format
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Ethiopian phone format: +251XXXXXXXXX (total 13 characters)
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');

    if (!RegExp(r'^\+251\d{9}$').hasMatch(cleaned)) {
      return 'Please enter a valid Ethiopian phone number (+251XXXXXXXXX)';
    }

    return null;
  }

  /// Format phone number for display
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length == 13 && cleaned.startsWith('+251')) {
      return '+251 ${cleaned.substring(4, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
    }
    return phone;
  }

  /// Mask phone number for security (+251***1234)
  static String maskPhone(String phone) {
    if (phone.length < 4) return phone;
    final start = phone.length > 7 ? phone.substring(0, 7) : phone.substring(0, phone.length - 4);
    final end = phone.substring(phone.length - 4);
    return '$start***$end';
  }
}
