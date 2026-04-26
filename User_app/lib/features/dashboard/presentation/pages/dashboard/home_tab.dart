import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pequire_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'dart:ui';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animations/animations.dart';
import 'package:lottie/lottie.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/auth/domain/entities/user_entity.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/provider_detail_page.dart';
import 'profile_tab.dart';
import 'categories_page.dart';
import 'quick_fix_categories_page.dart';
import 'emergency_sos_page.dart';
import 'subscription_page.dart';
import 'package:pequire_user_app/features/notifications/presentation/pages/notifications/notification_page.dart';
import 'location_picker_page.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/capture_issue_page.dart';
import 'package:pequire_user_app/core/services/location_service.dart';
import 'package:pequire_user_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:pequire_user_app/injection_container.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeTab extends StatefulWidget {
  final UserEntity user;
  const HomeTab({super.key, required this.user});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isFabOpen = false;
  String _currentLocation = 'Detecting location...';
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    setState(() {
      _currentLocation = 'Detecting location...';
    });
    
    try {
      final locationService = sl<LocationService>();
      final position = await locationService.getCurrentLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Timeout'),
      );
      
      if (position != null) {
        final address = await locationService.getAddressFromLatLng(position.latitude, position.longitude);
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
            _currentLocation = address;
          });
          _updateBackendLocation(position.latitude, position.longitude, address);
        }
      } else {
        if (mounted) {
          setState(() {
            _currentLocation = 'Tap to set location';
          });
        }
      }
    } catch (e) {
      debugPrint("Location initialization error: $e");
      if (mounted) {
        setState(() {
          _currentLocation = 'Tap to set location';
        });
      }
    }
  }

  Future<void> _updateBackendLocation(double lat, double lng, String address) async {
    final authRepository = sl<AuthRepository>();
    await authRepository.updateUserLocation(
      userId: widget.user.id,
      lat: lat,
      lng: lng,
      address: address,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildRecommendedSection(),
                  const SizedBox(height: 32),
                  _buildCategories(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isFabOpen) ...[
          _buildFabOption(
            icon: Icons.warning_amber_rounded,
            color: Colors.red,
            label: 'SOS',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencySOSPage())),
          ),
          const SizedBox(height: 16),
          _buildFabOption(
            icon: Icons.mic_none_rounded,
            color: AppColors.primary,
            label: 'Voice Request (Beta)',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuickFixCategoriesPage())),
          ),
          const SizedBox(height: 16),
          _buildFabOption(
            icon: Icons.camera_alt_outlined,
            color: AppColors.secondary,
            label: 'Quick Fix Request',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuickFixCategoriesPage())),
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          onPressed: () => setState(() => _isFabOpen = !_isFabOpen),
          backgroundColor: AppColors.secondary,
          child: AnimatedRotation(
            turns: _isFabOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(_isFabOpen ? Icons.add : Icons.flash_on_rounded, color: Colors.white, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          onPressed: onTap,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _buildGlassButton(
              onTap: () => _showLocationPicker(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Location',
                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _currentLocation,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_currentLocation == 'Detecting...' || _currentLocation == 'Detecting location...')
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                        )
                      else
                        Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.secondary),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildNotificationIcon(),
          const SizedBox(width: 12),
          _buildProfileIcon(context),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: GlassmorphicContainer(
              width: 50,
              height: 50,
              borderRadius: 16,
              blur: 15,
              alignment: Alignment.center,
              border: 1.5,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.05)],
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LocationPickerPage()),
    );

    if (result == 'CURRENT_LOCATION') {
      await _initLocation();
    } else if (result == 'SELECT_ON_MAP') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Map selection coming soon!')));
    } else if (result is LocationResult) {
      if (mounted) {
        setState(() {
          _currentLocation = result.address;
          _currentPosition = result.position;
        });
        _updateBackendLocation(result.position.latitude, result.position.longitude, result.address);
      }
    }
  }

  Widget _buildGlassButton({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (context, _) => const NotificationPage(),
      closedElevation: 0,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      closedColor: Colors.transparent,
      closedBuilder: (context, openContainer) => GlassmorphicContainer(
        width: 50,
        height: 50,
        borderRadius: 16,
        blur: 15,
        alignment: Alignment.center,
        border: 1.5,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.05)],
        ),
        child: const Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: 24),
      ),
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileTab(user: widget.user)),
        );
      },
      child:  GlassmorphicContainer(
        width: 50,
        height: 50,
        borderRadius: 16,
        blur: 15,
        alignment: Alignment.center,
        border: 1.5,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary.withOpacity(0.1), AppColors.secondary.withOpacity(0.05)],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.05)],
        ),
        child: const Icon(Icons.person_outline_rounded, color: Color(0xFF00BFA5), size: 24),
      ),
    );
  }

  Widget _buildSubscriptionBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubscriptionPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pequire Plus',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get priority response & 10% off',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Explore',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        openBuilder: (context, _) => _PremiumSearchPage(user: widget.user),
        closedElevation: 0,
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        closedColor: Colors.transparent,
        closedBuilder: (context, openContainer) => GestureDetector(
          onTap: openContainer,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Search "AC Repair"',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.mic_none_rounded, color: AppColors.secondary, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    final recommendations = [
      {
        'title': 'Spring Deep Cleaning',
        'subtitle': 'Get 20% off on your first home cleaning',
        'color': AppColors.primary,
        'image': Icons.auto_awesome,
      },
      {
        'title': 'AC Service Special',
        'subtitle': 'Expert maintenance for summer comfort',
        'color': AppColors.accent,
        'image': Icons.ac_unit_rounded,
      },
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          final item = recommendations[index];
          final color = item['color'] as Color;
          
          return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    item['image'] as IconData,
                    size: 140,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Recommended',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item['title'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['subtitle'] as String,
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.plumbing_rounded, 'label': 'Plumber', 'color': AppColors.primary},
      {'icon': Icons.electrical_services_rounded, 'label': 'Electrician', 'color': AppColors.secondary},
      {'icon': Icons.local_laundry_service_rounded, 'label': 'Laundry', 'color': AppColors.primary},
      {'icon': Icons.carpenter_rounded, 'label': 'Carpenter', 'color': AppColors.secondary},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CategoriesPage()),
                  );
                },
                child: Text(
                  'See All',
                  style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildPremiumCategoryItem(categories[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCategoryItem(Map<String, dynamic> category) {
    return _PressableContainer(
      onTap: () {},
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (category['color'] as Color).withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              category['label'] as String,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    final providers = [
      {'name': 'Dell Watson', 'rate': '\$50', 'rating': '4.9', 'category': 'Plumber'},
      {'name': 'Sarah Miller', 'rate': '\$45', 'rating': '4.8', 'category': 'Electrician'},
      {'name': 'John Smith', 'rate': '\$55', 'rating': '4.7', 'category': 'Laundry'},
    ];

    final filteredProviders = providers.where((p) {
      final name = (p['name'] as String).toLowerCase();
      final category = (p['category'] as String).toLowerCase();
      return name.contains(_searchQuery) || category.contains(_searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Best Professionals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Top rated in your community',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              if (filteredProviders.isNotEmpty)
                Text(
                  '1/${filteredProviders.length}',
                  style: TextStyle(fontSize: 13, color: Colors.black38),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (filteredProviders.isEmpty)
           const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Text('No results found for your search.', style: TextStyle(color: Colors.grey)),
          )
        else
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: filteredProviders.length,
              itemBuilder: (context, index) {
                return _buildPremiumFeaturedCard(filteredProviders[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumFeaturedCard(Map<String, String> provider) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 20),
      child: OpenContainer(
        transitionType: ContainerTransitionType.fade,
        openBuilder: (context, _) => ProviderDetailPage(providerName: provider['name']!, category: provider['category']!),
        closedElevation: 0,
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        closedColor: Colors.transparent,
        closedBuilder: (context, openContainer) => Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Center(
                        child: Icon(Icons.person, size: 70, color: AppColors.primary.withOpacity(0.3)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(provider['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                                  Text(provider['rating']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(provider['category']!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${provider['rate']}/hr', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbySection(BuildContext context) {
    final providers = [
      {'name': 'Mike Johnson', 'rate': '\$40', 'rating': '4.6', 'distance': '2.5 km', 'category': 'Plumber'},
      {'name': 'Emily Davis', 'rate': '\$48', 'rating': '4.8', 'distance': '3.1 km', 'category': 'Painter'},
    ];

    final filteredProviders = providers.where((p) {
      final name = (p['name'] as String).toLowerCase();
      final category = (p['category'] as String).toLowerCase();
      return name.contains(_searchQuery) || category.contains(_searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nearby Professionals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (filteredProviders.isNotEmpty)
                Text(
                  'See All',
                  style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (filteredProviders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text('No nearby providers found.', style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: filteredProviders.length,
            itemBuilder: (context, index) {
              return _buildNearbyProviderCard(context, filteredProviders[index], index);
            },
          ),
      ],
    );
  }

  Widget _buildNearbyProviderCard(BuildContext context, Map<String, String> provider, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderDetailPage(
              providerName: provider['name']!,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                size: 32,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider['name']!,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        provider['rating']!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${provider['distance']}',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  provider['rate']!,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
                const Text(
                  '/hr',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumSearchPage extends StatefulWidget {
  final UserEntity user;
  const _PremiumSearchPage({required this.user});

  @override
  State<_PremiumSearchPage> createState() => _PremiumSearchPageState();
}

class _PremiumSearchPageState extends State<_PremiumSearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildSectionTitle('Trending Searches'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildSearchTag('AC Maintenance'),
                      _buildSearchTag('Deep Cleaning'),
                      _buildSearchTag('Electrician'),
                      _buildSearchTag('Car Wash'),
                      _buildSearchTag('Plumbing'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Recent Professionals'),
                  const SizedBox(height: 16),
                  _buildRecentPro('Ronald Richards', 'Cleaning Expert', 4.9),
                  _buildRecentPro('Brooklyn Simmons', 'AC Technician', 4.8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search services...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  suffixIcon: Icon(Icons.mic_rounded, color: AppColors.secondary, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildSearchTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildRecentPro(String name, String service, double rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(service, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
              const SizedBox(width: 4),
              Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PressableContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PressableContainer({required this.child, required this.onTap});

  @override
  State<_PressableContainer> createState() => _PressableContainerState();
}

class _PressableContainerState extends State<_PressableContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
