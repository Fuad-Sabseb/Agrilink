import { Trip } from '../models/Trip.js';
import { Order } from '../models/Order.js';
import { PushNotificationService } from '../services/pushNotificationService.js';

export class TransportController {
  /**
   * List available transport requests (Orders needing transportation)
   */
  static async listTransportRequests(req, res, next) {
    try {
      // Find orders that are confirmed and need delivery
      const orders = await Order.find({
        status: { $in: ['confirmed', 'shipped'] },
        transporterId: null,
      }).sort({ createdAt: -1 });

      const requests = orders.map((o) => ({
        id: `REQ_${o.id}`,
        orderId: o.id,
        cropName: o.cropName,
        quantity: o.quantity,
        unit: o.unit,
        pickupLocation: o.farmerName + ' Farm',
        deliveryAddress: o.deliveryAddress,
        totalPrice: o.totalPrice,
        createdAt: o.createdAt,
      }));

      return res.status(200).json({
        success: true,
        count: requests.length,
        requests,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Transporter accepts request / creates trip
   */
  static async createTrip(req, res, next) {
    try {
      const { orderId, scheduledPickupTime, distanceKm, earnings } = req.body;
      const order = await Order.findById(orderId);

      if (!order) {
        return res.status(404).json({
          success: false,
          error: 'Order not found',
        });
      }

      if (order.transporterId) {
        return res.status(400).json({
          success: false,
          error: 'This order has already been assigned to another transporter',
        });
      }

      const trip = await Trip.create({
        orderId: order.id,
        transporterId: req.user.id,
        transporterName: req.user.fullName,
        pickupLocation: order.farmerName + ' Farm',
        dropoffLocation: order.deliveryAddress,
        scheduledPickupTime: scheduledPickupTime || new Date(),
        distanceKm: distanceKm || 25,
        earnings: earnings || parseFloat((order.totalPrice * 0.1).toFixed(2)),
        status: 'assigned',
      });

      order.transporterId = req.user.id;
      order.status = 'shipped';
      await order.save();

      // Notify Buyer and Farmer
      await PushNotificationService.sendToUser(order.buyerId, {
        title: 'Transporter Assigned 🚚',
        body: `${req.user.fullName} has accepted delivery for your order of ${order.cropName}.`,
        type: 'delivery',
        data: { tripId: trip.id, orderId: order.id },
      });

      return res.status(201).json({
        success: true,
        message: 'Trip accepted and assigned successfully',
        trip: trip.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get trips for a specific transporter
   */
  static async getTransporterTrips(req, res, next) {
    try {
      const transporterId = req.params.transporterId || req.user.id;
      const trips = await Trip.find({ transporterId }).sort({ createdAt: -1 });

      return res.status(200).json({
        success: true,
        count: trips.length,
        trips: trips.map((t) => t.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get single trip details
   */
  static async getTripById(req, res, next) {
    try {
      const trip = await Trip.findById(req.params.id);
      if (!trip) {
        return res.status(404).json({
          success: false,
          error: 'Trip not found',
        });
      }

      return res.status(200).json({
        success: true,
        trip: trip.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update trip status (picked_up, in_transit, etc.)
   */
  static async updateTripStatus(req, res, next) {
    try {
      const { status } = req.body;
      const trip = await Trip.findById(req.params.id);

      if (!trip) {
        return res.status(404).json({
          success: false,
          error: 'Trip not found',
        });
      }

      trip.status = status;
      if (status === 'picked_up') {
        trip.actualPickupTime = new Date();
      }
      await trip.save();

      return res.status(200).json({
        success: true,
        message: `Trip status updated to ${status}`,
        trip: trip.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Submit Proof of Delivery (POD)
   */
  static async submitProofOfDelivery(req, res, next) {
    try {
      const { recipientName, photoUrl, signatureUrl, notes } = req.body;
      const trip = await Trip.findById(req.params.id);

      if (!trip) {
        return res.status(404).json({
          success: false,
          error: 'Trip not found',
        });
      }

      if (!recipientName || !photoUrl) {
        return res.status(400).json({
          success: false,
          error: 'Recipient name and proof photo are required for delivery verification',
        });
      }

      trip.status = 'delivered';
      trip.deliveryTime = new Date();
      trip.proofOfDelivery = {
        recipientName,
        photoUrl,
        signatureUrl,
        notes,
        deliveredAt: new Date(),
      };
      await trip.save();

      // Update associated Order to delivered
      const order = await Order.findById(trip.orderId);
      if (order) {
        order.status = 'delivered';
        await order.save();

        // Notify Buyer
        await PushNotificationService.sendToUser(order.buyerId, {
          title: 'Order Delivered! 🎉',
          body: `Your order for ${order.cropName} has been delivered and received by ${recipientName}.`,
          type: 'delivery',
          data: { orderId: order.id, tripId: trip.id },
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Proof of Delivery confirmed successfully',
        trip: trip.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }
}
