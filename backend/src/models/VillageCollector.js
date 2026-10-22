import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const villageCollectorSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    collectorCode: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    nameAfaanOromoo: {
      type: String,
      required: true,
      trim: true,
    },
    contactPerson: {
      type: String,
      required: true,
      trim: true,
    },
    phone: {
      type: String,
      required: true,
      trim: true,
    },
    zone: {
      type: String,
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
      required: true,
      trim: true,
    },
    warehouseLocation: {
      type: String,
      required: true,
      trim: true,
    },
    storageCapacityQuintals: {
      type: Number,
      required: true,
      default: 500,
    },
    currentStoredQuintals: {
      type: Number,
      default: 0,
    },
    serviceCommissionRate: {
      rateType: {
        type: String,
        enum: ['percentage', 'fixed_per_quintal'],
        default: 'percentage',
      },
      value: {
        type: Number,
        required: true,
        default: 2.5, // e.g. 2.5% or 15 ETB/quintal
      },
      description: {
        type: String,
        default: 'Transparent disclosed commission fee per lot collected',
      },
    },
    supportedCrops: [
      {
        type: String,
        trim: true,
      },
    ],
    verificationBadge: {
      type: String,
      enum: ['bureau_certified', 'union_affiliated', 'registered_aggregator'],
      default: 'bureau_certified',
    },
    rating: {
      type: Number,
      default: 4.8,
      min: 1,
      max: 5,
    },
    totalTransactions: {
      type: Number,
      default: 35,
    },
    operatingStatus: {
      type: String,
      enum: ['actively_collecting', 'warehouse_full', 'seasonal_pause'],
      default: 'actively_collecting',
      index: true,
    },
    operatingHours: {
      type: String,
      default: '8:00 AM - 6:00 PM',
    },
    verifiedBy: {
      type: String,
      default: 'Jimma Zone Agriculture & Rural Development Bureau',
    },
    isVerified: {
      type: Boolean,
      default: true,
      index: true,
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

export const VillageCollector = mongoose.model('VillageCollector', villageCollectorSchema);
