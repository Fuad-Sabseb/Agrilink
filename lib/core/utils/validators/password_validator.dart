/// Validator for password-related inputs
class PasswordValidator {
  static const int minLength = 8;

  /// Validate current password
  static String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  /// Validate new password with strength requirements
  static String? validateNewPassword(String? value, {String? currentPassword}) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }

    if (currentPassword != null && value == currentPassword) {
      return 'New password must be different from current password';
    }

    return null;
  }

  /// Validate confirm password matches
  static String? validateConfirmPassword(String? value, String? newPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != newPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Get list of password requirements with status
  static List<PasswordRequirement> getPasswordRequirements(String password) {
    return [
      PasswordRequirement(
        'At least $minLength characters',
        password.length >= minLength,
      ),
      PasswordRequirement(
        'One uppercase letter',
        RegExp(r'[A-Z]').hasMatch(password),
      ),
      PasswordRequirement(
        'One lowercase letter',
        RegExp(r'[a-z]').hasMatch(password),
      ),
      PasswordRequirement(
        'One number',
        RegExp(r'[0-9]').hasMatch(password),
      ),
      PasswordRequirement(
        'One special character',
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      ),
    ];
  }

  /// Calculate password strength
  static PasswordStrengthLevel calculateStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score < 3) return PasswordStrengthLevel.weak;
    if (score < 5) return PasswordStrengthLevel.medium;
    return PasswordStrengthLevel.strong;
  }
}

/// Password requirement with status
class PasswordRequirement {
  final String description;
  final bool isMet;

  PasswordRequirement(this.description, this.isMet);
}

/// Password strength levels
enum PasswordStrengthLevel {
  weak,
  medium,
  strong,
}
