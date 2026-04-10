import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/core/services/location_service.dart';
import 'package:pequire_user_app/injection_container.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationResult {
  final LatLng position;
  final String address;

  LocationResult(this.position, this.address);
}

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final TextEditingController _locationSearchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _locationSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Change Location', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _locationSearchController,
              onChanged: (value) async {
                if (value.length > 2) {
                  setState(() => _isSearching = true);
                  final results = await sl<LocationService>().searchPlaces(value);
                  if (mounted) {
                    setState(() {
                      _searchResults = results;
                      _isSearching = false;
                    });
                  }
                } else {
                  if (mounted) setState(() => _searchResults = []);
                }
              },
              decoration: InputDecoration(
                hintText: 'Search for building, area or street...',
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: _isSearching ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            if (_searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
                      title: Text(item['description']),
                      onTap: () async {
                        final latLng = await sl<LocationService>().getPlaceDetails(item['place_id']);
                        if (latLng != null && mounted) {
                          Navigator.pop(context, LocationResult(latLng, item['description']));
                        }
                      },
                    );
                  },
                ),
              )
            else ...[
              ListTile(
                onTap: () {
                  Navigator.pop(context, 'CURRENT_LOCATION');
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
                ),
                title: const Text('Use Current Location', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Detect your precise current location'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ),
              const SizedBox(height: 8),
              ListTile(
                onTap: () {
                  Navigator.pop(context, 'SELECT_ON_MAP');
                },
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.map_rounded, color: AppColors.accent, size: 20),
                ),
                title: const Text('Select Location on Map', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Pinpoint your exact location manually'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ),
              const Divider(height: 32),
              const Text('SAVED ADDRESSES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              _buildLocationItem('Home', '123, Luxury Villas, Beverly Hills', Icons.home_rounded, const LatLng(34.0736, -118.4004)),
              _buildLocationItem('Work', 'Block C, Tech Park, Silicon Valley', Icons.work_rounded, const LatLng(37.3875, -122.0575)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(String label, String address, IconData icon, LatLng stubLocation) {
    return ListTile(
      onTap: () {
        Navigator.pop(context, LocationResult(stubLocation, address));
      },
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(address, style: const TextStyle(fontSize: 12)),
    );
  }
}
