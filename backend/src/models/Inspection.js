import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const findingSchema = new mongoose.Schema({
  _id: {
    type: String,
    default: () => uuidv4(),
  },
  title: {
    type: String,
    required: true,
  },
  severity: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'low',
  },
  description: {
    type: String,
    default: '',
  },
  photoUrl: {
    type: String,
    default: null,
  },
  recordedAt: {
    type: Date,
    default: Date.now,
  },
});

const inspectionSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    officerId: {
      type: String,
      required: true,
      index: true,
      ref: 'User',
    },
    officerName: {
      type: String,
      required: true,
    },
    woredaName: {
      type: String,
      required: true,
      index: true,
    },
    targetType: {
      type: String,
      enum: ['farm', 'cooperative'],
      required: true,
    },
    cooperativeName: {
      type: String,
      default: null,
    },
    farmName: {
      type: String,
      default: null,
    },
    type: {
      type: String,
      enum: ['routine', 'quality_audit', 'compliance', 'quality_certification'],
      default: 'routine',
    },
    status: {
      type: String,
      enum: ['scheduled', 'in_progress', 'completed', 'flagged'],
      default: 'scheduled',
      index: true,
    },
    findings: [findingSchema],
    signatureUrl: {
      type: String,
      default: null,
    },
    checkInTime: {
      type: Date,
      default: Date.now,
    },
    checkOutTime: {
      type: Date,
      default: null,
    },
    notes: {
      type: String,
      default: null,
    },
    issueCount: {
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

export const Inspection = mongoose.model('Inspection', inspectionSchema);
