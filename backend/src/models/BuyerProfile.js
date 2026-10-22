import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const buyerProfileSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    userId: {
      type: String,
      required: true,
      ref: 'User',
      index: true,
    },
    businessName: {
      type: String,
      required: true,
      trim: true,
    },
    businessNameAfaanOromoo: {
      type: String,
      trim: true,
    },
    buyerType: {
      type: String,
      enum: ['wholesaler', 'local_collector', 'exporter', 'processor', 'retailer', 'cooperative'],
      default: 'wholesaler',
      index: true,
    },
    contactPhone: {
      type: String,
      required: true,
      trim: true,
    },
    zone: {
      type: String,
      required: true,
      default: 'Jimma',
      index: true,
    },
    woreda: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    kebele: {
      type: String,
      trim: true,
      default: '',
    },
    specificLocation: {
      type: String,
      required: true,
      trim: true,
    },
    isVerified: {
      type: Boolean,
      default: true,
      index: true,
    },
    verificationBadge: {
      type: String,
      enum: ['verified_merchant', 'union_partner', 'licensed_exporter', 'certified_collector'],
      default: 'verified_merchant',
    },
    reliabilityScore: {
      type: Number,
      min: 0,
      max: 5,
      default: 4.8,
    },
    reliabilityPercentage: {
      type: Number,
      min: 0,
      max: 100,
      default: 96,
    },
    totalTransactions: {
      type: Number,
      default: 25,
    },
    completedDeals: {
      type: Number,
      default: 24,
    },
    noShowCount: {
      type: Number,
      default: 0,
    },
    onTimeArrivalRate: {
      type: Number,
      min: 0,
      max: 100,
      default: 96,
    },
    disclosedFeePercent: {
      type: Number,
      default: 0.0, // Commission rate for local village collectors
    },
    // Real-time live "Buying Now" status toggle
    isBuyingNow: {
      type: Boolean,
      default: false,
      index: true,
    },
    activeBuyingLocation: {
      type: String,
      trim: true,
      default: '',
    },
    todayOperatingHours: {
      type: String,
      default: '8:00 AM - 5:00 PM',
    },
    lastActiveAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (doc, ret) => {
        ret.id = ret._id;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

export const BuyerProfile = mongoose.model('BuyerProfile', buyerProfileSchema);
