import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/app_config.dart';

class RoutingService {
  // Configured in Google Cloud Console with Directions API.
  static const String apiKey = AppConfig.mapsApiKey;

  /// Fetches polyline points, distance, and traffic-aware ETA from Google Directions API
  static Future<Map<String, dynamic>> getDirections(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&departure_time=now&traffic_model=best_guess&key=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final routes = data['routes'] as List;
          if (routes.isNotEmpty) {
            final leg = routes[0]['legs'][0];
            final steps = leg['steps'] as List;
            final num totalDistNum = leg['distance']['value'] as num;
            final double totalDistance = totalDistNum.toDouble();
            
            // Extract duration in traffic (fallback to normal duration)
            final int durationInSeconds = (leg['duration_in_traffic'] != null) 
                  ? leg['duration_in_traffic']['value'] as int 
                  : leg['duration']['value'] as int;
            
            List<LatLng> coords = [];

            for (var step in steps) {
              final points = PolylinePoints.decodePolyline(step['polyline']['points']);
              coords.addAll(points.map((p) => LatLng(p.latitude, p.longitude)));
            }
            return {'coords': coords, 'totalDistance': totalDistance, 'durationInSeconds': durationInSeconds};
          }
        } else {
          print('Directions API Error: ${data['status']} - ${data['error_message']}');
        }
      } else {
        print('Directions API HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Routing error: $e');
    }
    return {'coords': <LatLng>[], 'totalDistance': 0.0, 'durationInSeconds': 0};
  }

  /// Calculates the Haversine distance in meters between two LatLng coordinates
  static double haversineDistance(LatLng pos1, LatLng pos2) {
    const double R = 6371e3; // Earth radius in meters
    final double phi1 = pos1.latitude * math.pi / 180;
    final double phi2 = pos2.latitude * math.pi / 180;
    final double deltaPhi = (pos2.latitude - pos1.latitude) * math.pi / 180;
    final double deltaLambda = (pos2.longitude - pos1.longitude) * math.pi / 180;

    final double a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
            math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  /// Returns true if the rider's current position deviates from the nearest route point by more than the threshold
  static bool checkDeviationFromRoute(LatLng currentPos, List<LatLng> routeCoords, {double thresholdMeters = 50.0}) {
    if (routeCoords.isEmpty) return false;

    bool isNearPath = routeCoords.any((point) {
      return haversineDistance(currentPos, point) < thresholdMeters;
    });

    return !isNearPath; // Deviated if not near path
  }

  /// Calculates the distance covered continuously from start towards current pos on existing polyline.
  static double calculateDistanceCovered(LatLng currentPos, List<LatLng> routeCoords) {
    if (routeCoords.isEmpty) return 0;
    
    double distance = 0;
    int closestIndex = 0;
    double minDistance = double.maxFinite;

    for (int i = 0; i < routeCoords.length; i++) {
        final d = haversineDistance(currentPos, routeCoords[i]);
        if (d < minDistance) {
            minDistance = d;
            closestIndex = i;
        }
    }

    // Summing distance up to the nearest route point
    for (int i = 0; i < closestIndex; i++) {
        distance += haversineDistance(routeCoords[i], routeCoords[i + 1]);
    }
    
    return distance; // Return covered distance in meters
  }

  /// Trims the polyline by dropping points that have already been passed by the rider
  static List<LatLng> trimPolyline(List<LatLng> polyline, LatLng currentLocation, {double thresholdMeters = 30.0}) {
    if (polyline.isEmpty) return polyline;

    int closestIndex = 0;
    double minDistance = double.maxFinite;

    for (int i = 0; i < polyline.length; i++) {
      final double distance = haversineDistance(currentLocation, polyline[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    // If within threshold of the closest point, trim the path behind the rider
    if (minDistance < thresholdMeters) {
      return polyline.sublist(closestIndex);
    }

    return polyline;
  }
}
