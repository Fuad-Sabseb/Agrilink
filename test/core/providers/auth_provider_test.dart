import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:agrolink/core/providers/auth_provider.dart';
import 'package:agrolink/core/services/auth_service.dart';
import 'package:agrolink/core/exceptions/auth_exceptions.dart';
import 'package:agrolink/models/user_model.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  group('AuthProvider Role Switching', () {
    late AuthProvider authProvider;
    late MockAuthService mockAuthService;
    late UserModel testUser;

    setUp(() {
      mockAuthService = MockAuthService();
      authProvider = AuthProvider(authService: mockAuthService);
      
      // Create a test user
      testUser = UserModel(
        id: 'test_user_123',
        fullName: 'Test User',
        phone: '+251911234567',
        password: '',
        role: 'farmer',
        location: 'Addis Ababa',
        createdAt: DateTime.now(),
      );
    });

    group('availableRoles and currentRole', () {
      test('should initialize with empty availableRoles', () {
        expect(authProvider.availableRoles, isEmpty);
        expect(authProvider.currentRole, isNull);
      });

      test('should return currentRole from user if not explicitly set', () async {
        // Setup authenticated user
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthService.getUser()).thenAnswer((_) async => testUser);
        
        await authProvider.initialize();
        
        expect(authProvider.currentRole, equals('farmer'));
      });
    });

    group('hasMultipleRoles getter', () {
      test('should return false when availableRoles has 0 or 1 role', () {
        expect(authProvider.hasMultipleRoles, isFalse);
      });

      test('should return true when availableRoles has multiple roles', () async {
        // Setup authenticated user
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthService.getUser()).thenAnswer((_) async => testUser);
        when(mockAuthService.getAvailableRoles())
            .thenAnswer((_) async => ['farmer', 'buyer']);
        
        await authProvider.initialize();
        await authProvider.fetchAvailableRoles();
        
        expect(authProvider.hasMultipleRoles, isTrue);
      });
    });

    group('fetchAvailableRoles', () {
      test('should fetch available roles from backend when authenticated', () async {
        // Setup authenticated user
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthService.getUser()).thenAnswer((_) async => testUser);
        when(mockAuthService.getAvailableRoles())
            .thenAnswer((_) async => ['farmer', 'buyer', 'transporter']);
        
        await authProvider.initialize();
        await authProvider.fetchAvailableRoles();
        
        expect(authProvider.availableRoles, equals(['farmer', 'buyer', 'transporter']));
        expect(authProvider.currentRole, equals('farmer'));
        verify(mockAuthService.getAvailableRoles()).called(1);
      });

      test('should set error when user is not authenticated', () async {
        // User not authenticated
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => false);
        
        await authProvider.initialize();
        await authProvider.fetchAvailableRoles();
        
        expect(authProvider.error, contains('not authenticated'));
        verifyNever(mockAuthService.getAvailableRoles());
      });

      test('should fallback to user role when fetch fails', () async {
        // Setup authenticated user
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthService.getUser()).thenAnswer((_) async => testUser);
        when(mockAuthService.getAvailableRoles())
            .thenThrow(Exception('Network error'));
        
        await authProvider.initialize();
        await authProvider.fetchAvailableRoles();
        
        // Should fallback to current user role
        expect(authProvider.availableRoles, equals(['farmer']));
        expect(authProvider.currentRole, equals('farmer'));
        expect(authProvider.error, contains('Failed to fetch available roles'));
      });
    });

    group('switchRole', () {
      setUp(() async {
        // Setup authenticated user with multiple roles
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthService.getUser()).thenAnswer((_) async => testUser);
        when(mockAuthService.getAvailableRoles())
            .thenAnswer((_) async => ['farmer', 'buyer']);
        when(mockAuthService.saveUser(any)).thenAnswer((_) async => {});
        
        await authProvider.initialize();
        await authProvider.fetchAvailableRoles();
      });

      test('should successfully switch to an available role', () async {
        when(mockAuthService.switchRole('buyer'))
            .thenAnswer((_) async => 'new_token_123');
        
        final result = await authProvider.switchRole('buyer');
        
        expect(result, isTrue);
        expect(authProvider.currentRole, equals('buyer'));
        expect(authProvider.user?.role, equals('buyer'));
        expect(authProvider.isLoading, isFalse);
        expect(authProvider.error, isNull);
        verify(mockAuthService.switchRole('buyer')).called(1);
      });

      test('should return true if already on the requested role', () async {
        // Already on 'farmer' role
        final result = await authProvider.switchRole('farmer');
        
        expect(result, isTrue);
        expect(authProvider.currentRole, equals('farmer'));
        verifyNever(mockAuthService.switchRole(any));
      });

      test('should return false when user is not authenticated', () async {
        // Create a new provider that's not authenticated
        final unauthProvider = AuthProvider(authService: mockAuthService);
        
        final result = await unauthProvider.switchRole('buyer');
        
        expect(result, isFalse);
        expect(unauthProvider.error, contains('not authenticated'));
        verifyNever(mockAuthService.switchRole(any));
      });

      test('should return false for unauthorized role', () async {
        // Try to switch to a role not in availableRoles
        final result = await authProvider.switchRole('bureau_officer');
        
        expect(result, isFalse);
        expect(authProvider.error, contains('Role not available'));
        expect(authProvider.currentRole, equals('farmer')); // Remains unchanged
        verifyNever(mockAuthService.switchRole(any));
      });

      test('should handle UnauthorizedRoleException from backend', () async {
        when(mockAuthService.switchRole('buyer'))
            .thenThrow(UnauthorizedRoleException(role: 'buyer'));
        
        final result = await authProvider.switchRole('buyer');
        
        expect(result, isFalse);
        expect(authProvider.error, contains('not authorized for this role'));
        expect(authProvider.currentRole, equals('farmer')); // Remains unchanged
        expect(authProvider.isLoading, isFalse);
      });

      test('should handle NetworkException from backend', () async {
        when(mockAuthService.switchRole('buyer'))
            .thenThrow(NetworkException(operation: 'switchRole'));
        
        final result = await authProvider.switchRole('buyer');
        
        expect(result, isFalse);
        expect(authProvider.error, contains('Cannot switch role offline'));
        expect(authProvider.currentRole, equals('farmer')); // Remains unchanged
        expect(authProvider.isLoading, isFalse);
      });

      test('should handle generic exceptions from backend', () async {
        when(mockAuthService.switchRole('buyer'))
            .thenThrow(Exception('Unknown error'));
        
        final result = await authProvider.switchRole('buyer');
        
        expect(result, isFalse);
        expect(authProvider.error, contains('Role switch failed'));
        expect(authProvider.currentRole, equals('farmer')); // Remains unchanged
        expect(authProvider.isLoading, isFalse);
      });

      test('should update user model and save after successful switch', () async {
        when(mockAuthService.switchRole('buyer'))
            .thenAnswer((_) async => 'new_token_123');
        
        await authProvider.switchRole('buyer');
        
        // Verify user model was updated
        expect(authProvider.user?.role, equals('buyer'));
        expect(authProvider.user?.id, equals(testUser.id));
        expect(authProvider.user?.fullName, equals(testUser.fullName));
        
        // Verify saveUser was called
        verify(mockAuthService.saveUser(any)).called(1);
      });
    });

    group('Integration with login flow', () {
      test('should maintain role switching state after login', () async {
        when(mockAuthService.login(
          identifier: anyNamed('identifier'),
          password: anyNamed('password'),
          rememberMe: anyNamed('rememberMe'),
        )).thenAnswer((_) async => testUser);
        when(mockAuthService.getAvailableRoles())
            .thenAnswer((_) async => ['farmer', 'buyer']);
        
        // Login
        await authProvider.login(
          identifier: '+251911234567',
          password: 'test123',
        );
        
        // Fetch roles
        await authProvider.fetchAvailableRoles();
        
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.availableRoles, equals(['farmer', 'buyer']));
        expect(authProvider.currentRole, equals('farmer'));
      });
    });

    group('restoreSession and initialize', () {
      test('should restore authenticated session when tokens and user are present', () async {
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthService.getUser()).thenAnswer((_) async => testUser);

        final result = await authProvider.restoreSession(force: true);

        expect(result, isTrue);
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.user?.id, equals(testUser.id));
        expect(authProvider.user?.fullName, equals('Test User'));
        expect(authProvider.isInitialized, isTrue);
      });

      test('should not authenticate when auth service returns false', () async {
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => false);

        final result = await authProvider.restoreSession(force: true);

        expect(result, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
        expect(authProvider.isInitialized, isTrue);
      });

      test('initialize should call restoreSession and prevent duplicate init', () async {
        when(mockAuthService.isAuthenticated()).thenAnswer((_) async => true);
        when(mockAuthService.getUser()).thenAnswer((_) async => testUser);

        await authProvider.initialize();
        expect(authProvider.isInitialized, isTrue);
        expect(authProvider.isAuthenticated, isTrue);

        // Second call should not re-query authService
        await authProvider.initialize();
        verify(mockAuthService.isAuthenticated()).called(1);
      });
    });

    group('verifyOTP', () {
      test('should return true and update auth state when verification succeeds', () async {
        when(mockAuthService.verifyOTP(phone: '+251911234567', code: '123456'))
            .thenAnswer((_) async => true);

        final result = await authProvider.verifyOTP(
          phone: '+251911234567',
          code: '123456',
        );

        expect(result, isTrue);
        expect(authProvider.error, isNull);
      });

      test('should return false and not authenticate when verification fails', () async {
        when(mockAuthService.verifyOTP(phone: '+251911234567', code: '000000'))
            .thenAnswer((_) async => false);

        final result = await authProvider.verifyOTP(
          phone: '+251911234567',
          code: '000000',
        );

        expect(result, isFalse);
      });
    });
  });
}
