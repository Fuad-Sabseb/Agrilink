import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:agrolink/models/user_model.dart';
import 'package:agrolink/core/services/auth_service.dart';
import 'package:agrolink/core/services/session_service.dart';
import 'package:agrolink/core/exceptions/auth_exceptions.dart';

/// Authentication state management using ChangeNotifier
/// Manages user session, authentication status, and auth operations
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  // ==================== State Variables ====================

  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Role switching state
  List<String> _availableRoles = [];
  String? _currentRole;

  // ==================== Getters ====================

  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  AuthService get authService => _authService;

  /// Get available roles for the current user
  List<String> get availableRoles => _availableRoles;

  /// Get current active role
  String? get currentRole => _currentRole ?? _user?.role;

  /// Check if user has multiple roles
  bool get hasMultipleRoles => _availableRoles.length > 1;

  /// Get user's role
  String? get userRole => _currentRole ?? _user?.role;

  /// Get user's ID (real ID from auth response)
  String? get userId => _user?.id;

  /// Check if user is a farmer
  bool get isFarmer => _user?.role == 'farmer';

  /// Check if user is a buyer
  bool get isBuyer => _user?.role == 'buyer';

  /// Check if user is a transporter
  bool get isTransporter => _user?.role == 'transporter';

  /// Check if user is a bureau officer
  bool get isBureauOfficer => _user?.role == 'bureau_officer';

  // ==================== Initialization ====================

  /// Initialize authentication state
  /// Call this at app startup to restore session
  Future<void> initialize() async {
    if (_isInitialized) return;
    await restoreSession(force: true);
  }

  /// Restore authentication session from secure storage or SessionService
  /// Set [force] to true to re-evaluate even if already initialized
  Future<bool> restoreSession({bool force = false}) async {
    if (_isInitialized && !force && _isAuthenticated) return true;

    _setLoading(true);
    _clearError();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _user = await _authService.getUser();
        if (_user != null) {
          await _syncSession(_user!);
          _isAuthenticated = true;
        } else {
          _isAuthenticated = false;
        }
      } else if (Hive.isBoxOpen('session')) {
        final session = SessionService();
        if (session.isLoggedIn && session.currentUser != null) {
          _user = session.currentUser;
          _isAuthenticated = true;
          await _authService.saveUser(_user!);
        } else {
          _isAuthenticated = false;
        }
      } else {
        _isAuthenticated = false;
      }
      _isInitialized = true;
      _setLoading(false);
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _setError('Failed to restore session: ${e.toString()}');
      _isInitialized = true;
      _setLoading(false);
      return false;
    }
  }

  // ==================== Authentication Methods ====================

  /// Login with phone/email and password
  Future<bool> login({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.login(
        identifier: identifier,
        password: password,
        rememberMe: rememberMe,
      );
      if (_user != null) {
        await _syncSession(_user!);
      }
      _isAuthenticated = true;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Register new user
  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    required String role,
    String? location,
    Map<String, dynamic>? additionalData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.register(
        fullName: fullName,
        phone: phone,
        password: password,
        role: role,
        location: location,
        additionalData: additionalData,
      );
      if (_user != null) {
        await _syncSession(_user!);
      }
      _isAuthenticated = true;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Send OTP to phone number
  /// Returns mock OTP code in development mode for testing
  Future<String?> sendOTP(String phone) async {
    _setLoading(true);
    _clearError();

    try {
      final mockCode = await _authService.sendOTP(phone);
      _setLoading(false);
      return mockCode;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOTP({
    required String phone,
    required String code,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final isVerified = await _authService.verifyOTP(
        phone: phone,
        code: code,
      );
      if (isVerified && _user != null) {
        _isAuthenticated = true;
        await _syncSession(_user!);
      }
      _setLoading(false);
      notifyListeners();
      return isVerified;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Refresh authentication token
  Future<bool> refreshToken() async {
    try {
      await _authService.refreshToken();
      return true;
    } catch (e) {
      _setError('Token refresh failed');
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.logout();
      await _clearSession();
      _user = null;
      _isAuthenticated = false;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      // Even if logout fails, clear local state
      await _clearSession();
      _user = null;
      _isAuthenticated = false;
      _setError('Logout completed with errors');
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Update user data
  Future<void> updateUser(UserModel updatedUser) async {
    try {
      await _authService.saveUser(updatedUser);
      await _syncSession(updatedUser);
      _user = updatedUser;
      notifyListeners();
    } catch (e) {
      _setError('Failed to update user: ${e.toString()}');
    }
  }

  // ==================== Role Switching Methods ====================

  /// Fetch available roles from backend
  /// Must be called after successful authentication
  Future<void> fetchAvailableRoles() async {
    if (!_isAuthenticated) {
      _setError('Cannot fetch roles: User not authenticated');
      return;
    }

    try {
      final roles = await _authService.getAvailableRoles();
      _availableRoles = roles;
      
      // Set current role from user data if not already set
      if (_currentRole == null && _user?.role != null) {
        _currentRole = _user!.role;
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to fetch available roles: ${e.toString()}');
      // Set default to current user role if fetch fails
      if (_user?.role != null) {
        _availableRoles = [_user!.role];
        _currentRole = _user!.role;
      }
    }
  }

  /// Switch to a different role with backend validation
  /// Returns true on success, false on failure
  /// Throws exception for unauthorized role or network errors
  Future<bool> switchRole(String role) async {
    if (!_isAuthenticated) {
      _setError('Cannot switch role: User not authenticated');
      return false;
    }

    // Validate role is in available roles
    if (!_availableRoles.contains(role)) {
      _setError('Role not available: $role');
      return false;
    }

    // Don't switch if already on the requested role
    if (_currentRole == role) {
      return true;
    }

    _setLoading(true);
    _clearError();

    try {
      // Call backend to validate and switch role
      await _authService.switchRole(role);
      
      // Update current role on success
      _currentRole = role;
      
      // Update user model with new role
      if (_user != null) {
        _user = UserModel(
          id: _user!.id,
          fullName: _user!.fullName,
          phone: _user!.phone,
          password: _user!.password,
          role: role,
          location: _user!.location,
          createdAt: _user!.createdAt,
        );
        await _authService.saveUser(_user!);
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } on UnauthorizedRoleException {
      _setError('You are not authorized for this role');
      _setLoading(false);
      return false;
    } on NetworkException {
      _setError('Cannot switch role offline');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Role switch failed: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  // ==================== State Management Helpers ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear error message
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Manual state reset (use with caution)
  void reset() {
    _user = null;
    _isAuthenticated = false;
    _isLoading = false;
    _error = null;
    _isInitialized = false;
    notifyListeners();
  }

  Future<void> _syncSession(UserModel user) async {
    try {
      if (Hive.isBoxOpen('users')) {
        await Hive.box<UserModel>('users').put(user.id, user);
      }
      if (Hive.isBoxOpen('session')) {
        await SessionService().login(user.id);
      }
    } catch (e) {
      debugPrint('AuthProvider session sync error: $e');
    }
  }

  Future<void> _clearSession() async {
    try {
      if (Hive.isBoxOpen('session')) {
        await SessionService().logout();
      }
    } catch (e) {
      debugPrint('AuthProvider session clear error: $e');
    }
  }
}
