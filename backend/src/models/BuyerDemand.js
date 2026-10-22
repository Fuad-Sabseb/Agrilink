import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const buyerDemandSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    buyerId: {
      type: String,
      required: true,
      ref: 'User',
      index: true,
    },
    buyerProfileId: {
      type: String,
      ref: 'BuyerProfile',
      index: true,
    },
    // Snapshot of buyer details for ultra-fast query and offline caching
    buyer: {
      businessName: { type: String, required: true },
      businessNameAfaanOromoo: { type: String },
      contactPhone: { type: String, required: true },
      buyerType: {
        type: String,
        enum: ['wholesaler', 'local_collector', 'exporter', 'processor', 'retailer', 'cooperative'],
        default: 'wholesaler',
      },
      isVerified: { type: Boolean, default: true },
      verificationBadge: { type: String, default: 'verified_merchant' },
      reliabilityScore: { type: Number, default: 4.8 },
      reliabilityPercentage: { type: Number, default: 96 },
      noShowCount: { type: Number, default: 0 },
      disclosedFeePercent: { type: Number, default: 0.0 },
    },
    cropId: {
      type: String,
      required: true,
      index: true,
    },
    cropName: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    cropNameAfaanOromoo: {
      type: String,
      required: true,
      trim: true,
    },
    preferredGrade: {
      type: String,
      enum: ['Grade 1 (Export)', 'Grade 2 (Commercial)', 'Grade 3 (Standard)', 'All Grades'],
      default: 'Grade 1 (Export)',
    },
    minimumQuantityKg: {
      type: Number,
      required: true,
      min: 1,
      default: 50,
    },
    maximumQuantityKg: {
      type: Number,
      required: true,
      min: 1,
      default: 2000,
    },
    fulfilledQuantityKg: {
      type: Number,
      default: 0,
      min: 0,
    },
    priceOfferPerKg: {
      type: Number,
      required: true,
      min: 0,
    },
    status: {
      type: String,
      enum: ['buying_now', 'active', 'paused', 'fulfilled', 'closed'],
      default: 'buying_now',
      index: true,
    },
    // Live "Buying Now" presence indicator
    isBuyingNow: {
      type: Boolean,
      default: true,
      index: true,
    },
    buyingPostLocation: {
      type: String,
      required: true,
      trim: true,
    },
    pickupZone: {
      type: String,
      required: true,
      default: 'Jimma',
    },
    pickupWoreda: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    transportProvided: {
      type: Boolean,
      default: false, // true = collector picks up from village/farm; false = farmer delivers to town
    },
    disclosedFeePercent: {
      type: Number,
      default: 0.0,
    },
    operatingHoursToday: {
      type: String,
      default: '8:00 AM - 5:00 PM',
    },
    neededBy: {
      type: Date,
      default: () => new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // Default 7 days from now
    },
    expiresAt: {
      type: Date,
      default: () => new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    },
    additionalNotes: {
      type: String,
      trim: true,
      default: '',
    },
    additionalNotesAfaanOromoo: {
      type: String,
      trim: true,
      default: '',
    },
    responseCount: {
      type: Number,
      default: 0,
    },
    viewCount: {
      type: Number,
      default: 0,
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

// Compound index for matching queries
buyerDemandSchema.index({ cropName: 1, status: 1, isBuyingNow: 1 });
buyerDemandSchema.index({ pickupWoreda: 1, status: 1 });

export const BuyerDemand = mongoose.model('BuyerDemand', buyerDemandSchema);
