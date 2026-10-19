import 'package:agrolink/core/network/api_client.dart';
import 'package:agrolink/core/config/api_config.dart';

import 'package:agrolink/models/requests/password_change_request.dart';

/// Service for password-related operations
/// SECURITY: Never log passwords or expose them in any way
class PasswordService {
  final ApiClient _apiClient;

  PasswordService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Mock mode toggle
  static const bool useMockData = true;

  /// Change password for authenticated user
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (useMockData) {
        return await _mockChangePassword(currentPassword, newPassword);
      }

      final request = PasswordChangeRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      final response = await _apiClient.post(
        ApiConfig.changePasswordEndpoint,
        data: request.toJson(),
        requiresAuth: true,
      );

      if (!response.isSuccess) {
        return ApiResponse.error(
          response.error ?? 'Failed to change password',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.success(null);
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Password change error (details omitted for security)');
      }
      return ApiResponse.error('Failed to change password');
    }
  }

  /// Request password reset (send OTP)
  Future<ApiResponse<PasswordResetResponse>> requestPasswordReset(
    String phone,
  ) async {
    try {
      if (useMockData) {
        return await _mockRequestPasswordReset(phone);
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.resetPasswordEndpoint,
        data: {'phone': phone},
        requiresAuth: false,
      );

      if (!response.isSuccess || response.data == null) {
        return ApiResponse.error(
          response.error ?? 'Failed to request password reset',
          statusCode: response.statusCode,
        );
      }

      final result = PasswordResetResponse(
        message: response.data!['message'] as String? ?? 'OTP sent',
        expiresIn: response.data!['expiresIn'] as int? ?? 600,
      );

      return ApiResponse.success(result);
    } catch (e) {
      return ApiResponse.error('Failed to request reset: ${e.toString()}');
    }
  }

  /// Verify OTP and get reset token
  Future<ApiResponse<ResetTokenResponse>> verifyResetOTP({
    required String phone,
    required String otpCode,
  }) async {
    try {
      if (useMockData) {
        return await _mockVerifyResetOTP(phone, otpCode);
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/reset-password/verify',
        data: {
          'phone': phone,
          'otpCode': otpCode,
        },
        requiresAuth: false,
      );

      if (!response.isSuccess || response.data == null) {
        return ApiResponse.error(
          response.error ?? 'Failed to verify OTP',
          statusCode: response.statusCode,
        );
      }

      final result = ResetTokenResponse(
        resetToken: response.data!['resetToken'] as String,
        expiresIn: response.data!['expiresIn'] as int? ?? 600,
      );

      return ApiResponse.success(result);
    } catch (e) {
      return ApiResponse.error('Failed to verify OTP: ${e.toString()}');
    }
  }

  /// Confirm password reset with token
  Future<ApiResponse<void>> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      if (useMockData) {
        return await _mockConfirmPasswordReset(resetToken, newPassword);
      }

      final response = await _apiClient.post(
        '/auth/reset-password/confirm',
        data: {
          'resetToken': resetToken,
          'newPassword': newPassword,
        },
        requiresAuth: false,
      );

      if (!response.isSuccess) {
        return ApiResponse.error(
          response.error ?? 'Failed to reset password',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.success(null);
    } catch (e) {
      if (ApiConfig.enableLogging) {
        print('Password reset error (details omitted for security)');
      }
      return ApiResponse.error('Failed to reset password');
    }
  }

  // ==================== Mock Implementations ====================

  Future<ApiResponse<void>> _mockChangePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate validation (in real app, backend validates)
    if (currentPassword.length < 6) {
      return ApiResponse.error(
        'Invalid current password',
        statusCode: 401,
      );
    }

    return ApiResponse.success(null);
  }

  Future<ApiResponse<PasswordResetResponse>> _mockRequestPasswordReset(
    String phone,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return ApiResponse.success(
      PasswordResetResponse(
        message: 'OTP sent to $phone',
        expiresIn: 600,
      ),
    );
  }

  Future<ApiResponse<ResetTokenResponse>> _mockVerifyResetOTP(
    String phone,
    String otpCode,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock accepts 123456
    if (otpCode == '123456') {
      return ApiResponse.success(
        ResetTokenResponse(
          resetToken: 'mock_reset_token_${DateTime.now().millisecondsSinceEpoch}',
          expiresIn: 600,
        ),
      );
    } else {
      return ApiResponse.error('Invalid OTP code', statusCode: 400);
    }
  }

  Future<ApiResponse<void>> _mockConfirmPasswordReset(
    String resetToken,
    String newPassword,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate expired token check
    if (!resetToken.startsWith('mock_reset_token')) {
      return ApiResponse.error('Invalid or expired reset token', statusCode: 400);
    }

    return ApiResponse.success(null);
  }
}

/// Response from password reset request
class PasswordResetResponse {
  final String message;
  final int expiresIn; // seconds

  PasswordResetResponse({
    required this.message,
    required this.expiresIn,
  });
}

/// Response from OTP verification containing reset token
class ResetTokenResponse {
  final String resetToken;
  final int expiresIn; // seconds

  ResetTokenResponse({
    required this.resetToken,
    required this.expiresIn,
  });
}
