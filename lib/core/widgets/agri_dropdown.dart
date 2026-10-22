import 'package:flutter/material.dart';
import '../theme/tokens.dart';

/// AgriDropdown - A reusable dropdown selector widget for AgriLink forms
///
/// This dropdown provides a consistent design for form selectors with support for:
/// - Floating label that animates on selection
/// - Validation with error messages
/// - Error state styling with red borders and error text
/// - Semantic labels for screen reader accessibility
/// - Accessible dropdown menu with proper spacing
/// - Consistent styling matching AgriTextField
/// - Custom hint text and dropdown items
///
/// **Usage Examples:**
///
/// ```dart
/// // Simple dropdown with label
/// AgriDropdown<String>(
///   label: 'Select Crop Type',
///   value: selectedCrop,
///   items: [
///     DropdownMenuItem(value: 'maize', child: Text('Maize')),
///     DropdownMenuItem(value: 'wheat', child: Text('Wheat')),
///     DropdownMenuItem(value: 'teff', child: Text('Teff')),
///   ],
///   onChanged: (value) => setState(() => selectedCrop = value),
/// )
///
/// // Dropdown with validation
/// AgriDropdown<String>(
///   label: 'Select Market',
///   value: selectedMarket,
///   items: marketItems,
///   onChanged: (value) => setState(() => selectedMarket = value),
///   validator: (value) {
///     if (value == null || value.isEmpty) {
///       return 'Please select a market';
///     }
///     return null;
///   },
/// )
///
/// // Dropdown with hint text
/// AgriDropdown<String>(
///   label: 'Payment Method',
///   hint: 'Choose payment method',
///   value: paymentMethod,
///   items: paymentItems,
///   onChanged: (value) => setState(() => paymentMethod = value),
/// )
///
/// // Disabled dropdown
/// AgriDropdown<String>(
///   label: 'Region',
///   value: region,
///   items: regionItems,
///   onChanged: null,
///   enabled: false,
/// )
/// ```
class AgriDropdown<T> extends StatelessWidget {
  /// The label text displayed above the dropdown (floats on selection)
  final String label;

  /// Optional hint text displayed inside the dropdown when no value is selected
  final String? hint;

  /// The currently selected value
  final T? value;

  /// List of dropdown menu items to display
  final List<DropdownMenuItem<T>> items;

  /// Callback when a value is selected
  /// Set to null to disable the dropdown
  final Function(T?)? onChanged;

  /// Validation function that returns error message or null if valid
  /// Called automatically by Form widget validation
  final String? Function(T?)? validator;

  /// Whether the dropdown is enabled
  final bool enabled;

  /// Focus node for managing dropdown focus
  final FocusNode? focusNode;

  /// Optional icon to display at the start of the dropdown
  final Widget? prefixIcon;

  /// Creates an AgriDropdown widget
  ///
  /// The [label] and [items] parameters are required.
  /// The dropdown automatically applies theme styling from AppTheme including
  /// border radius, colors, padding, and error styling.
  /// Semantic labels are automatically added for screen reader accessibility.
  const AgriDropdown({
    super.key,
    required this.label,
    this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: label,
      hint: hint ?? 'Select an option',
      button: true,
      enabled: enabled && onChanged != null,
      child: DropdownButtonFormField<T>(
        // Use initialValue instead of deprecated 'value'
        initialValue: value,
        items: items,
        focusNode: focusNode,
        onChanged: enabled ? onChanged : null,
        validator: validator,
        
        // Dropdown button styling
        icon: Icon(
          Icons.arrow_drop_down,
          color: enabled
              ? colorScheme.onSurface.withOpacity(0.6)
              : colorScheme.onSurface.withOpacity(0.38),
        ),
        
        // Dropdown menu styling
        menuMaxHeight: 300, // Limit menu height for scrollability
        elevation: 8,
        borderRadius: BorderRadius.circular(AppTokens.radiusM),
        dropdownColor: colorScheme.surface,
        
        // Item spacing and padding
        itemHeight: AppTokens.minTouchTarget, // Ensure accessible touch targets
        
        // Text styling
        style: theme.textTheme.bodyLarge?.copyWith(
          color: enabled ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.38),
        ),
        
        // Hint text styling
        hint: hint != null
            ? Text(
                hint!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
              )
            : null,
        
        // Decoration - matching AgriTextField styling
        decoration: InputDecoration(
          labelText: label,
          
          // Prefix icon with proper spacing
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(
                    left: AppTokens.spaceM,
                    right: AppTokens.spaceXS,
                  ),
                  child: prefixIcon,
                )
              : null,
          
          // Use theme's input decoration with consistent styling
          filled: true,
          fillColor: enabled
              ? colorScheme.surface
              : colorScheme.surfaceContainerHighest.withOpacity(0.5),
          
          // Content padding matching AgriTextField
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTokens.spaceM,
            vertical: AppTokens.spaceS,
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
          
          // Label styling - matching AgriTextField
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          
          // Floating label styling (when dropdown has focus or value)
          floatingLabelStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
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
          
          // Ensure minimum touch target for accessibility
          constraints: const BoxConstraints(
            minHeight: AppTokens.minTouchTarget,
          ),
        ),
        
        // Customize selected item display in the dropdown button
        selectedItemBuilder: (BuildContext context) {
          return items.map<Widget>((DropdownMenuItem<T> item) {
            return Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // Extract text from the item's child widget
                _extractTextFromWidget(item.child),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: enabled
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withOpacity(0.38),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  /// Helper method to extract text content from a widget
  /// Handles Text widgets and tries to extract text from other common widget types
  String _extractTextFromWidget(Widget widget) {
    if (widget is Text) {
      return widget.data ?? '';
    }
    // For complex widgets, return a generic representation
    // In production, you might want to add more specific handling
    return '';
  }
}
