import 'dart:math';

/// WCAG AA Contrast Ratio Checker for AgriLink Agricultural Earth-Tone Color System
/// 
/// This script verifies that all color combinations in the design system meet
/// WCAG AA accessibility standards:
/// - Normal text (< 18pt): minimum 4.5:1 contrast ratio
/// - Large text (≥ 18pt or 14pt bold): minimum 3:1 contrast ratio
/// - UI components and graphics: minimum 3:1 contrast ratio

void main() {
  print('═══════════════════════════════════════════════════════════════════════════');
  print('  WCAG AA Contrast Compliance Report');
  print('  AgriLink Agricultural Earth-Tone Color System');
  print('═══════════════════════════════════════════════════════════════════════════\n');
  
  final report = WCAGContrastReport();
  report.runFullAudit();
  report.printSummary();
}

class WCAGContrastReport {
  final List<ContrastTest> _tests = [];
  int _passCount = 0;
  int _failCount = 0;
  
  /// WCAG AA Standards
  static const double normalTextMinimum = 4.5;
  static const double largeTextMinimum = 3.0;
  static const double uiComponentMinimum = 3.0;
  
  void runFullAudit() {
    print('Running comprehensive contrast audit...\n');
    
    // Light Theme Tests
    _testLightTheme();
    
    // Dark Theme Tests
    _testDarkTheme();
    
    // Role-Specific Colors
    _testRoleColors();
    
    // Semantic Colors (Status & Feedback)
    _testSemanticColors();
    
    // UI Component Colors
    _testUIComponents();
    
    // Interactive Elements
    _testInteractiveElements();
  }
  
  void _testLightTheme() {
    _printSection('LIGHT THEME - Background & Surface Colors');
    
    // Primary text on light backgrounds
    _test('Primary text on Background (#F5F1E8)', 
          0xFF2C241E, 0xFFF5F1E8, TextType.normal);
    _test('Primary text on Surface (#FFFBF5)', 
          0xFF2C241E, 0xFFFFFBF5, TextType.normal);
    _test('Primary text on Surface Light (#FAF6EE)', 
          0xFF2C241E, 0xFFFAF6EE, TextType.normal);
    
    // Secondary text on light backgrounds
    _test('Secondary text on Background', 
          0xFF6B6258, 0xFFF5F1E8, TextType.normal);
    _test('Secondary text on Surface', 
          0xFF6B6258, 0xFFFFFBF5, TextType.normal);
    
    // Tertiary text on light backgrounds
    _test('Tertiary text on Background', 
          0xFF948A7E, 0xFFF5F1E8, TextType.normal);
    _test('Tertiary text on Surface', 
          0xFF948A7E, 0xFFFFFBF5, TextType.normal);
  }
  
  void _testDarkTheme() {
    _printSection('DARK THEME - Background & Surface Colors');
    
    // Light text on dark backgrounds
    _test('Primary text on Dark Background (#1B1916)', 
          0xFFF5F1E8, 0xFF1B1916, TextType.normal);
    _test('Primary text on Dark Surface (#24211D)', 
          0xFFF5F1E8, 0xFF24211D, TextType.normal);
    _test('Primary text on Dark Surface Highest (#2E2A24)', 
          0xFFF5F1E8, 0xFF2E2A24, TextType.normal);
    
    // Secondary text on dark backgrounds
    _test('Secondary text on Dark Background', 
          0xFFC4BCB0, 0xFF1B1916, TextType.normal);
    _test('Secondary text on Dark Surface', 
          0xFFC4BCB0, 0xFF24211D, TextType.normal);
    
    // Tertiary text on dark backgrounds
    _test('Tertiary text on Dark Background', 
          0xFF948A7E, 0xFF1B1916, TextType.normal);
    _test('Tertiary text on Dark Surface', 
          0xFF948A7E, 0xFF24211D, TextType.normal);
  }
  
