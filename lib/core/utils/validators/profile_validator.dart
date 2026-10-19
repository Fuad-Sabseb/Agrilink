/// Validator for profile-related inputs
class ProfileValidator {
  /// Validate full name
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 100) {
      return 'Name must not exceed 100 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validate location
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    if (value.trim().length < 2) {
      return 'Location must be at least 2 characters';
    }
    if (value.length > 100) {
      return 'Location must not exceed 100 characters';
    }
    return null;
  }
}
