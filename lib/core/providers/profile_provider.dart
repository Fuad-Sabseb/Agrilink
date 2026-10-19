import 'package:flutter/foundation.dart';
import 'package:agrolink/models/user_model.dart';
import 'package:agrolink/models/requests/profile_update_request.dart';
import 'package:agrolink/core/services/profile_service.dart';
import 'package:agrolink/core/providers/auth_provider.dart';

/// Provider for profile state management
class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService;
  final AuthProvider _authProvider;

  ProfileProvider({
    ProfileService? profileService,
    required AuthProvider authProvider,
  })  : _profileService = profileService ?? ProfileService(),
        _authProvider = authProvider;

  // State
  UserModel? _profile;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  DateTime? _lastFetched;

  // Cache duration
  static const _cacheDuration = Duration(minutes: 5);

  // Getters
  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  DateTime? get lastFetched => _lastFetched;

  bool get isCacheValid {
    if (_lastFetched == null) return false;
    return DateTime.now().difference(_lastFetched!) < _cacheDuration;
  }

  /// Fetch profile from API
  Future<void> fetchProfile({bool forceRefresh = false}) async {
    // Use cache if valid and not forcing refresh
    if (isCacheValid && !forceRefresh && _profile != null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _profileService.getProfile();

      if (response.isSuccess && response.data != null) {
        _profile = response.data;
        _lastFetched = DateTime.now();
        _error = null;

        // Update AuthProvider as well
        await _authProvider.authService.saveUser(_profile!);
      } else {
        _error = response.error ?? 'Failed to load profile';

        // Handle unauthorized
        if (response.statusCode == 401) {
          await _handleUnauthorized();
        }
      }
    } catch (e) {
      _error = 'Failed to load profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update profile
  Future<bool> updateProfile(ProfileUpdateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _profileService.updateProfile(request);

      if (response.isSuccess && response.data != null) {
        _profile = response.data;
        _lastFetched = DateTime.now();
        _error = null;

        // Update AuthProvider
        await _authProvider.updateUser(_profile!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to update profile';

        // Handle unauthorized
        if (response.statusCode == 401) {
          await _handleUnauthorized();
        }

        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Request OTP for phone update
  Future<bool> requestPhoneOTP(String newPhone) async {
    _error = null;
    notifyListeners();

    try {
      final response = await _profileService.requestPhoneOTP(newPhone);

      if (response.isSuccess) {
        return true;
      } else {
        _error = response.error ?? 'Failed to send OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to send OTP: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Update phone number with OTP
  Future<bool> updatePhoneNumber(String newPhone, String otpCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _profileService.updatePhoneWithOTP(
        newPhone: newPhone,
        otpCode: otpCode,
      );

      if (response.isSuccess) {
        // Refresh profile to get updated phone
        await fetchProfile(forceRefresh: true);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Failed to update phone number';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update phone: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Refresh profile (pull-to-refresh)
  Future<void> refreshProfile() async {
    _isRefreshing = true;
    notifyListeners();

    await fetchProfile(forceRefresh: true);

    _isRefreshing = false;
    notifyListeners();
  }

  /// Clear profile data (on logout)
  void clearProfile() {
    _profile = null;
    _error = null;
    _lastFetched = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Handle unauthorized response
  Future<void> _handleUnauthorized() async {
    await _authProvider.logout();
    // Navigation handled by UI listening to AuthProvider
  }
}
