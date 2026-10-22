import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// A reusable button widget following the Agricultural Earth-Tone design system.
///
/// The AgriButton supports three variants:
/// - Primary: Filled button with primary color background
/// - Secondary: Outlined button with transparent background
/// - Text: Text-only button with no background or border
///
/// Features:
/// - Loading state with CircularProgressIndicator
/// - Optional icon support
/// - Minimum 48x48dp touch target for accessibility
/// - Semantic labels for screen readers
/// - Theme-aware colors from AppColors
///
/// ## Usage Examples
///
/// ### Primary Button (Default)
/// Use primary buttons for the main call-to-action on a screen. These have the
/// highest visual emphasis and should be used sparingly.
///
/// ```dart
/// // Basic primary button
/// AgriButton(
///   text: 'Submit',
///   onPressed: () {
///     // Handle submit
///   },
/// )
///
/// // Primary button with icon
/// AgriButton.primary(
///   text: 'Add Produce',
///   icon: Icons.add,
///   onPressed: () {
///     // Navigate to add produce screen
///   },
/// )
///
/// // Primary button with custom color (for role-specific actions)
/// AgriButton.primary(
///   text: 'Schedule Inspection',
///   icon: Icons.verified,
///   customColor: AppColors.roleBureau,
///   onPressed: () {
///     // Handle inspection scheduling
///   },
/// )
/// ```
///
/// ### Secondary Button
/// Use secondary buttons for important but not primary actions. These have medium
/// visual emphasis and work well alongside primary buttons or in cards.
///
/// ```dart
/// // Basic secondary button
/// AgriButton.secondary(
///   text: 'Cancel',
///   onPressed: () {
///     Navigator.pop(context);
///   },
/// )
///
/// // Secondary button with icon
/// AgriButton.secondary(
///   text: 'View Details',
///   icon: Icons.arrow_forward,
///   onPressed: () {
///     // Navigate to details screen
///   },
/// )
///
/// // Use in action cards for secondary actions
/// AgriButton.secondary(
///   text: 'Learn More',
///   onPressed: () {
///     // Show information dialog
///   },
/// )
/// ```
///
/// ### Text Button
/// Use text buttons for the lowest-priority actions or when you need many actions
/// in close proximity (like in toolbars or dialogs).
///
/// ```dart
/// // Basic text button
/// AgriButton.text(
///   text: 'Skip',
///   onPressed: () {
///     // Handle skip action
///   },
/// )
///
/// // Text button in dialog
/// AlertDialog(
///   title: Text('Confirm Action'),
///   content: Text('Are you sure?'),
///   actions: [
///     AgriButton.text(
///       text: 'Cancel',
///       onPressed: () => Navigator.pop(context),
///     ),
///     AgriButton.text(
///       text: 'Confirm',
///       customColor: AppColors.error,
///       onPressed: () {
///         // Handle confirmation
///         Navigator.pop(context);
///       },
///     ),
///   ],
/// )
/// ```
///
/// ### Loading State Pattern
/// Use the loading state during async operations to provide visual feedback and
/// prevent duplicate submissions.
///
/// ```dart
/// class SubmitFormExample extends StatefulWidget {
///   @override
///   State<SubmitFormExample> createState() => _SubmitFormExampleState();
/// }
///
/// class _SubmitFormExampleState extends State<SubmitFormExample> {
///   bool _isSubmitting = false;
///
///   Future<void> _handleSubmit() async {
///     setState(() {
///       _isSubmitting = true;
///     });
///
///     try {
///       // Perform async operation (API call, database save, etc.)
///       await apiService.submitForm();
///
///       // Show success message
///       if (mounted) {
///         ScaffoldMessenger.of(context).showSnackBar(
///           SnackBar(content: Text('Submitted successfully')),
///         );
///       }
///     } catch (error) {
///       // Handle error
///       if (mounted) {
///         ScaffoldMessenger.of(context).showSnackBar(
///           SnackBar(content: Text('Error: $error')),
///         );
///       }
///     } finally {
///       if (mounted) {
///         setState(() {
///           _isSubmitting = false;
///         });
///       }
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return AgriButton(
///       text: 'Submit',
///       isLoading: _isSubmitting,
///       onPressed: _isSubmitting ? null : _handleSubmit,
///     );
///   }
/// }
/// ```
///
/// ### When to Use Each Variant
///
/// **Primary Buttons** - Use for:
/// - Main form submission (Submit, Save, Create)
/// - Critical actions in hero cards (Where Should I Sell?, Add Produce)
/// - Confirmation of important operations
/// - One primary button per screen section recommended
///
/// **Secondary Buttons** - Use for:
/// - Navigation actions (View Details, Browse More)
/// - Cancellation or alternative actions
/// - Actions in cards alongside primary buttons
/// - Multiple actions of similar importance
///
/// **Text Buttons** - Use for:
/// - Dialog actions (OK, Cancel, Dismiss)
/// - Tertiary navigation (Skip, Learn More)
/// - Toolbar actions where space is limited
/// - Low-priority actions that shouldn't distract from primary content
class AgriButton extends StatelessWidget {
  /// The text to display on the button
  final String text;

  /// Callback function when button is pressed
  final VoidCallback? onPressed;

  /// Button variant: true for primary (filled), false for secondary (outlined)
  /// Use [isTextButton] for text-only variant
  final bool isPrimary;

  /// Whether the button is in loading state
  final bool isLoading;

  /// Optional icon to display before the text
  final IconData? icon;

  /// Custom color override for the button
  /// If not provided, uses theme colors from AppColors
  final Color? customColor;

  /// Whether this is a text-only button (no background or border)
  final bool isTextButton;

  const AgriButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
    this.customColor,
    this.isTextButton = false,
  });

  /// Creates a primary (filled) button
  const AgriButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.customColor,
  })  : isPrimary = true,
        isTextButton = false;

  /// Creates a secondary (outlined) button
  const AgriButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.customColor,
  })  : isPrimary = false,
        isTextButton = false;

  /// Creates a text-only button
  const AgriButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.customColor,
  })  : isPrimary = false,
        isTextButton = true;

  @override
  Widget build(BuildContext context) {
    // Determine if button should be disabled
    final bool isDisabled = onPressed == null || isLoading;

    // Build the button content (icon + text or loading indicator)
    final Widget buttonContent = _buildButtonContent();

    // Build semantic wrapper for accessibility
    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: text,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 48.0, // Minimum touch target width
          minHeight: 48.0, // Minimum touch target height
        ),
        child: _buildButton(context, buttonContent, isDisabled),
      ),
    );
  }

  /// Builds the appropriate button widget based on variant
  Widget _buildButton(BuildContext context, Widget content, bool isDisabled) {
    if (isTextButton) {
      return TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: _buildTextButtonStyle(context),
        child: content,
      );
    } else if (isPrimary) {
      return ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: _buildPrimaryButtonStyle(context),
        child: content,
      );
    } else {
      return OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: _buildSecondaryButtonStyle(context),
        child: content,
      );
    }
  }

  /// Builds the button content (icon + text or loading indicator)
  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        height: 20.0,
        width: 20.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            isTextButton
                ? (customColor ?? AppColors.primary)
                : (isPrimary ? Colors.white : (customColor ?? AppColors.primary)),
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20.0),
          const SizedBox(width: 8.0),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Builds the style for primary (filled) button
  ButtonStyle _buildPrimaryButtonStyle(BuildContext context) {
    final Color buttonColor = customColor ?? AppColors.primary;

    return ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: Colors.white,
      disabledBackgroundColor: buttonColor.withValues(alpha: 0.38),
      disabledForegroundColor: Colors.white.withValues(alpha: 0.38),
      elevation: 2.0,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 12.0,
      ),
      minimumSize: const Size(48.0, 48.0),
    );
  }

  /// Builds the style for secondary (outlined) button
  ButtonStyle _buildSecondaryButtonStyle(BuildContext context) {
    final Color buttonColor = customColor ?? AppColors.primary;

    return OutlinedButton.styleFrom(
      foregroundColor: buttonColor,
      disabledForegroundColor: buttonColor.withValues(alpha: 0.38),
      side: BorderSide(
        color: buttonColor,
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 12.0,
      ),
      minimumSize: const Size(48.0, 48.0),
    );
  }

  /// Builds the style for text-only button
  ButtonStyle _buildTextButtonStyle(BuildContext context) {
    final Color buttonColor = customColor ?? AppColors.primary;

    return TextButton.styleFrom(
      foregroundColor: buttonColor,
      disabledForegroundColor: buttonColor.withValues(alpha: 0.38),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
      minimumSize: const Size(48.0, 48.0),
    );
  }
}
