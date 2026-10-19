import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:agrolink/models/user_model.dart';
import 'package:agrolink/core/network/api_client.dart';
import 'package:agrolink/core/config/api_config.dart';
import 'package:agrolink/core/exceptions/auth_exceptions.dart';

/// Production-Ready Authentication Service
/// Handles login, registration, OTP verification, token management, and secure storage
/// 
/// BACKEND INTEGRATION NOTES:
/// This service is structured for real API integration.
/// Mock mode is enabled by default until backend endpoints are available.
/// Set useMockAuth = false when real API is ready.
class AuthService {
  final FlutterSecureStorage _secureStorage;
  final ApiClient _apiClient;
  
  // Toggle between mock and real API
  // Set to false when backend is ready
  static const bool useMockAuth = true;

  AuthService({
    FlutterSecureStorage? secureStorage,
    ApiClient? apiClient,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _apiClient = apiClient ?? ApiClient();

  // ==================== Token Management ====================

  /// Save authentication tokens securely
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _apiClient.setAccessToken(accessToken);
    await _apiClient.setRefreshToken(refreshToken);
  }

  /// Retrieve access token
  Future<String?> getAccessToken() async {
    return await _apiClient.getAccessToken();
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    return await _apiClient.getRefreshToken();
  }

  /// Delete all tokens
  Future<void> deleteTokens() async {
    await _apiClient.clearTokens();
  }

  // ==================== User Data Management ====================

  /// Save user data securely
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode({
      'id': user.id,
      'fullName': user.fullName,
      'phone': user.phone,
      'role': user.role,
      'location': user.location,
      'createdAt': user.createdAt.toIso8601String(),
    });
    await _secureStorage.write(key: ApiConfig.userDataKey, value: userJson);
  }

  /// Retrieve saved user data
  Future<UserModel?> getUser() async {
    final userJson = await _secureStorage.read(key: ApiConfig.userDataKey);
    if (userJson == null) return null;

    try {
      final data = jsonDecode(userJson);
      return UserModel(
        id: data['id'],
        fullName: data['fullName'],
        phone: data['phone'],
        password: '', // Never store password
        role: data['role'],
        location: data['location'],
        createdAt: DateTime.parse(data['createdAt']),
      );
    } catch (e) {
      // If parsing fails, clear corrupted data
      await deleteUser();
      return null;
    }
  }

  /// Delete user data
  Future<void> deleteUser() async {
    await _secureStorage.delete(key: ApiConfig.userDataKey);
  }

  // ==================== Authentication Methods ====================

