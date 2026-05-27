import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/core/services/location_service.dart';
import 'package:pequire_user_app/injection_container.dart';
import 'location_picker_page.dart';

class MapLocationPickerPage extends StatefulWidget {
  const MapLocationPickerPage({super.key});

  @override
  State<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage> {
  GoogleMapController? _mapController;
  LatLng _pickedLocation = const LatLng(28.6139, 77.2090);
  String _address = 'Fetching address...';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _pickedLocation = LatLng(pos.latitude, pos.longitude);
          _loading = false;
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(_pickedLocation));
        _updateAddress(_pickedLocation);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateAddress(LatLng position) async {
    final address = await sl<LocationService>().getAddressFromLatLng(position.latitude, position.longitude);
    if (mounted) {
      setState(() {
        _address = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _pickedLocation, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onCameraMove: (position) {
              setState(() {
                _pickedLocation = position.target;
              });
            },
            onCameraIdle: () {
              _updateAddress(_pickedLocation);
            },
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on, color: AppColors.primary, size: 45),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _address,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, LocationResult(_pickedLocation, _address));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Confirm Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
