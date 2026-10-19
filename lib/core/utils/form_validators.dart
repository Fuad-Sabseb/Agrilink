/// Form Validators
/// Reusable validation functions for form inputs
class FormValidators {
  FormValidators._();

  // ==================== BASIC VALIDATORS ====================

  /// Required field validator
  static String? required(dynamic value, {String? fieldName}) {
    if (value == null ||
        (value is String && value.trim().isEmpty) ||
        (value is List && value.isEmpty)) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Minimum length validator
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }
    return null;
  }

  /// Maximum length validator
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;
    if (value.length > max) {
      return '${fieldName ?? 'This field'} must not exceed $max characters';
    }
    return null;
  }

  // ==================== PHONE NUMBER VALIDATORS ====================

  /// Ethiopian phone number validator
  /// Accepts formats: +251XXXXXXXXX, 251XXXXXXXXX, 09XXXXXXXX, 07XXXXXXXX
  static String? phoneNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    // Remove spaces and dashes
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');

    // Ethiopian phone patterns
    final patterns = [
      RegExp(r'^\+251[79]\d{8}$'), // +251XXXXXXXXX
      RegExp(r'^251[79]\d{8}$'), // 251XXXXXXXXX
      RegExp(r'^0[79]\d{8}$'), // 09XXXXXXXX or 07XXXXXXXX
    ];

    if (!patterns.any((pattern) => pattern.hasMatch(cleaned))) {
      return 'Please enter a valid Ethiopian phone number';
    }

    return null;
  }

  /// International phone number validator (basic)
  static String? internationalPhone(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    final pattern = RegExp(r'^\+?\d{10,15}$');

    if (!pattern.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // ==================== EMAIL VALIDATORS ====================

  /// Email validator
  static String? email(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final pattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!pattern.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // ==================== NUMBER VALIDATORS ====================

  /// Number validator (integer or decimal)
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    return null;
  }

  /// Integer validator
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a whole number';
    }

    return null;
  }

  /// Minimum value validator
  static String? min(String? value, double min, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null) return 'Please enter a valid number';

    if (number < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }

    return null;
  }

  /// Maximum value validator
  static String? max(String? value, double max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null) return 'Please enter a valid number';

    if (number > max) {
      return '${fieldName ?? 'Value'} must not exceed $max';
    }

    return null;
  }

  /// Range validator
  static String? range(String? value, double min, double max,
      {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null) return 'Please enter a valid number';

    if (number < min || number > max) {
      return '${fieldName ?? 'Value'} must be between $min and $max';
    }

    return null;
  }

  /// Positive number validator
  static String? positive(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    final number = double.tryParse(value);
    if (number == null) return 'Please enter a valid number';

    if (number <= 0) {
      return '${fieldName ?? 'Value'} must be greater than zero';
    }

    return null;
  }

  // ==================== AGRICULTURE-SPECIFIC VALIDATORS ====================

  /// Quantity validator (kg, quintals, tons)
  static String? quantity(String? value, {String? fieldName}) {
    final error = positive(value, fieldName: fieldName);
    if (error != null) return error;

    final number = double.parse(value!);
    if (number > 1000000) {
      return 'Quantity seems unreasonably large. Please verify.';
    }

    return null;
  }

  /// Price validator (ETB)
  static String? price(String? value, {String? fieldName}) {
    final error = positive(value, fieldName: fieldName);
    if (error != null) return error;

    final number = double.parse(value!);
    if (number > 100000) {
      return 'Price seems unreasonably high. Please verify.';
    }

    return null;
  }

  /// Hectares validator
  static String? hectares(String? value, {String? fieldName}) {
    final error = positive(value, fieldName: fieldName ?? 'Hectares');
    if (error != null) return error;

    final number = double.parse(value!);
    if (number > 10000) {
      return 'Area seems unreasonably large. Please verify.';
    }

    return null;
  }

  /// Yield validator (kg per hectare)
  static String? yieldPerHectare(String? value, {String? fieldName}) {
    final error = positive(value, fieldName: fieldName ?? 'Yield');
    if (error != null) return error;

    final number = double.parse(value!);
    if (number > 50000) {
      return 'Yield seems unreasonably high. Please verify.';
    }

    return null;
  }

  // ==================== DATE VALIDATORS ====================

  /// Date validator (not in future)
  static String? pastDate(DateTime? value, {String? fieldName}) {
    if (value == null) return null;

    if (value.isAfter(DateTime.now())) {
      return '${fieldName ?? 'Date'} cannot be in the future';
    }

    return null;
  }

  /// Date validator (not in past)
  static String? futureDate(DateTime? value, {String? fieldName}) {
    if (value == null) return null;

    if (value.isBefore(DateTime.now())) {
      return '${fieldName ?? 'Date'} cannot be in the past';
    }

    return null;
  }

  /// Date range validator
  static String? dateAfter(DateTime? value, DateTime after,
      {String? fieldName}) {
    if (value == null) return null;

    if (value.isBefore(after)) {
      return '${fieldName ?? 'Date'} must be after ${after.day}/${after.month}/${after.year}';
    }

    return null;
  }

  /// Harvest date validator (reasonable range)
  static String? harvestDate(DateTime? value, {String? fieldName}) {
    if (value == null) return null;

    final now = DateTime.now();
    final minDate = now.subtract(const Duration(days: 30)); // 1 month ago
    final maxDate = now.add(const Duration(days: 365)); // 1 year ahead

    if (value.isBefore(minDate) || value.isAfter(maxDate)) {
      return 'Harvest date should be within 1 month past to 1 year future';
    }

    return null;
  }

  // ==================== COMPOSITE VALIDATORS ====================

  /// Combine multiple validators
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Required email validator
  static String? requiredEmail(String? value) {
    return required(value, fieldName: 'Email') ?? email(value);
  }

  /// Required phone validator
  static String? requiredPhone(String? value) {
    return required(value, fieldName: 'Phone number') ?? phoneNumber(value);
  }

  /// Required positive number
  static String? requiredPositive(String? value, {String? fieldName}) {
    return required(value, fieldName: fieldName) ??
        positive(value, fieldName: fieldName);
  }

  /// Required quantity
  static String? requiredQuantity(String? value) {
    return required(value, fieldName: 'Quantity') ?? quantity(value);
  }

  /// Required price
  static String? requiredPrice(String? value) {
    return required(value, fieldName: 'Price') ?? price(value);
  }

  // ==================== CUSTOM VALIDATORS ====================

  /// Custom pattern validator
  static String? pattern(String? value, RegExp pattern, String message) {
    if (value == null || value.isEmpty) return null;

    if (!pattern.hasMatch(value)) {
      return message;
    }

    return null;
  }

  /// Match validator (e.g., password confirmation)
  static String? match(String? value, String? other, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value != other) {
      return '${fieldName ?? 'Values'} do not match';
    }

    return null;
  }
}

/// Extension for easier validator composition
extension ValidatorExtension on String? Function(String?) {
  /// Chain validators together
  String? Function(String?) and(String? Function(String?) other) {
    return (value) {
      final error = this(value);
      if (error != null) return error;
      return other(value);
    };
  }

  /// Apply validator only if condition is true
  String? Function(String?) when(bool condition) {
    return (value) {
      if (!condition) return null;
      return this(value);
    };
  }
}
