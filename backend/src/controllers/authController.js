import { User } from '../models/User.js';
import { SMSService } from '../services/smsService.js';
import { TokenService } from '../services/tokenService.js';

export class AuthController {
  /**
   * Register a new user
   */
  static async register(req, res, next) {
    try {
      const { fullName, phone, password, role, location, email, woreda } = req.body;

      if (!fullName || !phone || !password) {
        return res.status(400).json({
          success: false,
          error: 'Full name, phone, and password are required',
        });
      }

      const normalizedPhone = SMSService.normalizePhoneNumber(phone);

      // Check if user already exists
      const existingUser = await User.findOne({ phone: normalizedPhone });
      if (existingUser) {
        return res.status(409).json({
          success: false,
          error: 'A user with this phone number already exists',
        });
      }

      // Create user
      const user = await User.create({
        fullName,
        phone: normalizedPhone,
        password,
        role: role || 'farmer',
        location: location || 'Jimma, Jimma Zone, Oromia',
        email,
        woreda,
      });

      // Generate JWT tokens
      const tokens = TokenService.generateTokens(user);

      return res.status(201).json({
        success: true,
        message: 'Registration successful',
        user: user.toJSON(),
        tokens,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Login with phone/email and password
   */
  static async login(req, res, next) {
    try {
      const { identifier, phone, email, password } = req.body;
      const loginId = identifier || phone || email;

      if (!loginId || !password) {
        return res.status(400).json({
          success: false,
          error: 'Identifier (phone or email) and password are required',
        });
      }

      const normalizedPhone = SMSService.normalizePhoneNumber(loginId);

      // Find user by normalized phone or email
      const user = await User.findOne({
        $or: [{ phone: normalizedPhone }, { phone: loginId }, { email: loginId.toLowerCase() }],
      });

      if (!user) {
        return res.status(401).json({
          success: false,
          error: 'Invalid credentials. User not found.',
        });
      }

      // Verify password
      const isMatch = await user.comparePassword(password);
      if (!isMatch) {
        return res.status(401).json({
          success: false,
          error: 'Invalid credentials. Incorrect password.',
        });
      }

      // Generate JWT tokens
      const tokens = TokenService.generateTokens(user);

      return res.status(200).json({
        success: true,
        message: 'Login successful',
        user: user.toJSON(),
        tokens,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Refresh JWT token
   */
  static async refreshToken(req, res, next) {
    try {
      const { refreshToken } = req.body;
      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          error: 'Refresh token is required',
        });
      }

      const decoded = TokenService.verifyRefreshToken(refreshToken);
      const user = await User.findById(decoded.id);

      if (!user) {
        return res.status(401).json({
          success: false,
          error: 'User not found',
        });
      }

      const tokens = TokenService.generateTokens(user);

      return res.status(200).json({
        success: true,
        tokens,
      });
    } catch (error) {
      return res.status(401).json({
        success: false,
        error: error.message || 'Invalid refresh token',
      });
    }
  }

  /**
   * Send Ethio Telecom SMS OTP
   */
  static async sendOTP(req, res, next) {
    try {
      const { phone, type } = req.body;
      if (!phone) {
        return res.status(400).json({
          success: false,
          error: 'Phone number is required',
        });
      }

      const result = await SMSService.sendOTP(phone, type || 'login');

      return res.status(200).json({
        success: true,
        message: 'OTP sent successfully',
        ...result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Verify SMS OTP
   */
  static async verifyOTP(req, res, next) {
    try {
      const { phone, code, type } = req.body;
      if (!phone || !code) {
        return res.status(400).json({
          success: false,
          error: 'Phone number and verification code are required',
        });
      }

      const isValid = await SMSService.verifyOTP(phone, code, type || 'login');

      return res.status(200).json({
        success: true,
        verified: isValid,
        message: 'OTP verified successfully',
      });
    } catch (error) {
      return res.status(400).json({
        success: false,
        verified: false,
        error: error.message,
      });
    }
  }

  /**
   * Reset Password with OTP
   */
  static async resetPassword(req, res, next) {
    try {
      const { phone, code, newPassword } = req.body;
      if (!phone || !code || !newPassword) {
        return res.status(400).json({
          success: false,
          error: 'Phone, verification code, and new password are required',
        });
      }

      // Verify OTP
      await SMSService.verifyOTP(phone, code, 'password_reset');

      const normalizedPhone = SMSService.normalizePhoneNumber(phone);
      const user = await User.findOne({ phone: normalizedPhone });
      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'User not found with this phone number',
        });
      }

      user.password = newPassword;
      await user.save();

      return res.status(200).json({
        success: true,
        message: 'Password reset successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Change Password (Authenticated)
   */
  static async changePassword(req, res, next) {
    try {
      const { currentPassword, newPassword } = req.body;
      if (!currentPassword || !newPassword) {
        return res.status(400).json({
          success: false,
          error: 'Current password and new password are required',
        });
      }

      const user = await User.findById(req.user.id);
      const isMatch = await user.comparePassword(currentPassword);
      if (!isMatch) {
        return res.status(400).json({
          success: false,
          error: 'Current password does not match',
        });
      }

      user.password = newPassword;
      await user.save();

      return res.status(200).json({
        success: true,
        message: 'Password changed successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Verify Token / Get Current Auth State
   */
  static async verifyToken(req, res) {
    return res.status(200).json({
      success: true,
      user: req.user.toJSON(),
    });
  }

  /**
   * Logout
   */
  static async logout(req, res) {
    return res.status(200).json({
      success: true,
      message: 'Logged out successfully',
    });
  }
}
