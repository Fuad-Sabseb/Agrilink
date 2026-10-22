import { Order } from '../models/Order.js';
import { Produce } from '../models/Produce.js';
import { PushNotificationService } from '../services/pushNotificationService.js';

export class OrderController {
  /**
   * Create new order (Buyer)
   */
  static async createOrder(req, res, next) {
    try {
      const { produceId, quantity, deliveryAddress, paymentMethod, notes } = req.body;

      if (!produceId || !quantity) {
        return res.status(400).json({
          success: false,
          error: 'produceId and quantity are required',
        });
      }

      const produce = await Produce.findById(produceId);
      if (!produce) {
        return res.status(404).json({
          success: false,
          error: 'Produce not found',
        });
      }

      if (produce.quantity < quantity) {
        return res.status(400).json({
          success: false,
          error: `Insufficient stock. Only ${produce.quantity} ${produce.unit} available.`,
        });
      }

      const orderQty = parseFloat(quantity);
      const totalPrice = parseFloat((orderQty * produce.pricePerUnit).toFixed(2));

      const order = await Order.create({
        buyerId: req.user.id,
        buyerName: req.user.fullName,
        buyerPhone: req.user.phone,
        farmerId: produce.farmerId,
        farmerName: produce.farmerName,
        produceId: produce.id,
        cropName: produce.cropName,
        quantity: orderQty,
        unit: produce.unit,
        unitPrice: produce.pricePerUnit,
        totalPrice,
        currency: produce.currency || 'ETB',
        deliveryAddress: deliveryAddress || req.user.location,
        paymentMethod: paymentMethod || 'telebirr',
        paymentStatus: 'pending',
        status: 'pending',
        notes: notes || '',
      });

      // Update remaining stock
      produce.quantity -= orderQty;
      if (produce.quantity <= 0) {
        produce.status = 'sold';
      }
      await produce.save();

      // Dispatch Push Notification to Farmer
      await PushNotificationService.sendToUser(produce.farmerId, {
        title: 'New Order Received! 🌾',
        body: `${req.user.fullName} placed an order for ${orderQty} ${produce.unit} of ${produce.cropName} (${totalPrice} ETB).`,
        type: 'order',
        data: { orderId: order.id },
      });

      return res.status(201).json({
        success: true,
        message: 'Order placed successfully',
        order: order.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get single order by ID
   */
  static async getOrderById(req, res, next) {
    try {
      const order = await Order.findById(req.params.id);
      if (!order) {
        return res.status(404).json({
          success: false,
          error: 'Order not found',
        });
      }

      return res.status(200).json({
        success: true,
        order: order.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * List all orders (filtered by current user role)
   */
  static async listOrders(req, res, next) {
    try {
      const query = {};
      if (req.user.role === 'buyer') {
        query.buyerId = req.user.id;
      } else if (req.user.role === 'farmer') {
        query.farmerId = req.user.id;
      } else if (req.user.role === 'transporter') {
        query.transporterId = req.user.id;
      }

      const orders = await Order.find(query).sort({ createdAt: -1 });

      return res.status(200).json({
        success: true,
        count: orders.length,
        orders: orders.map((o) => o.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get orders for a specific buyer
   */
  static async getBuyerOrders(req, res, next) {
    try {
      const orders = await Order.find({ buyerId: req.params.userId }).sort({ createdAt: -1 });
      return res.status(200).json({
        success: true,
        count: orders.length,
        orders: orders.map((o) => o.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get orders for a specific farmer
   */
  static async getFarmerOrders(req, res, next) {
    try {
      const orders = await Order.find({ farmerId: req.params.userId }).sort({ createdAt: -1 });
      return res.status(200).json({
        success: true,
        count: orders.length,
        orders: orders.map((o) => o.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update order status
   */
  static async updateOrderStatus(req, res, next) {
    try {
      const { status } = req.body;
      const order = await Order.findById(req.params.id);

      if (!order) {
        return res.status(404).json({
          success: false,
          error: 'Order not found',
        });
      }

      order.status = status;
      await order.save();

      // Notify Buyer of status change
      await PushNotificationService.sendToUser(order.buyerId, {
        title: `Order Status: ${status.toUpperCase()}`,
        body: `Your order for ${order.cropName} is now ${status}.`,
        type: 'order',
        data: { orderId: order.id, status },
      });

      return res.status(200).json({
        success: true,
        message: `Order status updated to ${status}`,
        order: order.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }
}
