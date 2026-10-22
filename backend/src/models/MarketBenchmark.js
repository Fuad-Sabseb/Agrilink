import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const commodityPriceSchema = new mongoose.Schema({
  _id: {
    type: String,
    default: () => uuidv4(),
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
  cropType: {
    type: String,
    enum: ['Grain', 'Cash Crop', 'Tuber', 'Vegetable', 'Fruit', 'Spice'],
    default: 'Grain',
  },
  pricePerKg: {
    type: Number,
    required: true,
    min: 0,
  },
  qualityGrade: {
    type: String,
    enum: ['Grade 1', 'Grade 2', 'Grade 3', 'Standard'],
    default: 'Grade 1',
  },
  trend: {
    type: String,
    default: '0.0%',
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

const marketBenchmarkSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    marketCode: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
      index: true,
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
    region: {
      type: String,
      required: true,
      default: 'Oromia',
    },
    zone: {
      type: String,
      required: true,
      default: 'Jimma',
    },
    woreda: {
      type: String,
      default: '',
    },
    isPrimaryLocalMarket: {
      type: Boolean,
      default: false,
    },
    coordinates: {
      latitude: { type: Number, required: true },
      longitude: { type: Number, required: true },
    },
    // Matrix of distances in km from key Jimma agricultural woredas
    distanceMatrixKm: {
      type: Map,
      of: Number,
      default: {},
    },
    defaultDistanceKm: {
      type: Number,
      required: true,
      default: 20,
    },
    // Fixed checkpoint and transit toll fees along this route in ETB
    baseTransitFee: {
      type: Number,
      default: 500,
    },
    roadQualityFactor: {
      type: Number,
      default: 1.0, // 1.0 = asphalt highway, 1.2 = gravel / rugged terrain
    },
    commodityPrices: [commodityPriceSchema],
    isActive: {
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

// Index for geo and code lookups
marketBenchmarkSchema.index({ marketCode: 1, isActive: 1 });

export const MarketBenchmark = mongoose.model('MarketBenchmark', marketBenchmarkSchema);
