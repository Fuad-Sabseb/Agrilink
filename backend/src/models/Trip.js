import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const tripSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    orderId: {
      type: String,
      required: true,
      ref: 'Order',
    },
    transporterId: {
      type: String,
      required: true,
      index: true,
      ref: 'User',
    },
    transporterName: {
      type: String,
      required: true,
    },
    pickupLocation: {
      type: String,
      required: true,
    },
    dropoffLocation: {
      type: String,
      required: true,
    },
    scheduledPickupTime: {
      type: Date,
      default: null,
    },
    actualPickupTime: {
      type: Date,
      default: null,
    },
    deliveryTime: {
      type: Date,
      default: null,
    },
    status: {
      type: String,
      enum: ['assigned', 'picked_up', 'in_transit', 'delivered', 'cancelled'],
      default: 'assigned',
      index: true,
    },
    earnings: {
      type: Number,
      default: 0,
    },
    distanceKm: {
      type: Number,
      default: 0,
    },
    proofOfDelivery: {
      recipientName: { type: String, default: null },
      photoUrl: { type: String, default: null },
      signatureUrl: { type: String, default: null },
      notes: { type: String, default: null },
      deliveredAt: { type: Date, default: null },
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

export const Trip = mongoose.model('Trip', tripSchema);