  void _testRoleColors() {
    _printSection('ROLE-SPECIFIC COLORS');
    
    // Farmer (Rich Earth Green #3A7D44)
    _test('White text on Farmer Primary', 
          0xFFFFFFFF, 0xFF3A7D44, TextType.normal);
    _test('White text on Farmer Primary (Large)', 
          0xFFFFFFFF, 0xFF3A7D44, TextType.large);
    _test('Farmer Primary on Light Background', 
          0xFF3A7D44, 0xFFF5F1E8, TextType.normal);
    _test('Farmer Primary Light text on Background', 
          0xFF5C9B65, 0xFFF5F1E8, TextType.normal);
    
    // Buyer (Ethiopian Coffee Brown #8B5A3C)
    _test('White text on Buyer Primary', 
          0xFFFFFFFF, 0xFF8B5A3C, TextType.normal);
    _test('White text on Buyer Primary (Large)', 
          0xFFFFFFFF, 0xFF8B5A3C, TextType.large);
    _test('Buyer Primary on Light Background', 
          0xFF8B5A3C, 0xFFF5F1E8, TextType.normal);
    _test('Buyer Light text on Background', 
          0xFFA67C52, 0xFFF5F1E8, TextType.normal);
    
    // Transporter (Golden Harvest #D4AF37)
    _test('Dark text on Transporter Primary', 
          0xFF2C241E, 0xFFD4AF37, TextType.normal);
    _test('Dark text on Transporter Primary (Large)', 
          0xFF2C241E, 0xFFD4AF37, TextType.large);
    _test('White text on Transporter Primary', 
          0xFFFFFFFF, 0xFFD4AF37, TextType.normal);
    _test('Transporter Primary on Light Background', 
          0xFFD4AF37, 0xFFF5F1E8, TextType.normal);
    
    // Bureau Officer (Sky Blue #4A90E2)
    _test('White text on Bureau Primary', 
          0xFFFFFFFF, 0xFF4A90E2, TextType.normal);
    _test('White text on Bureau Primary (Large)', 
          0xFFFFFFFF, 0xFF4A90E2, TextType.large);
    _test('Bureau Primary on Light Background', 
          0xFF4A90E2, 0xFFF5F1E8, TextType.normal);
    _test('Bureau Light text on Background', 
          0xFF6BA4E8, 0xFFF5F1E8, TextType.normal);
  }
  
  void _testSemanticColors() {
    _printSection('SEMANTIC COLORS - Status & Feedback');
    
    // Success (Fresh Growth #7CB342)
    _test('White text on Success', 
          0xFFFFFFFF, 0xFF7CB342, TextType.normal);
    _test('Success on Light Background', 
          0xFF7CB342, 0xFFF5F1E8, TextType.normal);
    _test('Success Dark on Light Background', 
          0xFF558B2F, 0xFFF5F1E8, TextType.normal);
    
    // Warning (Orange #E07A24)
    _test('White text on Warning', 
          0xFFFFFFFF, 0xFFE07A24, TextType.normal);
    _test('Dark text on Warning', 
          0xFF2C241E, 0xFFE07A24, TextType.normal);
    _test('Warning on Light Background', 
          0xFFE07A24, 0xFFF5F1E8, TextType.normal);
    _test('Warning Dark on Light Background', 
          0xFFBF6A1C, 0xFFF5F1E8, TextType.normal);
    
    // Error (Red #C0392B)
    _test('White text on Error', 
          0xFFFFFFFF, 0xFFC0392B, TextType.normal);
    _test('Error on Light Background', 
          0xFFC0392B, 0xFFF5F1E8, TextType.normal);
    _test('Error Dark on Light Background', 
          0xFF8B2618, 0xFFF5F1E8, TextType.normal);
    
    // Info (Sky Blue #4A90E2)
    _test('White text on Info', 
          0xFFFFFFFF, 0xFF4A90E2, TextType.normal);
    _test('Info on Light Background', 
          0xFF4A90E2, 0xFFF5F1E8, TextType.normal);
  }
  
