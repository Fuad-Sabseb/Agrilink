import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const cooperativeSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    coopCode: {
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
    type: {
      type: String,
      enum: ['primary_cooperative', 'union'],
      default: 'primary_cooperative',
      index: true,
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
    contactPerson: {
      type: String,
      required: true,
      trim: true,
    },
    contactPhone: {
      type: String,
      required: true,
      trim: true,
    },
    totalMembers: {
      type: Number,
      default: 150,
    },
    aggregatedVolumeKg: {
      type: Number,
      default: 50000,
    },
    servicesOffered: [
      {
        type: String,
        enum: [
          'bulk_selling',
          'input_loans',
          'coffee_washing_station',
          'warehousing',
          'transport',
          'seed_distribution',
        ],
      },
    ],
    supportedCrops: [
      {
        type: String,
        trim: true,
      },
    ],
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

export const Cooperative = mongoose.model('Cooperative', cooperativeSchema);
