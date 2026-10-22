import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const produceSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    farmerId: {
      type: String,
      required: true,
      index: true,
      ref: 'User',
    },
    farmerName: {
      type: String,
      required: true,
    },
    cropName: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    cropType: {
      type: String,
      required: true,
      trim: true,
    },
    quantity: {
      type: Number,
      required: true,
      min: 0,
    },
    unit: {
      type: String,
      default: 'kg',
      enum: ['kg', 'quintal', 'crate', 'ton'],
    },
    pricePerUnit: {
      type: Number,
      required: true,
      min: 0,
    },
    currency: {
      type: String,
      default: 'ETB',
    },
    description: {
      type: String,
      default: '',
    },
    location: {
      type: String,
      required: true,
    },
    woreda: {
      type: String,
      default: '',
    },
    qualityGrade: {
      type: String,
      default: 'Grade 1',
    },
    harvestDate: {
      type: Date,
      default: Date.now,
    },
    images: {
      type: [String],
      default: [],
    },
    status: {
      type: String,
      enum: ['available', 'reserved', 'sold', 'unlisted'],
      default: 'available',
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

// Search index for cropName, description, and location
produceSchema.index({ cropName: 'text', description: 'text', location: 'text' });

export const Produce = mongoose.model('Produce', produceSchema);
