import { TelebirrService } from '../services/telebirrService.js';
import { Payment } from '../models/Payment.js';
import { Order } from '../models/Order.js';

export class PaymentController {
  /**
   * Initiate Telebirr payment checkout
   */
  static async initiateTelebirr(req, res, next) {
    try {
      const { orderId, amount, title } = req.body;

      if (!orderId) {
        return res.status(400).json({
          success: false,
          error: 'orderId is required',
        });
      }

      const result = await TelebirrService.initiatePayment({
        orderId,
        userId: req.user.id,
        amount: amount ? parseFloat(amount) : undefined,
        title,
      });

      return res.status(200).json({
        success: true,
        message: 'Telebirr payment checkout initiated',
        ...result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Webhook callback handler from Telebirr
   */
  static async telebirrCallback(req, res, next) {
    try {
      const callbackData = req.body;
      const result = await TelebirrService.handleCallback(callbackData);

      // Return HTTP 200 to Telebirr so it stops retrying the webhook
      return res.status(200).json({
        code: 0,
        message: 'SUCCESS',
        ...result,
      });
    } catch (error) {
      console.error('[Telebirr Webhook Error]', error.message);
      return res.status(400).json({
        code: -1,
        message: error.message,
      });
    }
  }

  /**
   * Query status of a payment for an order
   */
  static async queryPaymentStatus(req, res, next) {
    try {
      const { orderId } = req.params;
      const payment = await Payment.findOne({ orderId }).sort({ createdAt: -1 });

      if (!payment) {
        return res.status(404).json({
          success: false,
          error: 'No payment record found for this order',
        });
      }

      const order = await Order.findById(orderId);

      return res.status(200).json({
        success: true,
        payment: payment.toJSON(),
        orderStatus: order?.status,
        paymentStatus: order?.paymentStatus,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Simulated interactive HTML Telebirr checkout page (Development sandbox)
   */
  static async mockCheckout(req, res) {
    const { outTradeNo, amount } = req.query;

    const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Telebirr - Simulated Payment Gateway</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f5f1e8; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; padding: 20px; }
    .card { background: white; border-radius: 16px; padding: 32px; width: 100%; max-width: 420px; box-shadow: 0 10px 25px rgba(0,0,0,0.08); text-align: center; }
    .logo { background: #0077c8; color: white; border-radius: 12px; padding: 12px 24px; display: inline-block; font-weight: bold; font-size: 20px; margin-bottom: 24px; }
    h2 { margin: 0 0 8px; color: #2c241e; }
    .amount { font-size: 32px; font-weight: 800; color: #3a7d44; margin: 16px 0; }
    .details { background: #fbf4dd; border-radius: 8px; padding: 12px; margin: 20px 0; font-size: 14px; color: #8b5a3c; text-align: left; }
    button { width: 100%; background: #0077c8; color: white; border: none; padding: 14px; border-radius: 8px; font-size: 16px; font-weight: bold; cursor: pointer; transition: background 0.2s; margin-top: 10px; }
    button:hover { background: #005fa3; }
    .cancel-btn { background: #e0e0e0; color: #333; }
    .cancel-btn:hover { background: #ccc; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">telebirr</div>
    <h2>Confirm Payment</h2>
    <p style="color: #666; font-size: 14px;">Ethio Telecom Mobile Money</p>
    <div class="amount">${amount || '100.00'} ETB</div>
    <div class="details">
      <div><strong>Merchant:</strong> AgroLink Marketplace</div>
      <div><strong>Trade No:</strong> ${outTradeNo || 'N/A'}</div>
    </div>
    <form action="/api/v1/payments/telebirr/callback" method="POST">
      <input type="hidden" name="outTradeNo" value="${outTradeNo}">
      <input type="hidden" name="tradeNo" value="TEL_${Date.now()}">
      <input type="hidden" name="totalAmount" value="${amount}">
      <input type="hidden" name="tradeStatus" value="Completed">
      <button type="submit">Pay with Telebirr</button>
    </form>
    <button class="cancel-btn" onclick="window.history.back()">Cancel</button>
  </div>
</body>
</html>
    `;

    res.send(html);
  }
}
