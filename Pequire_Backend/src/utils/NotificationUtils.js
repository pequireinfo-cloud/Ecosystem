const { messaging } = require('../config/firebase');
const Notification = require('../models/Notification');
const User = require('../models/User');
const Provider = require('../models/Provider');

/**
 * Sends a push notification via Firebase and saves it to the database.
 * @param {Object} params - The notification parameters.
 * @param {String} [params.userId] - The ID of the user (if targeting a user).
 * @param {String} [params.providerId] - The ID of the provider (if targeting a provider).
 * @param {String} params.title - The title of the notification.
 * @param {String} params.body - The body text of the notification.
 * @param {String} [params.type] - The type of notification (e.g., 'booking_created').
 * @param {Object} [params.data] - Additional custom data payload.
 */
exports.sendPushNotification = async ({ userId, providerId, title, body, type = 'system', data = {} }) => {
  try {
    if (!messaging) {
      console.warn('Firebase Messaging not initialized. Skipping push notification.');
      return;
    }

    // 1. Save notification to database for history tracking
    const notification = await Notification.create({
      userId: userId || null,
      providerId: providerId || null,
      title,
      body,
      type,
      data
    });

    // 2. Fetch the FCM token of the target recipient
    let fcmToken = null;
    
    if (userId) {
      const user = await User.findById(userId);
      if (user && user.fcmToken && user.preferences?.pushNotifications !== false) {
        fcmToken = user.fcmToken;
      }
    } else if (providerId) {
      const provider = await Provider.findById(providerId);
      if (provider && provider.fcmToken) {
        fcmToken = provider.fcmToken;
      }
    }

    // 3. If a valid FCM token exists, send the push notification via Firebase
    if (fcmToken) {
      const message = {
        token: fcmToken,
        notification: {
          title,
          body
        },
        data: {
          ...data,
          type,
          notificationId: notification._id.toString()
        },
        android: {
          notification: {
            sound: 'default' // We will handle custom sounds on the Flutter side via channels
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default'
            }
          }
        }
      };

      const response = await messaging.send(message);
      console.log(`Successfully sent message: ${response}`);
    } else {
      console.log(`No FCM token found or push disabled for User:${userId} Provider:${providerId}. Notification saved to DB only.`);
    }

    return notification;
  } catch (error) {
    console.error('Error sending push notification:', error);
  }
};
