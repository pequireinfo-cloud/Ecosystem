const User = require('../models/User');

// @desc    Get user profile & Update Streak
// @route   GET /api/users/profile
// @access  Private
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    // Streak Logic
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    
    if (user.lastActiveDate) {
      const lastActive = new Date(user.lastActiveDate);
      const lastActiveDay = new Date(lastActive.getFullYear(), lastActive.getMonth(), lastActive.getDate());
      
      const diffTime = Math.abs(today - lastActiveDay);
      const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

      if (diffDays === 1) {
        // Consecutive day
        user.currentStreak += 1;
        if (user.currentStreak > user.highestStreak) {
          user.highestStreak = user.currentStreak;
        }
        // Reward every 5 days
        if (user.currentStreak % 5 === 0) {
          user.rewardPoints += 100;
        }
      } else if (diffDays > 1) {
        // Streak broken
        user.currentStreak = 1;
      }
      // If diffDays === 0, it's the same day, do nothing
    } else {
      // First time tracking streak
      user.currentStreak = 1;
    }

    user.lastActiveDate = now;
    await user.save();

    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// @desc    Update user profile
// @route   PUT /api/users/profile
// @access  Private
exports.updateUserProfile = async (req, res) => {
  try {
    const { name, nickname, dob, gender, country, address, email } = req.body;

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (name) user.name = name;
    if (nickname) user.nickname = nickname;
    if (dob) user.dob = dob;
    if (gender) user.gender = gender;
    if (country) user.country = country;
    if (address) user.address = { ...user.address, ...address };
    if (email) user.email = email;

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: user
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// @desc    Update user preferences
// @route   PUT /api/users/preferences
// @access  Private
exports.updateUserPreferences = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    user.preferences = { ...user.preferences, ...req.body };
    await user.save();

    res.status(200).json({
      success: true,
      data: user.preferences
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};
