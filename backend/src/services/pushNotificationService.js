import { getFirebaseMessaging } from '../config/firebase.js';
import { Notification } from '../models/Notification.js';
import { User } from '../models/User.js';

export class PushNotificationService {
  /**
   * Send a notification to a specific user
   */
  static async sendToUser(userId, { title, body, type = 'system', data = {} }) {
    try {
      // 1. Save in-app notification in MongoDB
      const notificationDoc = await Notification.create({
        userId,
        title,
        body,
        type,
        data,
      });

      // 2. Lookup recipient's FCM token
      const user = await User.findById(userId);
      if (!user || !user.fcmToken) {
        console.log(`[Push Notification] Stored in-app for user ${userId} (no FCM token registered)`);
        return notificationDoc;
      }

      // 3. Dispatch to Firebase Cloud Messaging if available
      const messaging = getFirebaseMessaging();
      if (messaging) {
        const messagePayload = {
          token: user.fcmToken,
          notification: {
            title,
            body,
          },
          data: {
            notificationId: notificationDoc.id,
            type,
            ...Object.keys(data).reduce((acc, key) => {
              acc[key] = String(data[key]);
              return acc;
            }, {}),
          },
        };

        const fcmResponse = await messaging.send(messagePayload);
        console.log(`[Push Notification] Sent FCM to user ${userId}: ${fcmResponse}`);
      } else {
        console.log(`[Push Notification] (SIMULATED) FCM message queued for user ${userId} | ${title}: ${body}`);
      }

      return notificationDoc;
    } catch (error) {
      console.error(`[Push Notification] Error sending to user ${userId}:`, error.message);
      // Non-blocking: Do not crash the caller if notification delivery fails
      return null;
    }
  }

  /**
   * Broadcast notification to all users of a specific role
   */
  static async sendToRole(role, { title, body, type = 'system', data = {} }) {
    const users = await User.find({ role }).select('_id');
    const promises = users.map((u) =>
      this.sendToUser(u._id, { title, body, type, data })
    );
    return await Promise.allSettled(promises);
  }
}
