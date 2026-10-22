/// AgriLink Design Tokens
/// 
/// Standardized spacing, sizing, and elevation constants for consistent
/// UI implementation across the application. These tokens ensure:
/// - Proper touch targets for accessibility (minimum 48x48dp)
/// - Visual hierarchy through consistent spacing
/// - Material Design elevation patterns
/// - Predictable layout rhythms (4dp base unit)
/// 
/// **Design Philosophy**:
/// All spacing follows a 4dp base unit system, creating a harmonious
/// rhythm throughout the interface. This system:
/// - Reduces visual noise through predictable patterns
/// - Improves designer-developer handoff (designers work in 4dp increments)
/// - Ensures consistency across different screen densities
/// - Aligns with Material Design guidelines
/// 
/// **Usage Pattern**:
/// ```dart
/// // Always use tokens instead of hard-coded values
/// 
/// // ❌ WRONG
/// padding: EdgeInsets.all(16.0)
/// 
/// // ✅ CORRECT
/// padding: EdgeInsets.all(AppTokens.spaceM)
/// 
/// // This makes it easy to adjust spacing app-wide and
/// // communicates intent to other developers
/// ```
class AppTokens {
  // Private constructor to prevent instantiation
  AppTokens._();

  // ============================================================================
  // SPACING TOKENS - Layout and component spacing
  // ============================================================================
  // All spacing follows a 4dp base unit system for visual harmony

  /// Extra extra small spacing - 4dp (base unit)
  /// 
  /// **Use for**: 
  /// - Compact padding within chips and small badges
  /// - Minimal gaps between tightly grouped elements
  /// - Icon-to-icon spacing in toolbars
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Chip internal padding
  /// Chip(
  ///   padding: EdgeInsets.all(AppTokens.spaceXXS),
  ///   label: Text('New'),
  /// )
  /// ```
  static const double spaceXXS = 4.0;

  /// Extra small spacing - 8dp (2× base unit)
  /// 
  /// **Use for**: 
  /// - Icon-to-text gaps within buttons
  /// - Tight component padding
  /// - Space between radio buttons and labels
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Button with icon
  /// Row(
  ///   children: [
  ///     Icon(Icons.add),
  ///     SizedBox(width: AppTokens.spaceXS),
  ///     Text('Add Item'),
  ///   ],
  /// )
  /// ```
  static const double spaceXS = 8.0;

  /// Small spacing - 12dp (3× base unit)
  /// 
  /// **Use for**: 
  /// - Form field vertical spacing
  /// - Card inner padding
  /// - Compact list item spacing
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Form field gap
  /// Column(
  ///   children: [
  ///     TextField(),
  ///     SizedBox(height: AppTokens.spaceS),
  ///     TextField(),
  ///   ],
  /// )
  /// ```
  static const double spaceS = 12.0;

  /// Medium spacing - 16dp (4× base unit)
  /// 
  /// **Use for**: 
  /// - Standard padding (most common spacing)
  /// - List item spacing
  /// - Default gaps between sections
  /// - Screen edge margins on mobile
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Standard padding
  /// Container(
  ///   padding: EdgeInsets.all(AppTokens.spaceM),
  ///   child: content,
  /// )
  /// 
  /// // List item spacing
  /// ListView.separated(
  ///   separatorBuilder: (_, __) => SizedBox(height: AppTokens.spaceM),
  /// )
  /// ```
  /// 
  /// **Design Note**: This is the most frequently used spacing token
  static const double spaceM = 16.0;

  /// Large spacing - 20dp (5× base unit)
  /// 
  /// **Use for**: 
  /// - Card padding
  /// - Section spacing
  /// - Prominent gaps between content groups
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Card internal padding
  /// Card(
  ///   child: Padding(
  ///     padding: EdgeInsets.all(AppTokens.spaceL),
  ///     child: content,
  ///   ),
  /// )
  /// ```
  static const double spaceL = 20.0;

  /// Extra large spacing - 24dp (6× base unit)
  /// 
  /// **Use for**: 
  /// - Major section padding
  /// - Screen margins on tablet/desktop
  /// - Spacing between distinct UI sections
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Screen padding on tablet
  /// if (isTablet) {
  ///   padding = EdgeInsets.all(AppTokens.spaceXL);
  /// }
  /// ```
  static const double spaceXL = 24.0;

  /// 2X extra large spacing - 32dp (8× base unit)
  /// 
  /// **Use for**: 
  /// - Large gaps between major sections
  /// - Desktop screen margins
  /// - Prominent spacing in hero sections
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Desktop content margins
  /// Padding(
  ///   padding: EdgeInsets.symmetric(horizontal: AppTokens.spaceXXL),
  ///   child: content,
  /// )
  /// ```
  static const double spaceXXL = 32.0;

  /// 3X extra large spacing - 40dp (10× base unit)
  /// 
  /// **Use for**: 
  /// - Header spacing
  /// - Major layout divisions
  /// - Spacious dashboard sections
  static const double spaceXXXL = 40.0;

