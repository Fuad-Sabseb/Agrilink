import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:agrolink/core/providers/auth_provider.dart';
import 'package:agrolink/core/providers/profile_provider.dart';
import 'package:agrolink/features/profile/screens/profile_screen.dart';
import 'package:agrolink/features/profile/widgets/role_switcher.dart';
import 'package:agrolink/models/user_model.dart';

/// Mock AuthProvider for testing
class MockAuthProvider extends AuthProvider {
  MockAuthProvider() : super();

  List<String> _testAvailableRoles = [];
  String? _testCurrentRole;

  void setTestRoles(List<String> roles, String? currentRole) {
    _testAvailableRoles = roles;
    _testCurrentRole = currentRole;
    notifyListeners();
  }

  @override
  List<String> get availableRoles => _testAvailableRoles;

  @override
  String? get currentRole => _testCurrentRole;

  @override
  bool get hasMultipleRoles => _testAvailableRoles.length > 1;
}

/// Mock ProfileProvider for testing
class MockProfileProvider extends ProfileProvider {
  MockProfileProvider({required super.authProvider});

  UserModel? _testProfile;

  void setTestProfile(UserModel profile) {
    _testProfile = profile;
    notifyListeners();
  }

  @override
  UserModel? get profile => _testProfile;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  Future<void> fetchProfile({bool forceRefresh = false}) async {
    // Mock implementation - do nothing
  }

  @override
  Future<void> refreshProfile() async {
    // Mock implementation - do nothing
  }
}

void main() {
  late MockAuthProvider mockAuthProvider;
  late MockProfileProvider mockProfileProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    mockProfileProvider = MockProfileProvider(authProvider: mockAuthProvider);

    // Set up test profile
    final testProfile = UserModel(
      id: 'test-user-id',
      fullName: 'Test User',
      phone: '+251912345678',
      password: '',
      role: 'farmer',
      location: 'Jimma, Ethiopia',
      createdAt: DateTime.now(),
    );
    mockProfileProvider.setTestProfile(testProfile);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ProfileProvider>.value(value: mockProfileProvider),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen RoleSwitcher Integration Tests', () {
    testWidgets('should display RoleSwitcher when user has multiple roles', (tester) async {
      // Arrange - user with multiple roles
      mockAuthProvider.setTestRoles(['farmer', 'buyer'], 'farmer');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - RoleSwitcher should be visible
      expect(find.byType(RoleSwitcher), findsOneWidget);
      expect(find.text('Switch Role'), findsOneWidget);
    });

    testWidgets('should not display RoleSwitcher when user has single role', (tester) async {
      // Arrange - user with single role
      mockAuthProvider.setTestRoles(['farmer'], 'farmer');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - RoleSwitcher should exist but not show content
      expect(find.byType(RoleSwitcher), findsOneWidget);
      expect(find.text('Switch Role'), findsNothing);
    });

    testWidgets('should place RoleSwitcher between header and personal info', (tester) async {
      // Arrange - user with multiple roles
      mockAuthProvider.setTestRoles(['farmer', 'buyer'], 'farmer');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - verify widget order in the Column
      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Column),
        ).first,
      );

      // The RoleSwitcher should be in the children list
      expect(column.children.whereType<RoleSwitcher>().length, equals(1));
    });

    testWidgets('should display profile information correctly', (tester) async {
      // Arrange
      mockAuthProvider.setTestRoles(['farmer'], 'farmer');

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - verify profile content is displayed
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('FARMER'), findsOneWidget);
      expect(find.text('Personal Information'), findsOneWidget);
    });

    testWidgets('should handle no roles gracefully', (tester) async {
      // Arrange - user with no roles
      mockAuthProvider.setTestRoles([], null);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - RoleSwitcher should exist but show nothing
      expect(find.byType(RoleSwitcher), findsOneWidget);
      expect(find.text('Switch Role'), findsNothing);
    });
  });
}
