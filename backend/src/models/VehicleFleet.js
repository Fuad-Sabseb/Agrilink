import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const vehicleFleetSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    plateNumber: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
    },
    transporterId: {
      type: String,
      required: true,
      ref: 'User',
      index: true,
    },
    transporterName: {
      type: String,
      required: true,
      trim: true,
    },
    driverPhone: {
      type: String,
      required: true,
      trim: true,
    },
    carrierType: {
      type: String,
      enum: ['pickup', 'isuzu_npr', 'fsr_truck', 'heavy_truck'],
      required: true,
      index: true,
    },
    carrierTypeName: {
      type: String,
      default: 'Isuzu NPR (Short Truck)',
    },
    carrierTypeNameAfaanOromoo: {
      type: String,
      default: 'Isuzuu Gabaabaa (NPR)',
    },
    modelYear: {
      type: Number,
      default: 2018,
    },
    maxPayloadKg: {
      type: Number,
      required: true,
      default: 4500, // in kg
    },
    maxPayloadQuintals: {
      type: Number,
      default: function () {
        return Math.round(this.maxPayloadKg / 100);
      },
    },
    volumeCubicMeters: {
      type: Number,
      default: 18,
    },
    baseWoreda: {
      type: String,
      required: true,
      default: 'Jimma Town',
      index: true,
    },
    currentWoredaLocation: {
      type: String,
      default: 'Jimma Town',
    },
    perKmBaseRateETB: {
      type: Number,
      required: true,
      default: 28.0, // ETB / km
    },
    perQuintalHandlingRateETB: {
      type: Number,
      default: 12.0, // ETB / quintal handling
    },
    isRefrigerated: {
      type: Boolean,
      default: false,
    },
    suitableCrops: [
      {
        type: String,
        trim: true,
      },
    ],
    availabilityStatus: {
      type: String,
      enum: ['available', 'on_trip', 'maintenance'],
      default: 'available',
      index: true,
    },
    insuranceValid: {
      type: Boolean,
      default: true,
    },
    rating: {
      type: Number,
      default: 4.9,
    },
    completedTrips: {
      type: Number,
      default: 42,
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

// Auto-calculate maxPayloadQuintals
vehicleFleetSchema.pre('save', function (next) {
  if (this.maxPayloadKg) {
    this.maxPayloadQuintals = Math.round(this.maxPayloadKg / 100);
  }
  next();
});

export const VehicleFleet = mongoose.model('VehicleFleet', vehicleFleetSchema);
