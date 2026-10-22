import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const reportSchema = new mongoose.Schema(
  {
    _id: { type: String, default: () => uuidv4() },
    transporterId: { type: String, required: true },
    transporterName: { type: String, required: true },
    vehicleType: { type: String, default: 'isuzu_npr' },
    reportedFeeETB: { type: Number, required: true },
    delayMinutes: { type: Number, default: 15 },
    congestionLevel: {
      type: String,
      enum: ['clear_fast', 'active_moderate_delay', 'heavy_congestion'],
      default: 'active_moderate_delay',
    },
    comment: { type: String, default: '' },
    reportedAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const checkpointTariffSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    checkpointCode: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
    },
    corridorCode: {
      type: String,
      required: true,
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
    locationWoreda: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    locationCoordinates: {
      latitude: { type: Number, default: 7.67 },
      longitude: { type: Number, default: 36.83 },
    },
    checkpointType: {
      type: String,
      enum: [
        'formal_municipal',
        'agricultural_quarantine',
        'coffee_inspection_bureau',
        'informal_community_kella',
        'weighbridge',
      ],
      default: 'formal_municipal',
    },
    officialTariffETB: {
      type: Number,
      required: true,
      default: 150,
    },
    feeUnit: {
      type: String,
      enum: ['per_truck', 'per_quintal', 'flat_cargo'],
      default: 'per_truck',
    },
    currentLiveFeeETB: {
      type: Number,
      default: 150,
    },
    currentStatus: {
      type: String,
      enum: ['clear_fast', 'active_moderate_delay', 'heavy_congestion', 'closed'],
      default: 'clear_fast',
      index: true,
    },
    delayMinutesAvg: {
      type: Number,
      default: 10,
    },
    crowdReportsCount: {
      type: Number,
      default: 1,
    },
    upvotes: {
      type: Number,
      default: 12,
    },
    lastReportedAt: {
      type: Date,
      default: Date.now,
    },
    recentReports: [reportSchema],
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

export const CheckpointTariff = mongoose.model('CheckpointTariff', checkpointTariffSchema);
