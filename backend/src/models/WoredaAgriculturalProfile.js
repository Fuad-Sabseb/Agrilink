import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const woredaAgriculturalProfileSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    woreda: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      index: true,
    },
    woredaAfaanOromoo: {
      type: String,
      required: true,
      trim: true,
    },
    zone: {
      type: String,
      required: true,
      default: 'Jimma',
      index: true,
    },
    agroEcologicalZone: {
      type: String,
      enum: ['highland_dega', 'midland_weyna_dega', 'lowland_kola'],
      default: 'midland_weyna_dega',
    },
    dominantSoil: {
      type: String,
      enum: ['nitisol_red_clay', 'vertisol_black_clay', 'alluvial_loam'],
      default: 'nitisol_red_clay',
    },
    arableLandHectares: {
      type: Number,
      required: true,
      min: 0,
    },
    arableLandQadaa: {
      type: Number,
      default: function () {
        return Number((this.arableLandHectares * 4).toFixed(2));
      },
    },
    farmingHouseholds: {
      type: Number,
      required: true,
      min: 0,
    },
    estimatedPopulation: {
      type: Number,
      required: true,
      min: 0,
    },
    annualStapleDemandQuintals: {
      type: Number,
      required: true,
      default: 10000,
    },
    cashCropProductionAnnualQuintals: {
      type: Number,
      default: 5000,
    },
    foodSecurityVulnerability: {
      type: String,
      enum: ['low', 'moderate', 'high_risk'],
      default: 'low',
    },
    activeCooperativesCount: {
      type: Number,
      default: 3,
    },
    primaryMarkets: [
      {
        type: String,
        trim: true,
      },
    ],
    coordinates: {
      latitude: { type: Number, required: true },
      longitude: { type: Number, required: true },
    },
    priorityCrops: [
      {
        type: String,
        trim: true,
      },
    ],
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

export const WoredaAgriculturalProfile = mongoose.model(
  'WoredaAgriculturalProfile',
  woredaAgriculturalProfileSchema
);
