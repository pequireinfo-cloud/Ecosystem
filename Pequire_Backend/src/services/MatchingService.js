const Provider = require('../models/Provider');

/**
 * Hybrid Smart Matching Engine for Pequire.
 * Implements hard filters, weighted scoring, and fallback logic.
 */
class MatchingService {
  constructor() {
    this.WEIGHTS = {
      RESPONSE: 0.35,
      RATING: 0.25,
      DISTANCE: 0.20,
      RELIABILITY: 0.10,
      CANCELLATION: 0.10
    };
    this.MAX_RADIUS = 20000; // 20km in meters
    this.STEP_RADII = [5000, 10000, 20000]; // 5km, 10km, 20km
  }

  /**
   * Main entry point to find the best providers for a booking.
   */
  async findBestProviders(booking) {
    let providers = [];
    let searchRadius = 0;
    let fallbackCount = 0;

    for (const radius of this.STEP_RADII) {
      searchRadius = radius;
      console.log(`Matching: Searching in radius ${radius / 1000}km...`);
      
      providers = await this._getEligibleProviders(booking, radius);
      
      if (providers.length > 0) {
        console.log(`Matching: Found ${providers.length} eligible providers at ${radius / 1000}km.`);
        break;
      }
      fallbackCount++;
    }

    if (providers.length === 0) {
      console.log('Matching: No matching providers found within 20km.');
      return { providers: [], searchRadius, fallbackCount };
    }

    // Step 2: Intelligent Ranking
    const rankedProviders = this._rankProviders(providers, booking.location);

    return {
      providers: rankedProviders,
      searchRadius,
      fallbackCount
    };
  }

  /**
   * Hard Filters (Step 1)
   */
  async _getEligibleProviders(booking, radius) {
    const query = {
      serviceType: booking.serviceType,
      status: 'Online',
      kycStatus: 'Verified',
      'location.geo': {
        $near: {
          $geometry: {
            type: "Point",
            coordinates: [booking.location.longitude, booking.location.latitude]
          },
          $maxDistance: radius
        }
      }
    };

    // If a specific task was mentioned, try to match expertise
    // Note: In fallback mode, we might loosen this, but Step 1 keeps it strict per requirement
    // Search category safety is strict as per rules
    
    return await Provider.find(query);
  }

  /**
   * Ranking Algorithm (Step 2)
   */
  _rankProviders(providers, userLocation) {
    return providers.map(p => {
      // 1. Response Score (Normalized 0-1)
      // avgResponseSeconds: 30s (best) to 3600s (worst)
      const resScore = Math.max(0, 1 - (p.avgResponseSeconds / 3600));

      // 2. Rating Score (Normalized 3.5-5.0 to 0-1)
      const ratScore = Math.max(0, (p.rating - 3.5) / 1.5);

      // 3. Distance Score
      // Based on distance to Naveen Market or User Location? 
      // Algorithm says "best nearby", so we should use distance from USER for ranking.
      const dist = this._calculateDistance(
        userLocation.latitude, userLocation.longitude,
        p.location.latitude, p.location.longitude
      );
      const distScore = Math.max(0, 1 - (dist / 20)); // Normalize to 20km

      // 4. Completion Reliability
      // Mix of totalJobsCompleted and acceptanceRate
      const jobsNorm = Math.min(1, p.totalJobsCompleted / 500);
      const accScore = p.acceptanceRate / 100;
      const relScore = (jobsNorm * 0.4) + (accScore * 0.6);

      // 5. Low Cancellation Score
      const canScore = Math.max(0, 1 - (p.cancellationRate / 100));

      // Final Categorical Weighting
      const totalScore = (resScore * this.WEIGHTS.RESPONSE) +
                         (ratScore * this.WEIGHTS.RATING) +
                         (distScore * this.WEIGHTS.DISTANCE) +
                         (relScore * this.WEIGHTS.RELIABILITY) +
                         (canScore * this.WEIGHTS.CANCELLATION);

      // Attach score for metadata
      const providerObj = p.toObject();
      providerObj.matchingScore = totalScore;
      providerObj.currentDistanceKm = dist;
      
      return providerObj;
    })
    .sort((a, b) => b.matchingScore - a.matchingScore)
    .slice(0, 10); // Return top 10 ranked for potential fallback use
  }

  _calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = 
      Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
      Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  }
}

module.exports = new MatchingService();
