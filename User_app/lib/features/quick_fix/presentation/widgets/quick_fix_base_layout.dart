import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class QuickFixBaseLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final VoidCallback? onBack;
  final double initialSheetSize;
  final double minSheetSize;
  final double maxSheetSize;
  final Widget? background;
  final Color? sheetColor;

  const QuickFixBaseLayout({
    super.key,
    required this.child,
    this.title = 'Quick Fix',
    this.onBack,
    this.initialSheetSize = 0.5,
    this.minSheetSize = 0.3,
    this.maxSheetSize = 0.95,
    this.background,
    this.sheetColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Layer (Real Map or Dummy Map)
          Positioned.fill(
            child: background ?? const _DefaultMapBackground(),
          ),

          // Custom App Bar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 15,
                left: 10,
                right: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: onBack ?? () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: initialSheetSize,
            minChildSize: minSheetSize,
            maxChildSize: maxSheetSize,
            snap: true,
            snapSizes: const [0.35, 0.8, 0.95],
            builder: (context, scrollController) {
              final isDark = (sheetColor ?? Colors.white).computeLuminance() < 0.5;
              return Container(
                decoration: BoxDecoration(
                  color: sheetColor ?? Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle Bar
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: child,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DefaultMapBackground extends StatefulWidget {
  const _DefaultMapBackground();

  @override
  State<_DefaultMapBackground> createState() => _DefaultMapBackgroundState();
}

class _DefaultMapBackgroundState extends State<_DefaultMapBackground> {
  LatLng _currentPos = const LatLng(28.6139, 77.2090);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPos = LatLng(pos.latitude, pos.longitude);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _currentPos, zoom: 14),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
