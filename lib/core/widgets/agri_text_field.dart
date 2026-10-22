import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';

/// AgriTextField - A reusable text input field widget for AgriLink forms
///
/// This text field provides a consistent design for form inputs with support for:
/// - Floating label that animates on focus
/// - Hint text and validation with error messages
/// - Prefix and suffix widgets (icons, buttons, etc.)
/// - Error state styling with red borders and error text
/// - Multiline support with maxLines parameter
/// - Semantic labels for screen reader accessibility
/// - Input decoration theme from AppTheme
/// - Various keyboard types and input formatters
///
/// **Usage Examples:**
///
/// ```dart
/// // Simple text field with label
/// AgriTextField(
///   label: 'Farm Name',
///   hint: 'Enter your farm name',
/// )
///
/// // Text field with validation
/// AgriTextField(
///   label: 'Email Address',
///   hint: 'farmer@example.com',
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) {
///     if (value == null || value.isEmpty) {
///       return 'Email is required';
///     }
///     if (!value.contains('@')) {
///       return 'Please enter a valid email';
///     }
///     return null;
///   },
/// )
///
/// // Number input with prefix icon
/// AgriTextField(
///   label: 'Price per Kg',
///   hint: '0.00',
///   keyboardType: TextInputType.number,
///   prefix: Icon(Icons.attach_money),
/// )
///
/// // Password field with suffix toggle
/// AgriTextField(
///   label: 'Password',
///   obscureText: true,
///   suffix: IconButton(
///     icon: Icon(Icons.visibility),
///     onPressed: () => togglePasswordVisibility(),
///   ),
/// )
///
/// // Multiline text area
/// AgriTextField(
///   label: 'Description',
///   hint: 'Describe your produce',
///   maxLines: 4,
/// )
///
/// // Read-only field with suffix widget
/// AgriTextField(
///   label: 'Location',
///   readOnly: true,
///   suffix: Icon(Icons.location_on),
///   onTap: () => selectLocation(),
/// )
/// ```
class AgriTextField extends StatelessWidget {
  /// The label text displayed above the field (floats on focus)
  final String label;

  /// Optional hint text displayed inside the field when empty
  final String? hint;

  /// Controller for managing the text input value
  final TextEditingController? controller;

  /// Validation function that returns error message or null if valid
  /// Called automatically by Form widget validation
  final String? Function(String?)? validator;

  /// Keyboard type for specialized input (text, number, email, phone, etc.)
  final TextInputType? keyboardType;

  /// Whether to obscure the text (for password fields)
  final bool obscureText;

  /// Whether the field is read-only (useful for picker fields)
  final bool readOnly;

  /// Optional widget displayed at the start of the field (icons, etc.)
  final Widget? prefix;

  /// Optional widget displayed at the end of the field (buttons, icons, etc.)
  final Widget? suffix;

  /// Maximum number of lines for the input field
  /// Set to null for unlimited lines (auto-expanding)
  /// Set to 1 for single-line field (default)
  final int? maxLines;

  /// Minimum number of lines to display
  /// Useful for multiline fields to show initial height
  final int? minLines;

  /// Maximum length of input
  final int? maxLength;

  /// Input formatters to restrict or format input
  final List<TextInputFormatter>? inputFormatters;

  /// Callback when the field value changes
  final Function(String)? onChanged;

  /// Callback when the field is tapped
  final VoidCallback? onTap;

  /// Callback when editing is complete (user presses done/submit)
  final Function(String)? onSubmitted;

  /// Focus node for managing field focus
  final FocusNode? focusNode;

  /// Text capitalization behavior
  final TextCapitalization textCapitalization;

  /// Whether the field is enabled
  final bool enabled;

  /// Optional initial value when no controller is provided
  final String? initialValue;

  /// Text input action for keyboard button
  final TextInputAction? textInputAction;

  /// Whether to autocorrect input
  final bool autocorrect;

  /// Whether to enable suggestions
  final bool enableSuggestions;

  /// Creates an AgriTextField widget
  ///
  /// The [label] parameter is required.
  /// The field automatically applies theme styling from AppTheme including
  /// border radius, colors, padding, and error styling.
  /// Semantic labels are automatically added for screen reader accessibility.
  const AgriTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.initialValue,
    this.textInputAction,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate if this is a multiline field
    final isMultiline = maxLines == null || (maxLines != null && maxLines! > 1);

    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      enabled: enabled,
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        textInputAction: textInputAction,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        
        // Styling
        style: theme.textTheme.bodyLarge?.copyWith(
          color: enabled ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.38),
        ),
        
        // Decoration
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          
          // Prefix widget with proper spacing
          prefixIcon: prefix != null
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: AppTokens.spaceM,
                    right: AppTokens.spaceXS,
                  ),
                  child: prefix,
                )
              : null,
          
          // Suffix widget with proper spacing
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: AppTokens.spaceXS,
                    right: AppTokens.spaceM,
                  ),
                  child: suffix,
                )
              : null,
          
          // Use theme's input decoration with slight customization
          filled: true,
          fillColor: enabled
              ? colorScheme.surface
              : colorScheme.surfaceContainerHighest.withOpacity(0.5),
          
          // Content padding adjusted for multiline vs single line
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppTokens.spaceM,
            vertical: isMultiline ? AppTokens.spaceM : AppTokens.spaceS,
          ),
          
          // Border styling - normal state
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
            borderSide: BorderSide(
              color: colorScheme.outline,
              width: 1,
            ),
          ),
          
          // Border styling - enabled state
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
            borderSide: BorderSide(
              color: colorScheme.outline,
              width: 1,
            ),
          ),
          
          // Border styling - focused state
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          
          // Border styling - error state
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 1,
            ),
          ),
          
          // Border styling - focused error state
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 2,
            ),
          ),
          
          // Border styling - disabled state
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusS),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
          ),
          
          // Label styling
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          
          // Floating label styling (when field has focus or value)
          floatingLabelStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
          
          // Hint text styling
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          
          // Error text styling
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.error,
            fontSize: 12,
          ),
          
          // Error max lines
          errorMaxLines: 2,
          
          // Helper text styling (if needed)
          helperStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
          
          // Counter styling (for maxLength)
          counterStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
          
          // Ensure minimum touch target for accessibility
          constraints: BoxConstraints(
            minHeight: AppTokens.minTouchTarget,
          ),
        ),
        
        // Validation
        validator: validator,
        
        // Callbacks
        onChanged: onChanged,
        onTap: onTap,
        onFieldSubmitted: onSubmitted,
      ),
    );
  }
}
