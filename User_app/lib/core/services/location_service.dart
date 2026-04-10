import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_service_stub.dart'
    if (dart.library.io) 'location_service_io.dart'
    if (dart.library.html) 'location_service_web.dart' as impl;

abstract class LocationService {
  factory LocationService() => impl.getLocationService();
  
  Future<Position?> getCurrentLocation();
  Future<String> getAddressFromLatLng(double lat, double lng);
  Future<List<Map<String, dynamic>>> searchPlaces(String query);
  Future<LatLng?> getPlaceDetails(String placeId);
}
