import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';

class PequireMapView extends StatefulWidget {
  final bool showRadar;
  final Function(LatLng)? onLocationChanged;

  const PequireMapView({
    super.key,
    this.showRadar = false,
    this.onLocationChanged,
  });

  @override
  State<PequireMapView> createState() => _PequireMapViewState();
}

class _PequireMapViewState extends State<PequireMapView> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(28.6273, 77.3725); // Default to Sector 62, Noida
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 15));
        // Convert latlong2 LatLng to any other if needed, but here we just use it
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 15,
          ),
          onMapCreated: (controller) => _mapController = controller,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.blue),
          ),
        // Overlay for extra premium feel
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.white.withValues(alpha: 0.2),
                  ],
                  stops: const [0, 0.2, 0.8, 1],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
