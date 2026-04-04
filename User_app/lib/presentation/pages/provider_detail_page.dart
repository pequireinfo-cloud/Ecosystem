import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';

class ProviderDetailPage extends StatefulWidget {
  final String providerName;
  final String category;
  const ProviderDetailPage({super.key, required this.providerName, this.category = 'Service Provider'});

  @override
  State<ProviderDetailPage> createState() => _ProviderDetailPageState();
}

class _ProviderDetailPageState extends State<ProviderDetailPage> {
  late ConfettiController _confettiController;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      if (_isFavorited) {
        _confettiController.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(context),
                const SizedBox(height: 24),
                _buildProviderInfo(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildGallerySection(),
                const SizedBox(height: 24),
                _buildBioSection(),
                const SizedBox(height: 24),
                _buildReviewsSection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.red, Colors.pink, Colors.orange],
            ),
          ),
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 320,
          decoration: const BoxDecoration(
            color: Color(0xFFFFCDD2),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.person,
              size: 120,
              color: Colors.grey.shade300,
            ),
          ),
        ),
        // Rating Badge
        Positioned(
          top: 200,
          left: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text(
                  '4.9',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        // Job Success Badge
        Positioned(
          top: 220,
          right: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '80%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Job Success',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        // Recommended Badge
        Positioned(
          top: 270,
          left: MediaQuery.of(context).size.width / 2 - 60,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Recommended',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        // Back Button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: _buildCircleAction(Icons.arrow_back_ios_new_rounded),
                ),
                GestureDetector(
                  onTap: _toggleFavorite,
                  child: _buildCircleAction(
                    _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isFavorited ? Colors.red : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCircleAction(IconData icon, {Color color = Colors.black}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildProviderInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.providerName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Verified Pro',
                  style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.category,
            style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                '\$50',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                '/hr',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      {'label': 'Total Earned', 'value': '\$30K+'},
      {'label': 'Job Completed', 'value': '230'},
      {'label': 'Hours Worked', 'value': '573'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: stats.map((stat) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat['label'] as String,
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBioSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Hey I\'m Savannah Nguyen, expert of Mobile Servicing. I have 8+ years of working experience. I appreciate the early delivery.',
              style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Read More',
              style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '(120)',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildReviewCard(),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C3E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A4A5E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'Jan 27, 2021',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'The was a great - the guy came out just fine and all our revisions were fixed in no time. I appreciate the timely delivery of which I was notified ahead of time.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A5E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '5G',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Service Gallery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 4,
            itemBuilder: (context, index) => Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.image_outlined, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showBookingSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Book Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Select Date & Time', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildCalendarHeatmap(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeatmap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Available slots', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('Elite Pro', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            itemCount: 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: index % 3 == 0 ? Colors.green.withOpacity(0.2) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('${index + 10}', style: const TextStyle(fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }
}

