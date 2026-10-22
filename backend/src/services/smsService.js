import axios from 'axios';
import crypto from 'crypto';
import { OTP } from '../models/OTP.js';
import { config } from '../config/env.js';

export class SMSService {
  /**
   * Normalize Ethiopian phone numbers to international standard (+251...)
   * Examples:
   * 0912345678 -> +251912345678
   * 0712345678 -> +251712345678
   * 251912345678 -> +251912345678
   */
  static normalizePhoneNumber(phone) {
    if (!phone) return '';
    let cleaned = phone.replace(/[\s\-()]/g, '');
    if (cleaned.startsWith('0')) {
      cleaned = '+251' + cleaned.substring(1);
    } else if (cleaned.startsWith('251')) {
      cleaned = '+' + cleaned;
    } else if (!cleaned.startsWith('+')) {
      cleaned = '+251' + cleaned;
    }
    return cleaned;
  }

  /**
   * Generate a secure 6-digit numeric OTP
   */
  static generateOTP() {
    return crypto.randomInt(100000, 999999).toString();
  }

  /**
   * Send OTP via Ethio Telecom SMS Gateway
   */
  static async sendOTP(phone, type = 'login') {
    const normalizedPhone = this.normalizePhoneNumber(phone);
    const code = this.generateOTP();

    // Invalidate any previous unverified OTPs for this phone and type
    await OTP.deleteMany({ phone: normalizedPhone, type, verified: false });

    // Store new OTP
    const otpDoc = await OTP.create({
      phone: normalizedPhone,
      code,
      type,
    });

    const message = `Your AgroLink verification code is ${code}. Valid for 5 minutes. Do not share this code with anyone.`;

    if (config.ethioTelecom.isMock) {
      console.log(`[Ethio Telecom SMS] (SIMULATED) To: ${normalizedPhone} | Message: "${message}" | Code: ${code}`);
      return {
        success: true,
        phone: normalizedPhone,
        code: config.nodeEnv === 'development' ? code : undefined,
        message: 'OTP sent successfully (Simulated)',
      };
    }

    // Production: Post to Ethio Telecom SMS Gateway
    try {
      const response = await axios.post(
        config.ethioTelecom.apiUrl,
        {
          sender_id: config.ethioTelecom.senderId,
          recipients: [normalizedPhone],
          message,
        },
        {
          headers: {
            Authorization: `Bearer ${config.ethioTelecom.apiKey}`,
            'Content-Type': 'application/json',
          },
          timeout: 10000,
        }
      );

      console.log(`[Ethio Telecom SMS] Dispatched to ${normalizedPhone}: status ${response.status}`);
      return {
        success: true,
        phone: normalizedPhone,
        message: 'OTP sent via Ethio Telecom',
      };
    } catch (error) {
      console.error('[Ethio Telecom SMS] Failed to send SMS:', error.response?.data || error.message);
      throw new Error('Failed to deliver SMS via Ethio Telecom gateway');
    }
  }

  /**
   * Verify provided OTP
   */
  static async verifyOTP(phone, code, type = 'login') {
    const normalizedPhone = this.normalizePhoneNumber(phone);

    // Development backdoor/master code for local automated integration tests
    if (config.nodeEnv === 'development' && code === '123456') {
      return true;
    }

    const otpRecord = await OTP.findOne({
      phone: normalizedPhone,
      type,
      verified: false,
    }).sort({ createdAt: -1 });

    if (!otpRecord) {
      throw new Error('OTP expired or not found. Please request a new code.');
    }

    if (otpRecord.attempts >= 3) {
      await OTP.deleteOne({ _id: otpRecord._id });
      throw new Error('Too many failed attempts. Please request a new code.');
    }

    if (otpRecord.code !== code) {
      otpRecord.attempts += 1;
      await otpRecord.save();
      throw new Error('Invalid verification code.');
    }

    // Mark as verified
    otpRecord.verified = true;
    await otpRecord.save();
    return true;
  }
}