  /// 4X extra large spacing - 48dp (12× base unit)
  /// 
  /// **Use for**: 
  /// - Screen-level spacing
  /// - Major separations between distinct features
  /// - Large empty state padding
  static const double space4XL = 48.0;

  /// 5X extra large spacing - 64dp (16× base unit)
  /// 
  /// **Use for**: 
  /// - Large hero sections
  /// - Prominent empty states
  /// - Splash screen padding
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Empty state with generous padding
  /// Padding(
  ///   padding: EdgeInsets.all(AppTokens.space5XL),
  ///   child: EmptyStateWidget(),
  /// )
  /// ```
  static const double space5XL = 64.0;

  // ============================================================================
  // BORDER RADIUS TOKENS - Rounded corners for components
  // ============================================================================
  // Consistent rounding creates visual cohesion and modern aesthetic

  /// Extra small radius - 4dp
  /// 
  /// **Use for**: 
  /// - Small badges
  /// - Compact chips
  /// - Subtle rounding on very small elements
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Small badge
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: BorderRadius.circular(AppTokens.radiusXS),
  ///   ),
  /// )
  /// ```
  static const double radiusXS = 4.0;

  /// Small radius - 8dp
  /// 
  /// **Use for**: 
  /// - Buttons (standard rounding)
  /// - Input fields
  /// - Small cards
  /// - Tags and labels
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Button with standard rounding
  /// ElevatedButton(
  ///   style: ElevatedButton.styleFrom(
  ///     shape: RoundedRectangleBorder(
  ///       borderRadius: BorderRadius.circular(AppTokens.radiusS),
  ///     ),
  ///   ),
  /// )
  /// 
  /// // Text field
  /// TextField(
  ///   decoration: InputDecoration(
  ///     border: OutlineInputBorder(
  ///       borderRadius: BorderRadius.circular(AppTokens.radiusS),
  ///     ),
  ///   ),
  /// )
  /// ```
  /// 
  /// **Design Note**: Most common radius for interactive elements
  static const double radiusS = 8.0;

  /// Medium radius - 12dp
  /// 
  /// **Use for**: 
  /// - Standard cards
  /// - Dialogs
  /// - Bottom sheets
  /// - Container elements
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Card with medium rounding
  /// Card(
  ///   shape: RoundedRectangleBorder(
  ///     borderRadius: BorderRadius.circular(AppTokens.radiusM),
  ///   ),
  /// )
  /// ```
  static const double radiusM = 12.0;

  /// Large radius - 16dp
  /// 
  /// **Use for**: 
  /// - Large cards
  /// - Prominent containers
  /// - Feature showcases
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Large feature card
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: BorderRadius.circular(AppTokens.radiusL),
  ///   ),
  /// )
  /// ```
  static const double radiusL = 16.0;

  /// Extra large radius - 24dp
  /// 
  /// **Use for**: 
  /// - Hero cards
  /// - Major UI elements
  /// - Floating action buttons
  /// - Prominent decorative elements
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Hero dashboard card
  /// Container(
  ///   decoration: BoxDecoration(
  ///     borderRadius: BorderRadius.circular(AppTokens.radiusXL),
  ///   ),
  /// )
  /// ```
  static const double radiusXL = 24.0;

  /// Full radius - 999dp
  /// 
  /// **Use for**: 
  /// - Circular elements (avatars, profile pictures)
  /// - Pill-shaped buttons
  /// - Circular badges
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Circular avatar
  /// CircleAvatar(
  ///   radius: 40,
  ///   // Implicitly circular, but can use:
  /// )
  /// 
  /// // Pill button
  /// ElevatedButton(
  ///   style: ElevatedButton.styleFrom(
  ///     shape: RoundedRectangleBorder(
  ///       borderRadius: BorderRadius.circular(AppTokens.radiusFull),
  ///     ),
  ///   ),
  /// )
  /// ```
  /// 
  /// **Design Note**: Large value ensures perfect circular rounding
  static const double radiusFull = 999.0;

  // ============================================================================
  // ELEVATION TOKENS - Shadow depth for Material Design
  // ============================================================================

  /// No elevation - 0dp
  /// Use for: Flat surfaces, inline elements
  static const double elevationNone = 0.0;

  /// Extra small elevation - 2dp
  /// Use for: Subtle cards, hovering elements
  static const double elevationXS = 2.0;

  /// Small elevation - 4dp
  /// Use for: Standard cards, raised buttons
  static const double elevationS = 4.0;

  /// Medium elevation - 6dp
  /// Use for: Floating action button (resting), prominent cards
  static const double elevationM = 6.0;

  /// Large elevation - 8dp
  /// Use for: Navigation drawer, app bar (scrolled)
  static const double elevationL = 8.0;

  /// Extra large elevation - 12dp
  /// Use for: Floating action button (raised), modal bottom sheets
  static const double elevationXL = 12.0;

  /// 2X extra large elevation - 16dp
  /// Use for: Navigation drawers, modal dialogs
  static const double elevationXXL = 16.0;

  /// 3X extra large elevation - 24dp
  /// Use for: Full-screen dialogs, prominent modals
  static const double elevationXXXL = 24.0;