  /// Login with phone/email and password
  /// Returns user data on success, throws exception on failure
  Future<UserModel> login({
    required String identifier, // phone or email
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      if (useMockAuth) {
        return await _mockLogin(identifier, password, rememberMe);
      }

      // Real API implementation
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.loginEndpoint,
        data: {
          'identifier': identifier,
          'password': password,
          'rememberMe': rememberMe,
        },
        requiresAuth: false,
      );

      if (!response.isSuccess || response.data == null) {
        throw Exception(response.error ?? 'Login failed');
      }

      final data = response.data!;
      
      // Extract user data from response
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel(
        id: userData['id'] as String,
        fullName: userData['fullName'] as String,
        phone: userData['phone'] as String,
        password: '', // Never store password
        role: userData['role'] as String,
        location: (userData['location'] as String?) ?? 'Not specified',
        createdAt: DateTime.parse(userData['createdAt'] as String),
      );

      // Extract and save tokens
      final tokens = data['tokens'] as Map<String, dynamic>;
      await saveTokens(
        accessToken: tokens['accessToken'] as String,
        refreshToken: tokens['refreshToken'] as String,
      );

      // Save user data
      await saveUser(user);

      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Register new user
  /// Returns user data on success, throws exception on failure
  Future<UserModel> register({
    required String fullName,
    required String phone,
    required String password,
    required String role,
    String? location,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (useMockAuth) {
        return await _mockRegister(fullName, phone, password, role, location);
      }

      // Real API implementation
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.registerEndpoint,
        data: {
          'fullName': fullName,
          'phone': phone,
          'password': password,
          'role': role,
          'location': location,
          ...?additionalData,
        },
        requiresAuth: false,
      );

      if (!response.isSuccess || response.data == null) {
        throw Exception(response.error ?? 'Registration failed');
      }

      final data = response.data!;
      
      // Extract user data from response
      final userData = data['user'] as Map<String, dynamic>;
      final user = UserModel(
        id: userData['id'] as String,
        fullName: userData['fullName'] as String,
        phone: userData['phone'] as String,
        password: '',
        role: userData['role'] as String,
        location: (userData['location'] as String?) ?? 'Not specified',
        createdAt: DateTime.parse(userData['createdAt'] as String),
      );

      // Extract and save tokens
      final tokens = data['tokens'] as Map<String, dynamic>;
      await saveTokens(
        accessToken: tokens['accessToken'] as String,
        refreshToken: tokens['refreshToken'] as String,
      );

      // Save user data
      await saveUser(user);

      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Send OTP to phone number
  /// Returns mock OTP code in development mode, null in production
  Future<String?> sendOTP(String phone) async {
    try {
      if (useMockAuth) {
        return await _mockSendOTP(phone);
      }

      // Real API implementation
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.sendOTPEndpoint,
        data: {'phone': phone},
        requiresAuth: false,
      );

      // In production, don't return the OTP
      return response.isSuccess ? null : throw Exception('Failed to send OTP');
    } catch (e) {
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Verify OTP code
  Future<bool> verifyOTP({
    required String phone,
    required String code,
  }) async {
    try {
      if (useMockAuth) {
        return await _mockVerifyOTP(phone, code);
      }

      // Real API implementation
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.verifyOTPEndpoint,
        data: {
          'phone': phone,
          'code': code,
        },
        requiresAuth: false,
      );

      if (!response.isSuccess || response.data == null) {
        return false;
      }

      return response.data!['verified'] == true;
    } catch (e) {
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  /// Refresh access token using refresh token
  Future<String> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }

      if (useMockAuth) {
        return await _mockRefreshToken();
      }

      // Real API implementation handled by ApiClient interceptor
      // This method is called by the interceptor automatically
      final newAccessToken = await _apiClient.getAccessToken();
      if (newAccessToken == null) {
        throw Exception('Token refresh failed');
      }

      return newAccessToken;
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  /// Verify if current token is valid
  Future<bool> verifyToken() async {
    try {
      if (useMockAuth) {
        final token = await getAccessToken();
        return token != null && token.isNotEmpty;
      }

      // Real API implementation
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.verifyTokenEndpoint,
        requiresAuth: true,
      );

      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    final user = await getUser();
    return token != null && token.isNotEmpty && user != null;
  }

  /// Logout user - clear all stored data and notify server
  Future<void> logout() async {
    try {
      if (!useMockAuth) {
        // Notify server to invalidate token
        await _apiClient.post(
          ApiConfig.logoutEndpoint,
          requiresAuth: true,
        );
      }
    } catch (e) {
      // Continue with local cleanup even if API call fails
      if (ApiConfig.enableLogging) {
        print('Logout API call failed: $e');
      }
    } finally {
      // Always clear local data
      await Future.wait([
        deleteTokens(),
        deleteUser(),
      ]);
    }
  }

  /// Clear all secure storage (use with caution)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  // ==================== Role Switching Methods ====================

  /// Fetch available roles from backend
  /// Returns list of roles the user is authorized to use
  Future<List<String>> getAvailableRoles() async {
    try {
      if (useMockAuth) {
        return await _mockGetAvailableRoles();
      }

      // Real API implementation
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/users/available-roles',
        requiresAuth: true,
      );

      if (!response.isSuccess || response.data == null) {
        throw NetworkException(
          operation: 'getAvailableRoles',
          message: response.error ?? 'Failed to fetch available roles',
        );
      }

      final data = response.data!;
      final roles = (data['roles'] as List).cast<String>();
      return roles;
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(
        operation: 'getAvailableRoles',
        message: 'Failed to fetch available roles: ${e.toString()}',
      );
    }
  }

  /// Switch to a different role with backend validation
  /// Returns new JWT token on success
  /// Throws UnauthorizedRoleException if role is not authorized
  /// Throws NetworkException if network request fails
  Future<String> switchRole(String role) async {
    try {
      if (useMockAuth) {
        return await _mockSwitchRole(role);
      }

      // Real API implementation
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/users/switch-role',
        data: {'role': role},
        requiresAuth: true,
      );

      // Handle 403 Forbidden - unauthorized role
      if (response.statusCode == 403) {
        throw UnauthorizedRoleException(
          role: role,
          message: 'You are not authorized for this role',
        );
      }

      if (!response.isSuccess || response.data == null) {
        throw NetworkException(
          operation: 'switchRole',
          message: response.error ?? 'Failed to switch role',
        );
      }

      final data = response.data!;
      
      // Extract new token from response
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String?;

      // Update stored tokens
      await _apiClient.setAccessToken(newAccessToken);
      if (newRefreshToken != null) {
        await _apiClient.setRefreshToken(newRefreshToken);
      }

      return newAccessToken;
    } catch (e) {
      if (e is UnauthorizedRoleException || e is NetworkException) rethrow;
      throw NetworkException(
        operation: 'switchRole',
        message: 'Failed to switch role: ${e.toString()}',
      );
    }
  }

  // ==================== Mock Role Switching (Development) ====================

  Future<List<String>> _mockGetAvailableRoles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock: return multiple roles for testing
    // In production, this comes from backend based on user permissions
    final user = await getUser();
    if (user == null) {
      return [];
    }

    // Simulate different role scenarios based on user role
    switch (user.role) {
      case 'farmer':
        // Farmer can also be a buyer (common in Ethiopian agriculture)
        return ['farmer', 'buyer'];
      case 'buyer':
        // Buyer might also be a transporter
        return ['buyer', 'transporter'];
      case 'bureau_officer':
        // Bureau officers typically have only one role
        return ['bureau_officer'];
      case 'transporter':
        // Transporter could also be a buyer
        return ['transporter', 'buyer'];
      default:
        return [user.role];
    }
  }

