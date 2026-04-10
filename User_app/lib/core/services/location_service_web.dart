import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'location_service.dart';
import '../utils/web_location_interop.dart';

class LocationServiceWeb implements LocationService {
  @override
  Future<Position?> getCurrentLocation() async {
    try {
        return await Future(() async {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) return null;

          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) return null;
          }

          if (permission == LocationPermission.deniedForever) return null;

          return await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
        }).timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint("Error fetching web location: $e");
      return null;
    }
  }

  @override
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    return await WebLocationHelper.getAddressFromLatLng(lat, lng);
  }

  @override
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.isEmpty) return [];
    return await WebLocationHelper.searchPlaces(query);
  }

  @override
  Future<LatLng?> getPlaceDetails(String placeId) async {
    final details = await WebLocationHelper.getPlaceDetails(placeId);
    if (details != null) {
      return LatLng(details['lat']!, details['lng']!);
    }
    return null;
  }
}

LocationService getLocationService() => LocationServiceWeb();