  void _testUIComponents() {
    _printSection('UI COMPONENTS - Borders, Disabled States');
    
    // Borders
    _test('Border on Light Background', 
          0xFFDDD6C9, 0xFFF5F1E8, TextType.ui);
    _test('Border Dark on Dark Background', 
          0xFF453F36, 0xFF1B1916, TextType.ui);
    _test('Border Dark Variant on Dark Surface', 
          0xFF38332C, 0xFF24211D, TextType.ui);
    
    // Disabled states
    _test('Disabled text on Light Background', 
          0xFFC4BCB0, 0xFFF5F1E8, TextType.normal);
    _test('Disabled text on Surface', 
          0xFFC4BCB0, 0xFFFFFBF5, TextType.normal);
  }
  
  void _testInteractiveElements() {
    _printSection('INTERACTIVE ELEMENTS - Buttons, Links, Actions');
    
    // Primary buttons
    _test('White text on Primary Button (#3A7D44)', 
          0xFFFFFFFF, 0xFF3A7D44, TextType.normal);
    _test('White text on Primary Dark Button', 
          0xFFFFFFFF, 0xFF2B5E34, TextType.normal);
    
    // Secondary buttons
    _test('White text on Secondary Button (#8B5A3C)', 
          0xFFFFFFFF, 0xFF8B5A3C, TextType.normal);
    _test('White text on Secondary Dark Button', 
          0xFFFF6B4429, 0xFF6B4429, TextType.normal);
    
    // Accent/Golden buttons
    _test('Dark text on Accent Button (#D4AF37)', 
          0xFF2C241E, 0xFFD4AF37, TextType.normal);
    _test('Dark text on Gold Light Button', 
          0xFF2C241E, 0xFFE5C048, TextType.normal);
    
    // Tertiary buttons
    _test('White text on Tertiary Button (#4A90E2)', 
          0xFFFFFFFF, 0xFF4A90E2, TextType.normal);
    _test('White text on Tertiary Dark Button', 
          0xFFFFFFFF, 0xFF1E3A5F, TextType.normal);
    
    // Container colors (Dark theme)
    _test('Text on Primary Container (Dark)', 
          0xFFD3E7D6, 0xFF224227, TextType.normal);
    _test('Text on Secondary Container (Dark)', 
          0xFFE8DDD5, 0xFF4A3425, TextType.normal);
    _test('Text on Tertiary Container (Dark)', 
          0xFFD6E8FD, 0xFF1E3A5F, TextType.normal);
    _test('Text on Error Container (Dark)', 
          0xFFFFCDD2, 0xFF5C1D1D, TextType.normal);
  }
  
  void _test(String description, int foregroundHex, int backgroundHex, TextType type) {
    final foreground = Color.fromHex(foregroundHex);
    final background = Color.fromHex(backgroundHex);
    final ratio = calculateContrastRatio(foreground, background);
    
    double minimumRatio;
    String standard;
    
    switch (type) {
      case TextType.normal:
        minimumRatio = normalTextMinimum;
        standard = 'Normal text (4.5:1)';
        break;
      case TextType.large:
        minimumRatio = largeTextMinimum;
        standard = 'Large text (3:1)';
        break;
      case TextType.ui:
        minimumRatio = uiComponentMinimum;
        standard = 'UI component (3:1)';
        break;
    }
    
    final passes = ratio >= minimumRatio;
    final test = ContrastTest(
      description: description,
      foreground: foreground,
      background: background,
      ratio: ratio,
      minimumRatio: minimumRatio,
      standard: standard,
      passes: passes,
    );
    
    _tests.add(test);
    if (passes) {
      _passCount++;
    } else {
      _failCount++;
    }
    
    _printTest(test);
  }
  
  void _printSection(String title) {
    print('\n${'─' * 79}');
    print('  $title');
    print('${'─' * 79}');
  }
  
