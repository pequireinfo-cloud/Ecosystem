import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'firebase_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final _geo = GeoFlutterFire();
  final _firestore = FirebaseService().firestore;
  final _auth = FirebaseService().auth;

  /// Check and request location permissions
  Future<bool> handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  /// Start streaming location to Firestore
  void startLocationTracking() async {
    final hasPermission = await handlePermission();
    if (!hasPermission) return;

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      _updateLocationInFirestore(position);
    });
  }

  Future<void> _updateLocationInFirestore(Position position) async {
    final user = _auth.currentUser;
    if (user == null) return;

    GeoFirePoint point = _geo.point(latitude: position.latitude, longitude: position.longitude);
    
    await _firestore.collection('providers').doc(user.uid).set({
      'currentLocation': point.data,
      'lastUpdated': FieldValue.serverTimestamp(),
      'isOnline': true,
    }, SetOptions(merge: true));
  }
}
