import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const paymentSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    orderId: {
      type: String,
      required: true,
      index: true,
      ref: 'Order',
    },
    userId: {
      type: String,
      required: true,
      ref: 'User',
    },
    amount: {
      type: Number,
      required: true,
    },
    currency: {
      type: String,
      default: 'ETB',
    },
    method: {
      type: String,
      enum: ['telebirr', 'cbe_birr', 'cash_on_delivery'],
      default: 'telebirr',
    },
    status: {
      type: String,
      enum: ['initiated', 'completed', 'failed', 'refunded'],
      default: 'initiated',
      index: true,
    },
    // Telebirr specific fields
    outTradeNo: {
      type: String,
      unique: true,
      sparse: true,
      index: true,
    },
    telebirrPrepayId: {
      type: String,
      default: null,
    },
    telebirrTransactionNo: {
      type: String,
      default: null,
    },
    checkoutUrl: {
      type: String,
      default: null,
    },
    rawCallbackData: {
      type: mongoose.Schema.Types.Mixed,
      default: null,
    },
    paidAt: {
      type: Date,
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

export const Payment = mongoose.model('Payment', paymentSchema);
