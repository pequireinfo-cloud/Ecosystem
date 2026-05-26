const Notification = require('../models/Notification');
const User = require('../models/User');
const Provider = require('../models/Provider');

// @desc    Get user/provider notifications
// @route   GET /api/notifications
// @access  Private
exports.getNotifications = async (req, res) => {
  try {
    const isProvider = req.user.role === 'provider';
    const query = isProvider ? { providerId: req.user.id } : { userId: req.user.id };

    const notifications = await Notification.find(query).sort({ createdAt: -1 }).limit(50);

    res.status(200).json({
      success: true,
      data: notifications
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// @desc    Mark notification as read
// @route   PUT /api/notifications/:id/read
// @access  Private
exports.markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    // Verify ownership
    const isProvider = req.user.role === 'provider';
    if (isProvider && notification.providerId?.toString() !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    } else if (!isProvider && notification.userId?.toString() !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    notification.isRead = true;
    await notification.save();

    res.status(200).json({ success: true, data: notification });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// @desc    Update FCM Token for User
// @route   PUT /api/users/update-fcm
// @access  Private
exports.updateUserFcmToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;
    if (!fcmToken) return res.status(400).json({ success: false, message: 'fcmToken is required' });

    await User.findByIdAndUpdate(req.user.id, { fcmToken });
    res.status(200).json({ success: true, message: 'FCM Token updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// @desc    Update FCM Token for Provider
// @route   PUT /api/providers/update-fcm
// @access  Private
exports.updateProviderFcmToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;
    if (!fcmToken) return res.status(400).json({ success: false, message: 'fcmToken is required' });

    await Provider.findByIdAndUpdate(req.user.id, { fcmToken });
    res.status(200).json({ success: true, message: 'FCM Token updated successfully' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
