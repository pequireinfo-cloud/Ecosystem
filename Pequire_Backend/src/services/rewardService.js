const User = require('../models/User');
const Provider = require('../models/Provider');

class RewardService {
  /**
   * Check and award rewards based on streak
   * @param {Object} target - The user or provider document
   * @param {string} type - 'user' or 'provider'
   */
  static async checkAndAward(target, type) {
    const streak = target.currentStreak;
    let rewardPoints = 0;

    // Define reward milestones
    if (streak === 5) {
      rewardPoints = 50;
    } else if (streak === 10) {
      rewardPoints = 150;
    } else if (streak === 20) {
      rewardPoints = 500;
    } else if (streak > 0 && streak % 50 === 0) {
      rewardPoints = 1000; // Major milestone
    }

    if (rewardPoints > 0) {
      target.rewardPoints = (target.rewardPoints || 0) + rewardPoints;
      await target.save();
      console.log(`Awarded ${rewardPoints} points to ${type} ${target._id} for ${streak} streak`);
      return rewardPoints;
    }

    return 0;
  }
}

module.exports = RewardService;
