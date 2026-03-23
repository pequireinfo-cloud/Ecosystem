import 'package:flutter/material.dart';
import 'package:pequire_admin_panel/features/providers/screens/provider_management_screen.dart';
import 'package:pequire_admin_panel/features/bookings/screens/booking_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: const Color(0xFF0F172A),
            child: Column(
              children: [
                const SizedBox(height: 36),
                // Logo + Wordmark
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Image.asset('assets/lOGO (1).png', height: 34, fit: BoxFit.contain),
                      const SizedBox(width: 10),
                      Image.asset('assets/Wordmark.png', height: 18, fit: BoxFit.contain),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF025EF3).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('ADMIN', style: TextStyle(color: Color(0xFF60A5FA), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 32),
                _sidebarItem(0, Icons.dashboard_rounded, 'Dashboard'),
                _sidebarItem(1, Icons.people_rounded, 'Providers'),
                _sidebarItem(2, Icons.map_rounded, 'Live Map'),
                _sidebarItem(3, Icons.book_online_rounded, 'Bookings'),
                _sidebarItem(4, Icons.analytics_rounded, 'Analytics'),
                const Spacer(),
                _sidebarItem(5, Icons.settings_rounded, 'Settings'),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Navbar
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      Text(
                        _selectedIndex == 0 ? 'Dashboard Overview' : (_selectedIndex == 1 ? 'Provider Management' : (_selectedIndex == 3 ? 'Booking Management' : 'Admin Panel')), 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications_none_rounded, color: Color(0xFF64748B)),
                      const SizedBox(width: 20),
                      const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.person_rounded, color: Color(0xFF025EF3))),
                    ],
                  ),
                ),
                
                // Actual View Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: _selectedIndex == 1 
                      ? const ProviderManagementScreen() 
                      : (_selectedIndex == 3 
                          ? const BookingManagementScreen()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatsGrid(),
                                const SizedBox(height: 32),
                                _buildRecentActivity(),
                              ],
                            )
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : const Color(0xFF94A3B8), size: 20),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF94A3B8), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _statCard('Total Providers', '1,284', '+12%', Colors.blue),
        const SizedBox(width: 20),
        _statCard('Active Bookings', '45', '+5%', Colors.green),
        const SizedBox(width: 20),
        _statCard('Revenue', '₹4.2L', '+18%', Colors.orange),
        const SizedBox(width: 20),
        _statCard('Pending KYC', '12', '-2%', Colors.red),
      ],
    );
  }

  Widget _statCard(String title, String value, String change, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(change, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Systems Monitoring', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _activityItem('Provider "Amit Kumar" updated location', 'Just now'),
          _activityItem('New booking request #4521 created', '2 mins ago'),
          _activityItem('KYC submission pending for "Suresh P."', '15 mins ago'),
        ],
      ),
    );
  }

  Widget _activityItem(String title, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.blue),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(color: Color(0xFF1E293B))),
          const Spacer(),
          Text(time, style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ],
      ),
    );
  }
}