  Future<String> _mockSwitchRole(String role) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    final availableRoles = await _mockGetAvailableRoles();
    
    // Simulate 403 for unauthorized roles
    if (!availableRoles.contains(role)) {
      throw UnauthorizedRoleException(
        role: role,
        message: 'You are not authorized for this role',
      );
    }

    // Generate new mock token
    final newToken = 'mock_access_${role}_${DateTime.now().millisecondsSinceEpoch}';
    await _apiClient.setAccessToken(newToken);
    
    return newToken;
  }

  // ==================== Mock Helpers ====================

  Future<UserModel> _mockLogin(String identifier, String password, bool rememberMe) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Validate password
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    // Accept specific test passwords
    const validPasswords = ['test123', 'password', '123456', 'farmer123', 'buyer123'];
    if (!validPasswords.contains(password)) {
      throw Exception('Invalid credentials');
    }

    // Generate mock user based on identifier
    final mockUser = UserModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _getMockFullName(identifier),
      phone: identifier.contains('@') ? '+251911234567' : identifier,
      password: '',
      role: _getMockRole(identifier),
      location: 'Addis Ababa, Ethiopia',
      createdAt: DateTime.now(),
    );

    // Mock tokens
    final mockAccessToken = 'mock_access_${DateTime.now().millisecondsSinceEpoch}';
    final mockRefreshToken = 'mock_refresh_${DateTime.now().millisecondsSinceEpoch}';

    await saveTokens(
      accessToken: mockAccessToken,
      refreshToken: mockRefreshToken,
    );
    await saveUser(mockUser);

    return mockUser;
  }

  Future<UserModel> _mockRegister(String fullName, String phone, String password, String role, String? location) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (fullName.isEmpty || phone.isEmpty || password.length < 6) {
      throw Exception('Invalid registration data');
    }

    final mockUser = UserModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName,
      phone: phone,
      password: '',
      role: role,
      location: location ?? 'Jimma, Oromia',
      createdAt: DateTime.now(),
    );

    final mockAccessToken = 'mock_access_${DateTime.now().millisecondsSinceEpoch}';
    final mockRefreshToken = 'mock_refresh_${DateTime.now().millisecondsSinceEpoch}';

    await saveTokens(
      accessToken: mockAccessToken,
      refreshToken: mockRefreshToken,
    );
    await saveUser(mockUser);

    return mockUser;
  }

  Future<String> _mockSendOTP(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Return mock OTP for development/testing
    return '123456';
  }

  Future<bool> _mockVerifyOTP(String phone, String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Accept 123456 as valid OTP
    return code == '123456';
  }

  Future<String> _mockRefreshToken() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newToken = 'mock_access_${DateTime.now().millisecondsSinceEpoch}';
    await _apiClient.setAccessToken(newToken);
    return newToken;
  }

  String _getMockFullName(String identifier) {
    if (identifier.contains('farmer') || identifier.startsWith('+2519')) {
      return 'Abebe Kebede';
    } else if (identifier.contains('buyer')) {
      return 'Tigist Alemu';
    } else if (identifier.contains('transporter')) {
      return 'Mulugeta Tadesse';
    } else if (identifier.contains('officer') || identifier.contains('bureau')) {
      return 'Almaz Tesfaye';
    }
    return 'Test User';
  }


  // ==================== Account Deletion ====================

  /// Delete user account permanently
  /// This is an irreversible operation
  Future<bool> deleteAccount() async {
    try {
      if (useMockAuth) {
        return await _mockDeleteAccount();
      }

      // Real API implementation
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '/users/account',
        requiresAuth: true,
      );

      if (response.isSuccess) {
        // Clear all local data
        await Future.wait([
          deleteTokens(),
          deleteUser(),
        ]);
        return true;
      }

      return false;
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  Future<bool> _mockDeleteAccount() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock successful deletion
    await Future.wait([
      deleteTokens(),
      deleteUser(),
    ]);
    
    return true;
  }

  String _getMockRole(String identifier) {
    if (identifier.contains('farmer') || identifier.startsWith('+2519')) {
      return 'farmer';
    } else if (identifier.contains('buyer')) {
      return 'buyer';
    } else if (identifier.contains('transporter')) {
      return 'transporter';
    } else if (identifier.contains('officer') || identifier.contains('bureau')) {
      return 'bureau_officer';
    }
    return 'farmer';
  }
}
