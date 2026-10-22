import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const cropCycleSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    farmId: {
      type: String,
      required: true,
      ref: 'Farm',
      index: true,
    },
    farmerId: {
      type: String,
      required: true,
      ref: 'User',
      index: true,
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
    },
    cropNameAfaanOromoo: {
      type: String,
      required: true,
      trim: true,
    },
    variety: {
      type: String,
      trim: true,
      default: 'Standard Regional Variety',
    },
    areaHectares: {
      type: Number,
      required: true,
      min: 0.01,
    },
    areaQadaa: {
      type: Number,
      default: function () {
        return Number((this.areaHectares * 4).toFixed(2));
      },
    },
    growthStage: {
      type: String,
      enum: ['seedling', 'vegetative', 'flowering', 'maturation', 'harvest_ready', 'harvested'],
      default: 'vegetative',
      index: true,
    },
    plantingDate: {
      type: Date,
      default: Date.now,
    },
    expectedHarvestStart: {
      type: Date,
      required: true,
    },
    expectedHarvestEnd: {
      type: Date,
      required: true,
    },
    expectedYieldKg: {
      type: Number,
      required: true,
      min: 1,
    },
    expectedYieldQuintals: {
      type: Number,
      default: function () {
        return Number((this.expectedYieldKg / 100).toFixed(2));
      },
    },
    expectedQualityGrade: {
      type: String,
      enum: ['Grade 1 (Export)', 'Grade 2 (Commercial)', 'Grade 3 (Standard)'],
      default: 'Grade 1 (Export)',
    },
    actualHarvestedKg: {
      type: Number,
      default: 0,
    },
    status: {
      type: String,
      enum: ['planted', 'growing', 'harvesting', 'completed', 'damaged'],
      default: 'growing',
      index: true,
    },
    notes: {
      type: String,
      trim: true,
      default: '',
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (doc, ret) => {
        ret.id = ret._id;
        ret.areaHectares = String(ret.areaHectares);
        ret.expectedYieldKg = ret.expectedYieldKg != null ? String(ret.expectedYieldKg) : null;
        ret.harvestStart = ret.expectedHarvestStart ? ret.expectedHarvestStart.toISOString() : null;
        ret.harvestEnd = ret.expectedHarvestEnd ? ret.expectedHarvestEnd.toISOString() : null;
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

// Auto-calculate areaQadaa and expectedYieldQuintals
cropCycleSchema.pre('save', function (next) {
  if (this.areaHectares) {
    this.areaQadaa = Number((this.areaHectares * 4).toFixed(2));
  }
  if (this.expectedYieldKg) {
    this.expectedYieldQuintals = Number((this.expectedYieldKg / 100).toFixed(2));
  }
  next();
});

export const CropCycle = mongoose.model('CropCycle', cropCycleSchema);
