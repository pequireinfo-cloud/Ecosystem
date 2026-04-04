import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

class MyCouponsPage extends StatelessWidget {
  const MyCouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'My Coupons',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                indicatorColor: AppColors.secondary,
                labelColor: AppColors.secondary,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Available'),
                  Tab(text: 'Used / Expired'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCouponsList(true),
                  _buildCouponsList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponsList(bool available) {
    final coupons = available
        ? [
            {'code': 'WELCOME20', 'discount': '20% OFF', 'desc': 'On your first cleaning service', 'expiry': 'Valid until 31 Dec 2024'},
            {'code': 'SUMMER50', 'discount': '\$50 OFF', 'desc': 'On AC maintenance services', 'expiry': 'Valid until 30 Aug 2024'},
          ]
        : [
            {'code': 'EXPIRED10', 'discount': '10% OFF', 'desc': 'Site-wide discount', 'expiry': 'Expired on 15 Jan 2024'},
          ];

    if (coupons.isEmpty) {
      return const Center(child: Text('No coupons found', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: coupons.length,
      itemBuilder: (context, index) {
        final coupon = coupons[index];
        return _buildCouponCard(coupon, available);
      },
    );
  }

  Widget _buildCouponCard(Map<String, String> coupon, bool available) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 100,
                color: available ? AppColors.secondary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    coupon['discount']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: available ? AppColors.secondary : Colors.grey,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon['code']!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon['desc']!,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const Spacer(),
                      const SizedBox(height: 8),
                      Text(
                        coupon['expiry']!,
                        style: TextStyle(fontSize: 11, color: available ? Colors.orange : Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              if (available)
                TextButton(
                  onPressed: () {},
                  child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
