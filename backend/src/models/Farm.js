import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const farmSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    farmerId: {
      type: String,
      required: true,
      ref: 'User',
      index: true,
    },
    farmerName: {
      type: String,
      required: true,
      trim: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    sizeHectares: {
      type: Number,
      required: true,
      min: 0.05,
    },
    sizeQadaa: {
      type: Number,
      default: function () {
        return Number((this.sizeHectares * 4).toFixed(2));
      },
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
    latitude: {
      type: Number,
      default: 7.67,
    },
    longitude: {
      type: Number,
      default: 36.83,
    },
    altitudeMeters: {
      type: Number,
      default: 1950, // Typical Jimma midland altitude
    },
    soilType: {
      type: String,
      enum: ['nitisol_red_clay', 'vertisol_black_clay', 'cambisol', 'loam_sandy'],
      default: 'nitisol_red_clay', // Native fertile red loam of Jimma
    },
    agroEcology: {
      type: String,
      enum: ['highland_dega', 'midland_weyna_dega', 'lowland_kolla'],
      default: 'midland_weyna_dega',
    },
    waterSource: {
      type: String,
      enum: ['rainfed', 'river_stream', 'well_borehole', 'drip_irrigation'],
      default: 'rainfed',
    },
    cooperativeId: {
      type: String,
      ref: 'Cooperative',
      index: true,
    },
    cooperativeName: {
      type: String,
      trim: true,
      default: '',
    },
    cooperativeMembershipId: {
      type: String,
      trim: true,
      default: '',
    },
    isVerified: {
      type: Boolean,
      default: true,
    },
    plotsCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
    toJSON: {
      transform: (doc, ret) => {
        ret.id = ret._id;
        // Keep sizeHectares as string formatted for compatibility with web client DECIMAL parsing
        ret.sizeHectares = String(ret.sizeHectares);
        delete ret._id;
        delete ret.__v;
        return ret;
      },
    },
  }
);

// Auto-update sizeQadaa on save
farmSchema.pre('save', function (next) {
  if (this.sizeHectares) {
    this.sizeQadaa = Number((this.sizeHectares * 4).toFixed(2));
  }
  next();
});

export const Farm = mongoose.model('Farm', farmSchema);
