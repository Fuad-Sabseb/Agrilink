import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const institutionalAlertSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    alertCode: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    alertType: {
      type: String,
      enum: [
        'food_security_deficit',
        'price_volatility_spike',
        'pest_disease_outbreak',
        'logistics_bottleneck',
        'advisory',
      ],
      required: true,
      index: true,
    },
    severity: {
      type: String,
      enum: ['critical', 'warning', 'advisory', 'info'],
      default: 'warning',
      index: true,
    },
    title: {
      type: String,
      required: true,
      trim: true,
    },
    titleAfaanOromoo: {
      type: String,
      required: true,
      trim: true,
    },
    targetWoredas: [
      {
        type: String,
        trim: true,
      },
    ],
    targetCrop: {
      type: String,
      default: 'General',
      trim: true,
    },
    description: {
      type: String,
      required: true,
    },
    descriptionAfaanOromoo: {
      type: String,
      required: true,
    },
    recommendedAction: {
      type: String,
      required: true,
    },
    recommendedActionAfaanOromoo: {
      type: String,
      required: true,
    },
    issuedBy: {
      userId: { type: String, default: 'user_bureau_derartu' },
      name: { type: String, default: 'Jimma Zone Agriculture Bureau' },
      role: { type: String, default: 'bureau' },
      institution: {
        type: String,
        default: 'Jimma Zone Agriculture & Rural Development Bureau',
      },
    },
    metricPayload: {
      deficitQuintals: { type: Number, default: 0 },
      priceSpikePercent: { type: Number, default: 0 },
      affectedHouseholds: { type: Number, default: 0 },
      affectedHectares: { type: Number, default: 0 },
      confidencePercent: { type: Number, default: 95 },
    },
    status: {
      type: String,
      enum: ['active', 'monitoring', 'resolved'],
      default: 'active',
      index: true,
    },
    resolvedAt: {
      type: Date,
      default: null,
    },
    resolutionNotes: {
      type: String,
      default: null,
    },
    resolvedBy: {
      type: String,
      default: null,
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

export const InstitutionalAlert = mongoose.model(
  'InstitutionalAlert',
  institutionalAlertSchema
);
