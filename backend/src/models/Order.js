import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const orderSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    buyerId: {
      type: String,
      required: true,
      index: true,
      ref: 'User',
    },
    buyerName: {
      type: String,
      required: true,
    },
    buyerPhone: {
      type: String,
      default: '',
    },
    farmerId: {
      type: String,
      required: true,
      index: true,
      ref: 'User',
    },
    farmerName: {
      type: String,
      required: true,
    },
    farmerPhone: {
      type: String,
      default: '',
    },
    produceId: {
      type: String,
      required: true,
      ref: 'Produce',
    },
    cropName: {
      type: String,
      required: true,
    },
    quantity: {
      type: Number,
      required: true,
      min: 0,
    },
    unit: {
      type: String,
      default: 'kg',
    },
    unitPrice: {
      type: Number,
      required: true,
    },
    totalPrice: {
      type: Number,
      required: true,
    },
    currency: {
      type: String,
      default: 'ETB',
    },
    deliveryAddress: {
      type: String,
      default: '',
    },
    status: {
      type: String,
      enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'],
      default: 'pending',
      index: true,
    },
    paymentMethod: {
      type: String,
      enum: ['telebirr', 'cbe_birr', 'cash_on_delivery', 'mock'],
      default: 'telebirr',
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'paid', 'refunded', 'failed'],
      default: 'pending',
      index: true,
    },
    transporterId: {
      type: String,
      default: null,
      ref: 'User',
    },
    notes: {
      type: String,
      default: '',
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

export const Order = mongoose.model('Order', orderSchema);
