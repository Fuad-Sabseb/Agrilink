import crypto from 'crypto';
import axios from 'axios';
import { Payment } from '../models/Payment.js';
import { Order } from '../models/Order.js';
import { PushNotificationService } from './pushNotificationService.js';
import { config } from '../config/env.js';

export class TelebirrService {
  /**
   * Generate unique outTradeNo for Telebirr
   */
  static generateOutTradeNo(orderId) {
    const timestamp = Date.now();
    const randomSuffix = Math.floor(1000 + Math.random() * 9000);
    return `AGRO_${timestamp}_${randomSuffix}`;
  }

  /**
   * Sign Telebirr payload with SHA256withRSA
   */
  static signPayload(params, privateKey) {
    try {
      if (!privateKey) return '';
      const sortedKeys = Object.keys(params).sort();
      const stringToSign = sortedKeys.map((key) => `${key}=${params[key]}`).join('&');

      const signer = crypto.createSign('SHA256');
      signer.update(stringToSign);
      return signer.sign(privateKey, 'base64');
    } catch (e) {
      console.warn('[Telebirr] Signature generation warning:', e.message);
      return '';
    }
  }

  /**
   * Initiate Telebirr In-App / H5 Web payment
   */
  static async initiatePayment({ orderId, userId, amount, title = 'AgroLink Produce Order' }) {
    const order = await Order.findById(orderId);
    if (!order) {
      throw new Error(`Order with ID ${orderId} not found`);
    }

    const outTradeNo = this.generateOutTradeNo(orderId);
    const totalAmount = (amount || order.totalPrice).toFixed(2);

    // Save payment record in DB
    const payment = await Payment.create({
      orderId,
      userId,
      amount: parseFloat(totalAmount),
      currency: 'ETB',
      method: 'telebirr',
      status: 'initiated',
      outTradeNo,
    });

    if (config.telebirr.isMock) {
      // In development / test mode, generate a simulated checkout URL
      const mockCheckoutUrl = `${config.storageBaseUrl}/api/v1/payments/telebirr/mock-checkout?outTradeNo=${outTradeNo}&amount=${totalAmount}`;
      payment.checkoutUrl = mockCheckoutUrl;
      await payment.save();

      console.log(`[Telebirr] (SIMULATED) Initiated payment: Order ${orderId} | outTradeNo: ${outTradeNo} | Amount: ${totalAmount} ETB`);
      return {
        success: true,
        outTradeNo,
        amount: totalAmount,
        currency: 'ETB',
        checkoutUrl: mockCheckoutUrl,
        isSimulated: true,
      };
    }

    // Production Telebirr API Call
    try {
      const payload = {
        appId: config.telebirr.appId,
        outTradeNo,
        totalAmount,
        subject: title,
        shortCode: config.telebirr.shortCode,
        notifyUrl: config.telebirr.notifyUrl,
        returnUrl: config.telebirr.returnUrl,
        receiveName: 'AgroLink Marketplace',
        timeoutExpress: '30m',
        nonce: crypto.randomBytes(16).toString('hex'),
        timestamp: Date.now().toString(),
      };

      const response = await axios.post(config.telebirr.apiUrl, payload, {
        headers: { 'Content-Type': 'application/json' },
        timeout: 15000,
      });

      if (response.data && response.data.code === 0) {
        payment.telebirrPrepayId = response.data.data.toPayUrl;
        payment.checkoutUrl = response.data.data.toPayUrl;
        await payment.save();

        return {
          success: true,
          outTradeNo,
          checkoutUrl: response.data.data.toPayUrl,
        };
      }

      payment.status = 'failed';
      await payment.save();
      throw new Error(response.data?.msg || 'Telebirr payment initiation rejected');
    } catch (error) {
      console.error('[Telebirr] API error:', error.response?.data || error.message);
      payment.status = 'failed';
      await payment.save();
      throw new Error(`Telebirr error: ${error.message}`);
    }
  }

  /**
   * Handle webhook callback from Telebirr
   */
  static async handleCallback(callbackData) {
    console.log('[Telebirr] Webhook callback received:', callbackData);

    const { outTradeNo, tradeNo, totalAmount, tradeStatus } = callbackData;

    const payment = await Payment.findOne({ outTradeNo });
    if (!payment) {
      throw new Error(`Payment with outTradeNo ${outTradeNo} not found`);
    }

    // Check if status is SUCCESS
    const isSuccess = tradeStatus === 'Completed' || tradeStatus === 'SUCCESS' || tradeStatus === '1';

    if (isSuccess) {
      payment.status = 'completed';
      payment.telebirrTransactionNo = tradeNo || `TEL_${Date.now()}`;
      payment.paidAt = new Date();
      payment.rawCallbackData = callbackData;
      await payment.save();

      // Update Order status
      const order = await Order.findById(payment.orderId);
      if (order) {
        order.paymentStatus = 'paid';
        if (order.status === 'pending') {
          order.status = 'confirmed';
        }
        await order.save();

        // Send Push Notification to Farmer
        await PushNotificationService.sendToUser(order.farmerId, {
          title: 'Payment Received!',
          body: `Payment of ${payment.amount} ETB via Telebirr has been confirmed for order #${order.id.slice(0, 8)}.`,
          type: 'payment',
          data: { orderId: order.id },
        });

        // Send Push Notification to Buyer
        await PushNotificationService.sendToUser(order.buyerId, {
          title: 'Order Payment Confirmed',
          body: `Your payment of ${payment.amount} ETB via Telebirr was successful.`,
          type: 'payment',
          data: { orderId: order.id },
        });
      }

      return { success: true, message: 'Payment completed successfully' };
    } else {
      payment.status = 'failed';
      payment.rawCallbackData = callbackData;
      await payment.save();
      return { success: false, message: 'Payment status was not successful' };
    }
  }
}
