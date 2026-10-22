import mongoose from 'mongoose';
import { v4 as uuidv4 } from 'uuid';

const notificationSchema = new mongoose.Schema(
  {
    _id: {
      type: String,
      default: () => uuidv4(),
    },
    userId: {
      type: String,
      required: true,
      index: true,
      ref: 'User',
    },
    title: {
      type: String,
      required: true,
    },
    body: {
      type: String,
      required: true,
    },
    type: {
      type: String,
      enum: ['order', 'delivery', 'inspection', 'payment', 'system', 'demand_match', 'marketplace'],
      default: 'system',
    },
    data: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
    isRead: {
      type: Boolean,
      default: false,
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

export const Notification = mongoose.model('Notification', notificationSchema);
