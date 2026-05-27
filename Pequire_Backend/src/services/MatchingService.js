const Provider = require('../models/Provider');

/**
 * Startup Day 1 Dispatch Engine (Simplified TC4).
 * Fast Database Geofence -> Quality Guard -> Google Maps Live ETA -> Batch Dispatch.
 */
class MatchingService {
  constructor() {
    this.MAX_RADIUS = 500000; // 500km in meters
    this.STEP_RADII = [50000, 100000, 500000]; // 50km, 100km, 500km
    
    // Skill keywords for extraction from problem description
    this.SKILL_KEYWORDS = {
      'Carpentry': ['door', 'cabinet', 'bed', 'furniture', 'kitchen', 'window', 'sofa', 'lock', 'polish'],
      'Plumbing': ['leak', 'geyser', 'tap', 'toilet', 'blockage', 'tank', 'shower', 'sink', 'pipe'],
      'Electrical': ['ac', 'fan', 'wiring', 'inverter', 'refrigerator', 'washing', 'switchboard', 'light', 'meter'],
      'Laundry': ['dry clean', 'stain', 'bridal', 'woolen', 'iron', 'curtain', 'carpet', 'wash']
    };
  }

  /**
   * Main entry point to find the best providers for a booking.
   */
  async findBestProviders(booking) {
    let providers = [];
    let searchRadius = 0;
    let fallbackCount = 0;

    // Step 0: Identify specific skills from problem description
    const requestedSkills = this._extractSkills(booking.problemDescription, booking.serviceType);
    console.log(`Matching: Identified skills: [${requestedSkills.join(', ')}]`);

    // Phase 1: Search for Specialists (Providers with matching expertise)
    if (requestedSkills.length > 0) {
      console.log('Matching Phase: Searching for Specialists...');
      for (const radius of this.STEP_RADII) {
        searchRadius = radius;
        providers = await this._getEligibleProviders(booking, radius, requestedSkills);
        if (providers.length > 0) break;
        fallbackCount++;
      }
    }

    // Phase 2: Search for Generalists (Fallback to anyone in category)
    if (providers.length === 0) {
      console.log(`Matching Phase: No specialists found. Falling back to Generalists in ${booking.serviceType}...`);
      for (const radius of this.STEP_RADII) {
        searchRadius = radius;
        providers = await this._getEligibleProviders(booking, radius, []);
        if (providers.length > 0) break;
        fallbackCount++;
      }
    }

    if (providers.length === 0) {
      console.log('Matching: No matching providers found within 20km even in fallback.');
      return { providers: [], searchRadius, fallbackCount };
    }

    // Step 2: Google Maps ETA Calculation
    const rankedProviders = await this._rankProvidersWithGoogleMaps(providers, booking.location);

    return {
      providers: rankedProviders,
      searchRadius,
      fallbackCount
    };
  }

  /**
   * Hard Filters (Category + Radius + Quality Guard >= 3.5)
   */
  async _getEligibleProviders(booking, radius, requiredSkills) {
    const query = {
      serviceType: booking.serviceType,
      status: 'Online',
      kycStatus: 'Verified',
      rating: { $gte: 3.5 }, // Quality Guard: Only 3.5+ stars allowed
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

    // Strict expertise filter if skills are identified
    if (requiredSkills && requiredSkills.length > 0) {
      query.expertise = { $in: requiredSkills };
    }
    
    return await Provider.find(query);
  }

  /**
   * Identifies relevant skills from a textual description.
   */
  _extractSkills(description, category) {
    if (!description || !this.SKILL_KEYWORDS[category]) return [];
    const descLower = description.toLowerCase();
    return this.SKILL_KEYWORDS[category].filter(skill => descLower.includes(skill));
  }

  /**
   * Google Maps Distance Matrix Ranking
   */
  async _rankProvidersWithGoogleMaps(providers, userLocation) {
    const apiKey = process.env.GOOGLE_MAPS_API_KEY;
    if (!apiKey) {
      console.warn("No GOOGLE_MAPS_API_KEY found, falling back to raw straight-line math.");
      return this._fallbackMathematicalRank(providers, userLocation);
    }

    // Format origins: lat,lng|lat,lng|lat,lng
    const origins = providers.map(p => `${p.location.latitude},${p.location.longitude}`).join('|');
    const destination = `${userLocation.latitude},${userLocation.longitude}`;

    try {
      const url = `https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origins}&destinations=${destination}&departure_time=now&traffic_model=best_guess&key=${apiKey}`;
      const response = await fetch(url);
      const data = await response.json();

      if (data.status !== 'OK') {
        console.warn(`Google Maps API returned ${data.status}, falling back to math.`);
        return this._fallbackMathematicalRank(providers, userLocation);
      }

      // Map ETAs to providers
      const ranked = providers.map((p, index) => {
        const element = data.rows[index].elements[0];
        let durationSeconds = 999999; // Default huge time if route failed
        let distanceMeters = 0;

        if (element.status === 'OK') {
          // Use traffic duration if available, else normal duration
          durationSeconds = element.duration_in_traffic ? element.duration_in_traffic.value : element.duration.value;
          distanceMeters = element.distance.value;
        }

        const providerObj = p.toObject();
        providerObj.etaSeconds = durationSeconds;
        providerObj.currentDistanceKm = distanceMeters / 1000;
        providerObj.matchingScore = durationSeconds; // Lowest score is best now
        return providerObj;
      });

      // Sort ascending (Lowest ETA = Rank 1)
      return ranked.sort((a, b) => a.etaSeconds - b.etaSeconds).slice(0, 10);

    } catch (e) {
      console.error("Error calling Google Maps API:", e);
      return this._fallbackMathematicalRank(providers, userLocation);
    }
  }

  /**
   * Fallback if Maps API fails
   */
  _fallbackMathematicalRank(providers, userLocation) {
    return providers.map(p => {
      const distKm = this._calculateDistance(userLocation.latitude, userLocation.longitude, p.location.latitude, p.location.longitude);
      const providerObj = p.toObject();
      providerObj.etaSeconds = Math.floor(distKm * 120); // Rough estimate: 2 mins per km
      providerObj.currentDistanceKm = distKm;
      providerObj.matchingScore = providerObj.etaSeconds; 
      return providerObj;
    })
    .sort((a, b) => a.etaSeconds - b.etaSeconds)
    .slice(0, 10);
  }

  _calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
      Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
      Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  }
}

module.exports = new MatchingService();
