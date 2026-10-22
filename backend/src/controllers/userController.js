import { User } from '../models/User.js';

export class UserController {
  /**
   * Get current user profile
   */
  static async getProfile(req, res, next) {
    try {
      const user = await User.findById(req.user.id);
      return res.status(200).json({
        success: true,
        user: user.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update user profile
   */
  static async updateProfile(req, res, next) {
    try {
      const { fullName, location, woreda, avatarUrl, email } = req.body;
      const user = await User.findById(req.user.id);

      if (fullName) user.fullName = fullName;
      if (location) user.location = location;
      if (woreda !== undefined) user.woreda = woreda;
      if (avatarUrl) user.avatarUrl = avatarUrl;
      if (email) user.email = email;

      await user.save();

      return res.status(200).json({
        success: true,
        message: 'Profile updated successfully',
        user: user.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Register or update FCM Token for Push Notifications
   */
  static async updateFCMToken(req, res, next) {
    try {
      const { fcmToken } = req.body;
      if (!fcmToken) {
        return res.status(400).json({
          success: false,
          error: 'fcmToken is required',
        });
      }

      await User.findByIdAndUpdate(req.user.id, { fcmToken });

      return res.status(200).json({
        success: true,
        message: 'FCM device token registered successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get user preferences
   */
  static async getPreferences(req, res, next) {
    try {
      const user = await User.findById(req.user.id);
      return res.status(200).json({
        success: true,
        preferences: user.preferences,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update user preferences
   */
  static async updatePreferences(req, res, next) {
    try {
      const user = await User.findById(req.user.id);
      user.preferences = {
        ...user.preferences,
        ...req.body,
      };
      await user.save();

      return res.status(200).json({
        success: true,
        message: 'Preferences updated successfully',
        preferences: user.preferences,
      });
    } catch (error) {
      next(error);
    }
  }
}
