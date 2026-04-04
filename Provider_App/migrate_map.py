import os

filepath = r"c:\Users\ddaya\OneDrive\Desktop\Pequire\Provider_App\lib\features\home\screens\home_screen.dart"

with open(filepath, "r", encoding="utf-8") as f:
    content = f.read()

# Chunk 1: Imports
content = content.replace(
"""import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:pequire_provider_app/core/services/booking_service.dart';""",
"""import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pequire_provider_app/core/services/routing_service.dart';
import 'package:pequire_provider_app/core/services/booking_service.dart';"""
)

# Chunk 2: Map Controller
content = content.replace(
"""  final MapController _mapController = MapController();
  bool _mapInitialized = false;""",
"""  GoogleMapController? _mapController;
  bool _mapInitialized = false;
  double _totalRouteDistance = 0.0;"""
)

# Chunk 3: ref.listen locationProvider
content = content.replace(
"""    ref.listen(locationProvider, (previous, next) {
      next.whenData((position) {
        if (_followUser) {
          final target = LatLng(position.latitude, position.longitude);
          if (_mapInitialized) {
            _mapController.move(target, _mapController.camera.zoom);
          }
        }
        
        // Emit location update if there is an active job
        if (_activeBookingId != null) {
          TrackingService().updateLocation(
            orderId: _activeBookingId!,
            latitude: position.latitude,
            longitude: position.longitude,
            heading: position.heading,
          );
        }
      });
    });""",
"""    ref.listen(locationProvider, (previous, next) {
      next.whenData((position) {
        final target = LatLng(position.latitude, position.longitude);
        if (_followUser && _mapInitialized) {
          _mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: target, zoom: 15.0, bearing: position.heading),
          ));
        }

        // Deviation logic trigger
        if (_routePoints.isNotEmpty && _activeJobDestination != null) {
          bool isDeviated = RoutingService.checkDeviationFromRoute(target, _routePoints);
          if (isDeviated) {
            // Refetch route
            _fetchRoute(target, _activeJobDestination!);
          }
        }
        
        // Emit location update if there is an active job
        if (_activeBookingId != null) {
          TrackingService().updateLocation(
            orderId: _activeBookingId!,
            latitude: position.latitude,
            longitude: position.longitude,
            heading: position.heading,
          );
        }
      });
    });"""
)

# Chunk 4: Route Fetching
content = content.replace(
"""  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry']['coordinates'] as List;
          setState(() {
            _routePoints = geometry.map((coord) => LatLng(coord[1] as double, coord[0] as double)).toList();
          });
          
          final bounds = LatLngBounds.fromPoints([start, end, ..._routePoints]);
          _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
        } else {
          _showError('No travel route found for this location.');
        }
      } else {
        _showError('Mapping service unavailable (Error ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Routing error: $e');
      _showError('Could not calculate route: $e');
    }
  }""",
"""  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    try {
      setState(() => _isLoadingRoute = true);
      final result = await RoutingService.getDirections(start, end);
      final coords = result['coords'] as List<LatLng>;
      
      if (coords.isNotEmpty) {
        setState(() {
          _routePoints = coords;
          _totalRouteDistance = result['totalDistance'] as double;
          _isLoadingRoute = false;
        });
        
        // Fit bounds for Google Maps
        double minLat = [start.latitude, end.latitude, ...coords.map((c) => c.latitude)].reduce((a, b) => a < b ? a : b);
        double maxLat = [start.latitude, end.latitude, ...coords.map((c) => c.latitude)].reduce((a, b) => a > b ? a : b);
        double minLng = [start.longitude, end.longitude, ...coords.map((c) => c.longitude)].reduce((a, b) => a < b ? a : b);
        double maxLng = [start.longitude, end.longitude, ...coords.map((c) => c.longitude)].reduce((a, b) => a > b ? a : b);
        
        final bounds = LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      } else {
        setState(() => _isLoadingRoute = false);
        _showError('No travel route found for this location.');
      }
    } catch (e) {
      setState(() => _isLoadingRoute = false);
      debugPrint('Routing error: $e');
      _showError('Could not calculate route: $e');
    }
  }"""
)

# Chunk 5: Map Render
content = content.replace(
"""              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: target,
                  initialZoom: 15.0,
                  onPointerDown: (_, __) {
                    // Disable following when user manually interacts with map
                    if (_followUser) setState(() => _followUser = false);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.pequire.provider',
                  ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: AppColors.primary,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  CircleLayer(
                    circles: _hotspots.map((latLng) => CircleMarker(
                      point: latLng,
                      radius: 800,
                      useRadiusInMeter: true,
                      color: Colors.orange.withOpacity(0.15),
                      borderColor: Colors.orange.withOpacity(0.3),
                      borderStrokeWidth: 2,
                    )).toList(),
                  ),
                  CircleLayer(
                    circles: _hotspots.map((latLng) => CircleMarker(
                      point: latLng,
                      radius: 300,
                      useRadiusInMeter: true,
                      color: Colors.deepOrange.withOpacity(0.2),
                    )).toList(),
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: target,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 5)],
                          ),
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Color(0xFF025EF3),
                            size: 24,
                          ),
                        ),
                      ),
                      if (_activeJobDestination != null)
                        Marker(
                          point: _activeJobDestination!,
                          width: 40,
                          height: 40,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFDC2626),
                            size: 40,
                          ),
                        ),
                    ],
                  ),
                ],
              );""",
"""              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: target,
                  zoom: 15.0,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                polylines: _routePoints.isNotEmpty 
                  ? {
                      Polyline(
                        polylineId: const PolylineId('route'),
                        points: _routePoints,
                        color: AppColors.primary,
                        width: 4,
                      )
                    }
                  : {},
                circles: {
                  ..._hotspots.map((latLng) => Circle(
                    circleId: CircleId('hotspot_outer_\\${latLng.latitude}_\\${latLng.longitude}'),
                    center: latLng,
                    radius: 800,
                    fillColor: Colors.orange.withOpacity(0.15),
                    strokeColor: Colors.orange.withOpacity(0.3),
                    strokeWidth: 2,
                  )),
                  ..._hotspots.map((latLng) => Circle(
                    circleId: CircleId('hotspot_inner_\\${latLng.latitude}_\\${latLng.longitude}'),
                    center: latLng,
                    radius: 300,
                    fillColor: Colors.deepOrange.withOpacity(0.2),
                    strokeWidth: 0,
                  )),
                },
                markers: {
                  if (_activeJobDestination != null)
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: _activeJobDestination!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                },
                onCameraMoveStarted: () {
                  if (_followUser) setState(() => _followUser = false);
                },
              );"""
)

# Chunk 6: Recenter button controller fix
content = content.replace(
"""                    _mapController.move(LatLng(pos.latitude, pos.longitude), 15.0);""",
"""                    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15.0));"""
)

with open(filepath, "w", encoding="utf-8") as f:
    f.write(content)

print("Done replacing.")
