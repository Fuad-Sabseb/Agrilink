import mongoose from 'mongoose';

const otpSchema = new mongoose.Schema(
  {
    phone: {
      type: String,
      required: true,
      index: true,
      trim: true,
    },
    code: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      enum: ['login', 'register', 'password_reset', 'verify_phone'],
      default: 'login',
    },
    verified: {
      type: Boolean,
      default: false,
    },
    attempts: {
      type: Number,
      default: 0,
    },
    createdAt: {
      type: Date,
      default: Date.now,
      expires: 300, // 5 minutes TTL in MongoDB
    },
  },
  {
    timestamps: true,
  }
);

export const OTP = mongoose.model('OTP', otpSchema);
