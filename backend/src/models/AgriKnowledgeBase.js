import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const agriKnowledgeBaseSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    topicId: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    crop: {
      type: String,
      required: true,
      default: 'General',
      index: true,
    },
    cropAfaanOromoo: {
      type: String,
      default: 'Waliigala',
    },
    category: {
      type: String,
      enum: ['plant_pathology', 'soil_and_agronomy', 'seasonal_calendar', 'market_and_credit'],
      required: true,
      index: true,
    },
    title: {
      type: String,
      required: true,
    },
    titleAfaanOromoo: {
      type: String,
      required: true,
    },
    scientificName: {
      type: String,
      default: '',
    },
    keywords: [
      {
        type: String,
        lowercase: true,
        trim: true,
      },
    ],
    symptoms: {
      en: { type: String, default: '' },
      om: { type: String, default: '' },
    },
    prevalenceInJimma: {
      type: String,
      default: 'Jimma Zone midland and highland woredas',
    },
    recommendedVarieties: {
      type: String,
      default: 'Jimma Agricultural Research Center (JARC) certified cultivars',
    },
    treatmentProtocol: {
      culturalEn: { type: String, default: '' },
      culturalOm: { type: String, default: '' },
      organicEn: { type: String, default: '' },
      organicOm: { type: String, default: '' },
      chemicalApprovedEn: { type: String, default: '' },
      chemicalApprovedOm: { type: String, default: '' },
    },
    prevention: {
      en: { type: String, default: '' },
      om: { type: String, default: '' },
    },
    confidenceBaseline: {
      type: Number,
      default: 0.95,
    },
    isVerifiedByJARC: {
      type: Boolean,
      default: true,
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

agriKnowledgeBaseSchema.index({ keywords: 1 });

export const AgriKnowledgeBase = mongoose.model('AgriKnowledgeBase', agriKnowledgeBaseSchema);
