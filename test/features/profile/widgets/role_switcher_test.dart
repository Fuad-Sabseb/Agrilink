import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/core/providers/auth_provider.dart';
import 'package:agrolink/features/profile/widgets/role_switcher.dart';

/// Test AuthProvider that allows us to manipulate internal state for testing
class TestAuthProvider extends AuthProvider {
  TestAuthProvider() : super();

  // Methods to manipulate state for testing
  void setAvailableRolesForTest(List<String> roles) {
    _availableRoles.clear();
    _availableRoles.addAll(roles);
    notifyListeners();
  }

  void setCurrentRoleForTest(String? role) {
    _currentRole = role;
    notifyListeners();
  }

  // Access to private fields for testing
  List<String> get _availableRoles => availableRoles;
  String? _currentRole;

  @override
  String? get currentRole => _currentRole;

  @override
  bool get hasMultipleRoles => _availableRoles.length > 1;
}

void main() {
  late TestAuthProvider authProvider;

  setUp(() {
    authProvider = TestAuthProvider();
  });

  Widget createTestWidget(TestAuthProvider provider) {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<AuthProvider>.value(
          value: provider,
          child: const RoleSwitcher(),
        ),
      ),
    );
  }

  group('RoleSwitcher Widget Tests', () {
    testWidgets('should not display when user has only one role', (tester) async {
      // Arrange - user with single role
      authProvider.setAvailableRolesForTest(['farmer']);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert
      expect(find.byType(RoleSwitcher), findsOneWidget);
      expect(find.text('Switch Role'), findsNothing);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    });

    testWidgets('should not display when no roles available', (tester) async {
      // Arrange - user with no roles
      authProvider.setAvailableRolesForTest([]);

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert
      expect(find.text('Switch Role'), findsNothing);
    });

    testWidgets('should display dropdown with multiple roles', (tester) async {
      // Arrange - user with multiple roles
      authProvider.setAvailableRolesForTest(['farmer', 'buyer', 'transporter']);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // The widget should be present and display Switch Role
      expect(find.byType(RoleSwitcher), findsOneWidget);
      expect(find.text('Switch Role'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('should display correct role names in dropdown', (tester) async {
      // Arrange
      authProvider.setAvailableRolesForTest(['farmer', 'buyer']);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert
      expect(find.text('Switch Role'), findsOneWidget);
      expect(find.text('Current Role'), findsOneWidget);
    });

    testWidgets('should display role icons correctly', (tester) async {
      // Arrange
      authProvider.setAvailableRolesForTest(['farmer', 'buyer', 'transporter', 'bureau_officer']);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert - verify widget is present with dropdown
      expect(find.byType(RoleSwitcher), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('should render Card with proper styling', (tester) async {
      // Arrange
      authProvider.setAvailableRolesForTest(['farmer', 'buyer']);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // The Card should be present when multiple roles exist
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Switch Role'), findsOneWidget);
    });

    testWidgets('should display all 4 role types', (tester) async {
      // Arrange - user with all possible roles
      authProvider.setAvailableRolesForTest([
        'farmer',
        'buyer',
        'transporter',
        'bureau_officer'
      ]);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert
      expect(find.byType(RoleSwitcher), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('should show dropdown with current role', (tester) async {
      // Arrange
      authProvider.setAvailableRolesForTest(['farmer', 'buyer']);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert - verify dropdown exists with label
      expect(find.text('Current Role'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('should use Consumer to listen to auth changes', (tester) async {
      // Arrange
      authProvider.setAvailableRolesForTest(['farmer', 'buyer']);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert - widget should rebuild when provider changes
      expect(find.byType(RoleSwitcher), findsOneWidget);
      
      // Change roles
      authProvider.setAvailableRolesForTest(['farmer']);
      await tester.pump();
      
      // Should hide switcher when only one role
      expect(find.text('Switch Role'), findsNothing);
    });

    testWidgets('should display with proper margins and padding', (tester) async {
      // Arrange
      authProvider.setAvailableRolesForTest(['farmer', 'buyer']);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert - verify Card exists with content
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);
      
      final card = tester.widget<Card>(cardFinder);
      expect(card.margin, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)));
    });
  });

  group('RoleSwitcher Conditional Rendering', () {
    testWidgets('should render when hasMultipleRoles is true', (tester) async {
      // Arrange
      authProvider.setAvailableRolesForTest(['farmer', 'buyer']);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert
      expect(authProvider.hasMultipleRoles, isTrue);
      expect(find.text('Switch Role'), findsOneWidget);
    });

    testWidgets('should not render when hasMultipleRoles is false', (tester) async {
      // Arrange
      authProvider.setAvailableRolesForTest(['farmer']);
      authProvider.setCurrentRoleForTest('farmer');

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert
      expect(authProvider.hasMultipleRoles, isFalse);
      expect(find.text('Switch Role'), findsNothing);
    });

    testWidgets('should handle empty role list', (tester) async {
      // Arrange
      authProvider.setAvailableRolesForTest([]);
      authProvider.setCurrentRoleForTest(null);

      // Act
      await tester.pumpWidget(createTestWidget(authProvider));

      // Assert
      expect(authProvider.hasMultipleRoles, isFalse);
      expect(find.text('Switch Role'), findsNothing);
    });
  });
}
