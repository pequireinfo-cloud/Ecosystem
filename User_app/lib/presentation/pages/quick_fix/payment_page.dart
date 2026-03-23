import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/booking_service.dart';
import 'searching_provider_page.dart';

class PaymentPage extends StatefulWidget {
  final bool isWaitAndSave;
  const PaymentPage({super.key, this.isWaitAndSave = false});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'Google Pay UPI';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Payment Method',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: 1.0, // Step 5 of 5
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                   Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL TO PAY',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '₹1,200',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                         GestureDetector(
                           onTap: () {}, // Show breakdown modal
                           child: const Text(
                            'View Price Breakdown',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                                                   ),
                         ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.plumbing, color: AppColors.secondary, size: 36),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Payment Options
            const Text(
              'Recommended',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildPaymentOption(
              icon: Icons.account_balance_wallet,
              title: 'Google Pay UPI',
              subtitle: 'Fastest way to pay',
              value: 'Google Pay UPI',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              icon: Icons.payments,
              title: 'PhonePe UPI',
              subtitle: 'Secure payment',
              value: 'PhonePe UPI',
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
             TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: AppColors.secondary),
              label: const Text(
                'Add new UPI ID',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),
            
            const Text(
              'Pay After Service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              icon: Icons.money,
              title: 'Cash after service',
              subtitle: 'Pay cash or QR after job is done',
              value: 'Cash',
              color: Colors.green,
            ),

            const SizedBox(height: 24),
            
            const Text(
              'Cards & More',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              icon: Icons.credit_card,
              title: 'Credit / Debit Card',
              subtitle: 'Visa, Mastercard, RuPay',
              value: 'Card',
               color: Colors.blueGrey,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              icon: Icons.account_balance,
              title: 'Wallets',
              subtitle: 'Paytm, Amazon Pay',
              value: 'Wallets',
               color: Colors.blueGrey,
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   const Icon(Icons.lock, size: 16, color: AppColors.secondary),
                   const SizedBox(width: 8),
                   Text(
                    '100% Secure Payments',
                    style: TextStyle(
                      color: AppColors.secondary.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                   ),
                ],
              ),
            ),
             const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                   'Total Payable',
                   style: TextStyle(color: Colors.grey, fontSize: 12),
                 ),
                 Text(
                   '₹1,200',
                   style: TextStyle(
                     fontSize: 20, 
                     fontWeight: FontWeight.bold,
                   ),
                 ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // Show loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    final bookingId = await BookingService().createBooking(
                      userId: 'temp_user_123', // TODO: Get from Auth
                      serviceType: 'Plumbing', // TODO: Get from AI analysis
                      lat: 28.6139,
                      lng: 77.2090,
                      address: '123, Green Park, New Delhi',
                      estimatedPrice: totalToPay.toDouble(),
                      isWaitAndSave: widget.isWaitAndSave,
                    );

                    if (context.mounted) {
                      Navigator.pop(context); // Close loading
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchingProviderPage(bookingId: bookingId),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking failed: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Book Service',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
  }) {
    bool isSelected = _selectedMethod == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.secondary : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: isSelected 
                ? Container(
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ) 
                : null,
            ),
          ],
        ),
      ),
    );
  }
}