  void _printTest(ContrastTest test) {
    final statusIcon = test.passes ? '✓' : '✗';
    final statusColor = test.passes ? 'PASS' : 'FAIL';
    final ratioStr = test.ratio.toStringAsFixed(2);
    
    print('$statusIcon [$statusColor] ${test.description}');
    print('  Contrast: $ratioStr:1 (min: ${test.minimumRatio}:1 for ${test.standard})');
    print('  Foreground: ${test.foreground.toHex()} | Background: ${test.background.toHex()}');
    if (!test.passes) {
      final shortfall = test.minimumRatio - test.ratio;
      print('  ⚠️  ACCESSIBILITY ISSUE: Shortfall of ${shortfall.toStringAsFixed(2)}:1');
    }
    print('');
  }
  
  void printSummary() {
    final separator = '═' * 79;
    print('\n$separator');
    print('  SUMMARY');
    print('$separator\n');
    
    final total = _passCount + _failCount;
    final passPercentage = (_passCount / total * 100).toStringAsFixed(1);
    
    print('Total Tests: $total');
    print('Passed: $_passCount ($_passCount/$total = $passPercentage%)');
    print('Failed: $_failCount');
    print('');
    
    if (_failCount > 0) {
      print('⚠️  WCAG AA COMPLIANCE: PARTIAL');
      print('The following color combinations need attention:\n');
      
      for (final test in _tests.where((t) => !t.passes)) {
        print('• ${test.description}');
        print('  Current: ${test.ratio.toStringAsFixed(2)}:1 | Required: ${test.minimumRatio}:1');
      }
      
      print('\nRecommendations:');
      print('1. Adjust color luminance to meet minimum contrast ratios');
      print('2. Consider using darker shades for text on light backgrounds');
      print('3. Consider using lighter shades for text on dark backgrounds');
      print('4. Test with real users and accessibility tools');
    } else {
      print('✓ WCAG AA COMPLIANCE: FULL');
      print('All tested color combinations meet or exceed WCAG AA standards.');
    }
    
    print('\n$separator');
    print('Report generated: ${DateTime.now()}');
    print('$separator\n');
  }
  
  /// Calculate contrast ratio between two colors
  /// Formula from WCAG 2.1: (L1 + 0.05) / (L2 + 0.05)
  /// where L1 is the lighter color and L2 is the darker color
  double calculateContrastRatio(Color foreground, Color background) {
    final l1 = foreground.relativeLuminance();
    final l2 = background.relativeLuminance();
    
    final lighter = max(l1, l2);
    final darker = min(l1, l2);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
}

enum TextType {
  normal,  // Normal text < 18pt
  large,   // Large text ≥ 18pt or 14pt bold
  ui,      // UI components and graphics
}

class ContrastTest {
  final String description;
  final Color foreground;
  final Color background;
  final double ratio;
  final double minimumRatio;
  final String standard;
  final bool passes;
  
  ContrastTest({
    required this.description,
    required this.foreground,
    required this.background,
    required this.ratio,
    required this.minimumRatio,
    required this.standard,
    required this.passes,
  });
}

class Color {
  final int r, g, b;
  
  Color(this.r, this.g, this.b);
  
  factory Color.fromHex(int hex) {
    return Color(
      (hex >> 16) & 0xFF,
      (hex >> 8) & 0xFF,
      hex & 0xFF,
    );
  }
  
  String toHex() {
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}'.toUpperCase();
  }
  
  /// Calculate relative luminance using WCAG formula
  /// https://www.w3.org/WAI/GL/wiki/Relative_luminance
  double relativeLuminance() {
    final rs = _sRGBtoLinear(r / 255.0);
    final gs = _sRGBtoLinear(g / 255.0);
    final bs = _sRGBtoLinear(b / 255.0);
    
    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
  }
  
  double _sRGBtoLinear(double c) {
    if (c <= 0.03928) {
      return c / 12.92;
    } else {
      return pow((c + 0.055) / 1.055, 2.4).toDouble();
    }
  }
}
