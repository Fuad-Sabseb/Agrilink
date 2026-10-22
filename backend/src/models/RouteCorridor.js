import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const routeCorridorSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    corridorCode: {
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
    origin: {
      zone: { type: String, default: 'Jimma' },
      woreda: { type: String, required: true },
    },
    destination: {
      zone: { type: String, default: 'Jimma' },
      woreda: { type: String, required: true },
      marketHub: { type: String, required: true },
    },
    distanceKm: {
      type: Number,
      required: true,
      min: 1,
    },
    roadCondition: {
      type: String,
      enum: ['asphalt_good', 'asphalt_potholes', 'gravel_compacted', 'gravel_rough', 'muddy_seasonal'],
      default: 'asphalt_good',
    },
    roadConditionMultiplier: {
      type: Number,
      default: 1.0, // 1.0 = asphalt, 1.2 = gravel, 1.45 = rough, 1.8 = seasonal mud
    },
    averageTransitHours: {
      type: Number,
      default: 1.0,
    },
    elevationProfile: {
      type: String,
      default: 'Midland Weyna Dega (1,750m - 2,050m)',
    },
    checkpointsCount: {
      type: Number,
      default: 1,
    },
    baseFuelCostETB: {
      type: Number,
      default: 450,
    },
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

export const RouteCorridor = mongoose.model('RouteCorridor', routeCorridorSchema);
