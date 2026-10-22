import { TokenService } from '../services/tokenService.js';
import { User } from '../models/User.js';

export const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: 'Authentication token required',
      });
    }

    const token = authHeader.split(' ')[1];
    const decoded = TokenService.verifyAccessToken(token);

    const user = await User.findById(decoded.id);
    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'User not found or account deactivated',
      });
    }

    req.user = user;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      error: error.message || 'Invalid or expired token',
    });
  }
};

export const optionalAuthenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      try {
        const decoded = TokenService.verifyAccessToken(token);
        const user = await User.findById(decoded.id);
        if (user) req.user = user;
      } catch (err) {
        // Token invalid/expired, continue without req.user
      }
    }
    next();
  } catch (error) {
    next();
  }
};

export const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: `Forbidden: role '${req.user?.role}' does not have access to this resource`,
      });
    }
    next();
  };
};

