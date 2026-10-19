import 'package:agrolink/core/network/api_client.dart';
import 'package:agrolink/core/config/api_config.dart';
import 'package:agrolink/models/user_model.dart';
import 'package:agrolink/models/requests/profile_update_request.dart';

/// Service for profile-related API operations
class ProfileService {
  final ApiClient _apiClient;

  ProfileService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Mock mode toggle (same as Phase 1 auth)
  static const bool useMockData = true;

  /// Get user profile from backend
  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      if (useMockData) {
        return await _mockGetProfile();
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.userProfileEndpoint,
        requiresAuth: true,
      );

      if (!response.isSuccess || response.data == null) {
        return ApiResponse.error(
          response.error ?? 'Failed to load profile',
          statusCode: response.statusCode,
        );
      }

      final user = UserModel.fromJson(response.data!);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error('Failed to load profile: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<ApiResponse<UserModel>> updateProfile(
    ProfileUpdateRequest request,
  ) async {
    try {
      if (useMockData) {
        return await _mockUpdateProfile(request);
      }

      final response = await _apiClient.patch<Map<String, dynamic>>(
        ApiConfig.updateProfileEndpoint,
        data: request.toJson(),
        requiresAuth: true,
      );

      if (!response.isSuccess || response.data == null) {
        return ApiResponse.error(
          response.error ?? 'Failed to update profile',
          statusCode: response.statusCode,
        );
      }

      // Backend returns { "success": true, "user": {...} }
      final userData = response.data!['user'] as Map<String, dynamic>?;
      if (userData == null) {
        return ApiResponse.error('Invalid response format');
      }

      final user = UserModel.fromJson(userData);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error('Failed to update profile: ${e.toString()}');
    }
  }

  /// Request OTP for phone update
  Future<ApiResponse<void>> requestPhoneOTP(String newPhone) async {
    try {
      if (useMockData) {
        return await _mockRequestPhoneOTP(newPhone);
      }

      final response = await _apiClient.post(
        '/user/phone/send-otp',
        data: {'newPhone': newPhone},
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        return ApiResponse.error(
          response.error ?? 'Failed to send OTP',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Update phone number with OTP verification
  Future<ApiResponse<void>> updatePhoneWithOTP({
    required String newPhone,
    required String otpCode,
  }) async {
    try {
      if (useMockData) {
        return await _mockUpdatePhoneWithOTP(newPhone, otpCode);
      }

      final response = await _apiClient.post(
        '/user/phone/verify',
        data: {
          'newPhone': newPhone,
          'otpCode': otpCode,
        },
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        return ApiResponse.error(
          response.error ?? 'Failed to update phone number',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Failed to update phone: ${e.toString()}');
    }
  }

  // ==================== Mock Implementations ====================

  Future<ApiResponse<UserModel>> _mockGetProfile() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Return mock user (in real app, get from AuthService)
    final mockUser = UserModel(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      fullName: 'Abdullahi Mohammed',
      phone: '+251912345678',
      password: '',
      role: 'farmer',
      location: 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      woreda: 'Jimma Town Woreda',
      kebele: 'Kebele 07',
      cooperativeName: 'Jimma Coffee Cooperative',
      isVerified: true,
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      roleData: {
        'farmCount': 2,
        'totalHectares': 4.0,
        'primaryCrops': ['coffee', 'maize'],
      },
    );

    return ApiResponse.success(mockUser);
  }

  Future<ApiResponse<UserModel>> _mockUpdateProfile(
    ProfileUpdateRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate update - in real app, merge with existing user
    final updatedUser = UserModel(
      id: 'mock_user_123',
      fullName: request.fullName ?? 'Abdullahi Mohammed',
      phone: '+251912345678',
      password: '',
      role: 'farmer',
      location: request.location ?? 'Jimma Town',
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      woreda: request.woreda,
      cooperativeName: request.cooperativeName,
      isVerified: true,
    );

    return ApiResponse.success(updatedUser);
  }

  Future<ApiResponse<void>> _mockRequestPhoneOTP(String newPhone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock OTP: 123456
    return ApiResponse.success(null);
  }

  Future<ApiResponse<void>> _mockUpdatePhoneWithOTP(
    String newPhone,
    String otpCode,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Verify OTP (mock accepts 123456)
    if (otpCode == '123456') {
      return ApiResponse.success(null);
    } else {
      return ApiResponse.error('Invalid OTP code', statusCode: 400);
    }
  }
}