  // ============================================================================
  // ICON SIZE TOKENS - Consistent icon sizing
  // ============================================================================

  /// Extra small icon - 16dp
  /// Use for: Inline icons, small badges, compact UI
  static const double iconXS = 16.0;

  /// Small icon - 20dp
  /// Use for: List item icons, compact buttons
  static const double iconS = 20.0;

  /// Medium icon - 24dp
  /// Use for: Standard UI icons, toolbar icons, app bar actions
  static const double iconM = 24.0;

  /// Large icon - 32dp
  /// Use for: Feature icons, prominent action buttons
  static const double iconL = 32.0;

  /// Extra large icon - 40dp
  /// Use for: Hero icons, large feature illustrations
  static const double iconXL = 40.0;

  // ============================================================================
  // TOUCH TARGET TOKENS - Accessibility and usability
  // ============================================================================
  // Material Design and WCAG guidelines for interactive elements

  /// Minimum touch target size - 48x48dp
  /// 
  /// **Accessibility Standard**: Material Design and WCAG 2.1 Level AA
  /// require all interactive elements to be at least 48x48dp for users
  /// with motor impairments or larger fingers.
  /// 
  /// **Use for**: 
  /// - All buttons (minimum height)
  /// - All icons that act as buttons
  /// - List items (minimum height)
  /// - Checkboxes, radio buttons (with padding)
  /// - Any tap target
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Ensure button meets minimum touch target
  /// ElevatedButton(
  ///   style: ElevatedButton.styleFrom(
  ///     minimumSize: Size(88, AppTokens.minTouchTarget),
  ///   ),
  ///   child: Text('Submit'),
  /// )
  /// 
  /// // Icon button with proper touch target
  /// IconButton(
  ///   iconSize: AppTokens.iconM,
  ///   constraints: BoxConstraints(
  ///     minWidth: AppTokens.minTouchTarget,
  ///     minHeight: AppTokens.minTouchTarget,
  ///   ),
  ///   icon: Icon(Icons.delete),
  /// )
  /// 
  /// // List item with proper height
  /// ListTile(
  ///   minVerticalPadding: 12,
  ///   // Results in ~48dp total height
  /// )
  /// ```
  /// 
  /// **Critical**: Never make interactive elements smaller than this!
  static const double minTouchTarget = 48.0;

  /// Recommended touch target size - 56x56dp
  /// 
  /// **Use for**: 
  /// - Primary action buttons (more comfortable)
  /// - Floating action buttons
  /// - Important interactive elements
  /// 
  /// **Example Usage**:
  /// ```dart
  /// // Comfortable primary button
  /// ElevatedButton(
  ///   style: ElevatedButton.styleFrom(
  ///     minimumSize: Size(120, AppTokens.recommendedTouchTarget),
  ///   ),
  ///   child: Text('Add Produce'),
  /// )
  /// 
  /// // Floating action button (default size already 56dp)
  /// FloatingActionButton(
  ///   onPressed: onPressed,
  ///   child: Icon(Icons.add),
  /// )
  /// ```
  /// 
  /// **Design Note**: Provides extra comfort for frequently-used actions
  static const double recommendedTouchTarget = 56.0;

  // ============================================================================
  // SIZING TOKENS - Common component sizes
  // ============================================================================

  /// Avatar size small - 32dp
  static const double avatarS = 32.0;

  /// Avatar size medium - 40dp
  static const double avatarM = 40.0;

  /// Avatar size large - 56dp
  static const double avatarL = 56.0;

  /// Avatar size extra large - 80dp
  static const double avatarXL = 80.0;

  /// Button height small - 32dp
  static const double buttonHeightS = 32.0;

  /// Button height medium - 40dp
  static const double buttonHeightM = 40.0;

  /// Button height large - 48dp (meets minimum touch target)
  static const double buttonHeightL = 48.0;

  /// Input field height - 48dp (meets minimum touch target)
  static const double inputHeight = 48.0;

  /// App bar height - 56dp
  static const double appBarHeight = 56.0;

  /// Bottom navigation height - 56dp
  static const double bottomNavHeight = 56.0;

  // ============================================================================
  // DIVIDER TOKENS - Separator styling
  // ============================================================================

  /// Thin divider - 1dp
  static const double dividerThin = 1.0;

  /// Medium divider - 2dp
  static const double dividerMedium = 2.0;

  /// Thick divider - 4dp
  static const double dividerThick = 4.0;

  // ============================================================================
  // OPACITY TOKENS - Transparency levels
  // ============================================================================

  /// Disabled opacity - 38%
  static const double opacityDisabled = 0.38;

  /// Medium emphasis opacity - 60%
  static const double opacityMedium = 0.60;

  /// High emphasis opacity - 87%
  static const double opacityHigh = 0.87;

  /// Overlay light - 8%
  static const double overlayLight = 0.08;

  /// Overlay medium - 12%
  static const double overlayMedium = 0.12;

  /// Overlay dark - 16%
  static const double overlayDark = 0.16;
}
