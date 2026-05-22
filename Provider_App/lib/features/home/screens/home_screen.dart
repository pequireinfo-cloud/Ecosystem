import 'package:flutter/material.dart';
import 'package:pequire_provider_app/core/constants/app_colors.dart';
import 'package:pequire_provider_app/core/constants/app_typography.dart';
import 'package:pequire_provider_app/shared/widgets/drawer/pequire_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pequire_provider_app/core/providers/kyc_provider.dart';
import 'package:pequire_provider_app/core/providers/location_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pequire_provider_app/core/services/routing_service.dart';
import 'package:pequire_provider_app/core/services/booking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pequire_provider_app/features/home/widgets/active_job_panel.dart';
import 'package:pequire_provider_app/core/services/tracking_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pequire_provider_app/shared/widgets/pequire_logo.dart';
import 'package:pequire_provider_app/core/config/api_config.dart';
import 'package:pequire_provider_app/core/services/provider_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isOnline = false;
  GoogleMapController? _mapController;
  bool _mapInitialized = false;
  double _totalRouteDistance = 0.0;
  LatLng? _activeJobDestination;
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;
  double _distanceCovered = 0.0;
  double _remainingDistance = 0.0;
  double _completedPercentage = 0.0;
  final TextEditingController _locationController = TextEditingController();
  bool _followUser = true;
  StreamSubscription? _bookingSubscription;
  final Set<String> _notifiedBookingIds = {};
  String? _activeBookingId;
  String? _activeServiceType;
  String? _activeAddress;
  final List<LatLng> _hotspots = [
    const LatLng(28.6129, 77.2295), // Connaught Place area
    const LatLng(28.5272, 77.2602), // Okhla area
    const LatLng(28.5623, 77.2144), // South Ext
    const LatLng(28.6448, 77.2167), // Karol Bagh
  ];

  @override
  void initState() {
    super.initState();
    TrackingService().startTracking('initial'); // Or remove if not needed for init
    _startBookingListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkKycStatus();
    });
  }

  Future<void> _checkKycStatus() async {
    final providerId = ApiConfig.currentProviderId;
    if (providerId == null) return;
    
    final profile = await ProviderService().getProfile(providerId);
    if (profile != null && mounted) {
      final status = profile['kycStatus'] ?? 'Pending';
      KycState newState;
      if (status == 'Verified') {
        newState = KycState.verified;
      } else if (status == 'In Review' || status == 'Pending') {
        newState = KycState.pending;
      } else {
        newState = KycState.unverified;
      }
      ref.read(kycProvider.notifier).updateState(newState);
    }
  }

  void _startBookingListener() {
    _bookingSubscription = BookingService().listenForBookings().listen((snapshot) {
      if (!_isOnline) return;
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final bookingId = doc.id;
        
        if (!_notifiedBookingIds.contains(bookingId)) {
          _notifiedBookingIds.add(bookingId);
          
          final serviceType = data['serviceType'] ?? 'General Service';
          final address = data['address'] ?? 'Nearby Location';
          final location = data['location'] as GeoPoint?;
          
          if (location != null && mounted) {
            _showRealIncomingJob(
              bookingId: bookingId,
              serviceType: serviceType,
              address: address,
              lat: location.latitude,
              lon: location.longitude,
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycProvider);
    final isVerified = kycState == KycState.verified;

    // Fix: Move map centering out of the build loop using ref.listen
    ref.listen(locationProvider, (previous, next) {
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
            // Refetch route if deviating
            _fetchRoute(target, _activeJobDestination!);
          } else {
            // Calculate distance metrics & trim visual route
            final double covered = RoutingService.calculateDistanceCovered(target, _routePoints);
            setState(() {
              _distanceCovered = covered;
              _remainingDistance = (_totalRouteDistance - covered).clamp(0.0, double.maxFinite);
              if (_totalRouteDistance > 0) {
                 _completedPercentage = ((covered / _totalRouteDistance) * 100).clamp(0.0, 100.0);
              }
              // Trim polyline visually to "eat" the path
              List<LatLng> originalPoints = _routePoints;
              List<LatLng> trimmed = RoutingService.trimPolyline(originalPoints, target);
              if (trimmed.length != originalPoints.length) {
                _routePoints = trimmed;
              }
            });
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
    });

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      endDrawer: const PequireDrawer(),
      body: Column(
        children: [
            // ─── Top Header ───
            Container(
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                children: [
                  // Brand Group (Logo + Wordmark)
                  const PequireLogo(height: 28, isLight: true),
                  const Spacer(),
                  // Notification bell
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Stack(
                        children: [
                          Center(child: Icon(Icons.notifications_none_rounded, size: 20, color: Theme.of(context).colorScheme.onSurface)),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Logout
                  GestureDetector(
                    onTap: () async {
                      await ApiConfig.logout(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: const Center(child: Icon(Icons.logout_rounded, size: 20, color: Color(0xFFEF4444))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Avatar
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white10 : const Color(0xFFF8FAFC),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        'https://i.pravatar.cc/150?img=11',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, color: Color(0xFFCBD5E1), size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Body (Full-Screen Map) ───
            Expanded(
              child: Stack(
                children: [
                  // 1. The Full-Screen Map
                  Positioned.fill(
                    child: _buildLocationMap(),
                  ),
                  
                  // 2. Online/Offline Toggle Top Overlay
                  if (isVerified)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: _buildOnlineToggle(),
                    ),
                    
                  // 3. KYC Banner Bottom Overlay
                  if (!isVerified)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 30,
                      child: _buildKycBanner(kycState),
                    ),
                  
                  // 4. Minimal Map Navigation Overlay
                  if (_activeBookingId != null && _routePoints.isNotEmpty)
                    Positioned(
                      left: 20,
                      right: 20,
                      top: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${(_distanceCovered / 1000).toStringAsFixed(1)} km', style: AppTypography.h3.copyWith(fontSize: 16, color: AppColors.primary)),
                                Text('Covered', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                              ],
                            ),
                            Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${_completedPercentage.toStringAsFixed(0)}%', style: AppTypography.h3.copyWith(fontSize: 16, color: const Color(0xFFF59E0B))),
                                Text('Completed', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                              ],
                            ),
                            Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${(_remainingDistance / 1000).toStringAsFixed(1)} km', style: AppTypography.h3.copyWith(fontSize: 16, color: const Color(0xFF0F172A))),
                                Text('Remaining', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // 5. Active Job Panel Overlay
                  if (_activeBookingId != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: ActiveJobPanel(
                        bookingId: _activeBookingId!,
                        serviceType: _activeServiceType ?? 'Service',
                        address: _activeAddress ?? 'Nearby',
                        onComplete: () {
                          setState(() {
                            _activeBookingId = null;
                            _activeJobDestination = null;
                            _routePoints.clear();
                            _distanceCovered = 0.0;
                            _remainingDistance = 0.0;
                            _completedPercentage = 0.0;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Job Completed Successfully!')),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showRealIncomingJob({
    required String bookingId,
    required String serviceType,
    required String address,
    required double lat,
    required double lon,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
              child: const Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 20),
            ),
            const SizedBox(width: 12),
            const Text('New Job Request'),
          ],
        ),
        titleTextStyle: AppTypography.h3.copyWith(color: const Color(0xFF0F172A), fontSize: 18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(serviceType, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, color: Color(0xFF94A3B8), size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(address, style: AppTypography.label.copyWith(color: const Color(0xFF0F172A), fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final providerId = ApiConfig.currentProviderId ?? 'unknown_provider';
                await BookingService().acceptBooking(bookingId, providerId);
                if (mounted) {
                    setState(() {
                      _activeBookingId = bookingId;
                      _activeServiceType = serviceType;
                      _activeAddress = address;
                      _activeJobDestination = LatLng(lat, lon);
                    });
                  // Start Firestore tracking
                  TrackingService().startTracking(bookingId);

                  final providerLocation = ref.read(locationProvider).value;
                  if (providerLocation != null) {
                    _fetchRoute(LatLng(providerLocation.latitude, providerLocation.longitude), LatLng(lat, lon));
                  }
                }
              } catch (e) {
                _showError('Failed to accept job: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Accept Job'),
          ),
        ],
      ),
    );
  }



  Future<void> _fetchRoute(LatLng start, LatLng end) async {
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
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Widget _buildLocationMap() {
    final locationAsync = ref.watch(locationProvider);

    return SizedBox.expand(
      child: Stack(
        children: [
          locationAsync.when(
            data: (position) {
              final target = LatLng(position.latitude, position.longitude);
              
              if (!_mapInitialized) {
                _mapInitialized = true;
              }

              return GoogleMap(
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
                    circleId: CircleId('hotspot_outer_\${latLng.latitude}_\${latLng.longitude}'),
                    center: latLng,
                    radius: 800,
                    fillColor: Colors.orange.withOpacity(0.15),
                    strokeColor: Colors.orange.withOpacity(0.3),
                    strokeWidth: 2,
                  )),
                  ..._hotspots.map((latLng) => Circle(
                    circleId: CircleId('hotspot_inner_\${latLng.latitude}_\${latLng.longitude}'),
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
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Location error: $err', style: AppTypography.bodySmall, textAlign: TextAlign.center),
              ),
            ),
          ),
          // Live Tracking Pill
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text('Live Tracking', style: AppTypography.label.copyWith(fontSize: 12, color: const Color(0xFF0F172A))),
                ],
              ),
            ),
          ),
          // Recenter Button
          if (!_followUser)
            Positioned(
              bottom: 24,
              left: 20,
              child: FloatingActionButton.small(
                heroTag: 'recenter_map',
                onPressed: () {
                  setState(() => _followUser = true);
                  final pos = ref.read(locationProvider).value;
                  if (pos != null) {
                    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 15.0));
                  }
                },
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                child: const Icon(Icons.my_location_rounded),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnlineToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: _isOnline
            ? const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)])
            : const LinearGradient(colors: [Color(0xFF475569), Color(0xFF64748B)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_isOnline ? const Color(0xFF059669) : const Color(0xFF475569)).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small Status Icon
          Icon(
            _isOnline ? Icons.wifi_tethering_rounded : Icons.wifi_tethering_off_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            _isOnline ? 'Online' : 'Offline',
            style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 12),
          // Small Toggle Switch
          GestureDetector(
            onTap: () => setState(() => _isOnline = !_isOnline),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: _isOnline ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycBanner(KycState state) {
    final isPending = state == KycState.pending;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPending ? const Color(0xFFFDE68A) : const Color(0xFFFECACA)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isPending ? Icons.hourglass_top_rounded : Icons.shield_outlined,
              color: isPending ? const Color(0xFFD97706) : const Color(0xFFDC2626),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isPending ? 'Verification Pending' : 'Complete KYC',
            style: AppTypography.h3.copyWith(color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          Text(
            isPending
                ? 'Your documents are being reviewed. This usually takes 24 hours.'
                : 'Verify your identity to start receiving job requests and earning.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: const Color(0xFF64748B), fontSize: 13, height: 1.5),
          ),
          if (!isPending) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/kyc'),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF025EF3), Color(0xFF3B82F6)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user_outlined, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('Start KYC Verification', style: AppTypography.label.copyWith(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEarningsStrip() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Earnings', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text('₹1,280', style: AppTypography.h1.copyWith(color: const Color(0xFF0F172A), fontSize: 28)),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 44, color: const Color(0xFFF1F5F9)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This Week', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text('₹5,480', style: AppTypography.h2.copyWith(color: AppColors.primary, fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                      child: Text('+12%', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/earnings'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF025EF3), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        _quickAction(Icons.history_rounded, 'Bookings', const Color(0xFF6366F1), () => context.push('/history')),
        const SizedBox(width: 10),
        _quickAction(Icons.star_outline_rounded, 'Reviews', const Color(0xFFD97706), () => context.push('/reviews')),
        const SizedBox(width: 10),
        _quickAction(Icons.account_balance_wallet_outlined, 'Earnings', const Color(0xFF059669), () => context.push('/earnings')),
        const SizedBox(width: 10),
        _quickAction(Icons.help_outline_rounded, 'Help', const Color(0xFFDC2626), () => context.push('/help')),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: AppTypography.bodySmall.copyWith(color: const Color(0xFF475569), fontWeight: FontWeight.w600, fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(String service, String customer, String time, String price, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service, style: AppTypography.label.copyWith(color: const Color(0xFF0F172A), fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('$customer • $time', style: AppTypography.bodySmall.copyWith(color: const Color(0xFF94A3B8), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(price, style: AppTypography.h3.copyWith(color: const Color(0xFF059669), fontSize: 17)),
        ],
      ),
    );
  }
}

class _LocationSearchField extends StatefulWidget {
  final Function(double lat, double lon, String displayName) onSelected;
  const _LocationSearchField({required this.onSelected});

  @override
  State<_LocationSearchField> createState() => _LocationSearchFieldState();
}

class _LocationSearchFieldState extends State<_LocationSearchField> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  void _search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
      return;
    }
    
    setState(() => _isLoading = true);
    
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5');
        final response = await http.get(url, headers: {'User-Agent': 'PequireProviderApp/1.0'});
        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _suggestions = jsonDecode(response.body) as List;
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: _search,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for a location...',
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
            suffixIcon: _isLoading 
                ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))) 
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        if (_suggestions.isNotEmpty)
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder: (ctx, i) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                itemBuilder: (ctx, i) {
                  final item = _suggestions[i];
                  final name = item['display_name'].toString();
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: Color(0xFF475569)),
                    title: Text(name, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () {
                      final lat = double.parse(item['lat'].toString());
                      final lon = double.parse(item['lon'].toString());
                      widget.onSelected(lat, lon, name.split(',')[0]);
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}


