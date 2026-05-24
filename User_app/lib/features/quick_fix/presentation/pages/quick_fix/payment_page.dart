import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/core/services/booking_service.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/widgets/quick_fix_base_layout.dart';
import 'package:pequire_user_app/features/quick_fix/domain/entities/booking_session.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/rating_feedback_page.dart';
import 'searching_provider_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/features/auth/presentation/bloc/auth_bloc.dart';

class PaymentPage extends StatefulWidget {
  final BookingSession session;
  final bool isWaitAndSave;
  
  const PaymentPage({
    super.key, 
    required this.session,
    this.isWaitAndSave = false,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedMethod = 'Pay via UPI (Prepaid)';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: widget.session.bookingId != null 
          ? BookingService().watchBooking(widget.session.bookingId!)
          : null,
      builder: (context, snapshot) {
        String displayPrice = widget.session.price?.toInt().toString() ?? '1,200';
        bool isFinalPayment = false;

        if (snapshot.hasData) {
          final data = snapshot.data!;
          if (data['finalPrice'] != null) {
            displayPrice = (data['finalPrice'] as num).toInt().toString();
            isFinalPayment = true;
          }
        }

        return QuickFixBaseLayout(
            title: isFinalPayment ? 'Final Payment' : 'Select Payment Method',
            initialSheetSize: 0.8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Total Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFinalPayment ? 'FINAL AMOUNT' : 'TOTAL TO PAY',
                                style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹$displayPrice',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF001233)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'View Price Breakdown',
                                style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isFinalPayment ? Icons.verified_rounded : Icons.account_balance_wallet_rounded, 
                            color: AppColors.primary, 
                            size: 30
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(isFinalPayment ? 'Pay Online (0% Fee)' : 'Pay Now (Prepaid)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF001233))),
                  const SizedBox(height: 16),
                  
                  _buildPaymentOption(isFinalPayment ? 'Pay via UPI' : 'Pay via UPI (Prepaid)', 'GPay, PhonePe, Paytm', Icons.qr_code_scanner_rounded, Colors.green),
                  
                  const SizedBox(height: 24),
                  
                  const Text('Other Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF001233))),
                  const SizedBox(height: 16),
                  _buildPaymentOption(isFinalPayment ? 'Cash' : 'Pay after service', 'Pay cash or direct QR to provider', Icons.money_rounded, Colors.orange),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final authState = context.read<AuthBloc>().state;
                        String currentUserId = 'temp_user_789';
                        if (authState is AuthAuthenticated) {
                           currentUserId = authState.user.id;
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to book a service')));
                           return;
                        }

                        // Show loading
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
  
                        try {
                          if (isFinalPayment) {
                             if (_selectedMethod.contains('UPI')) {
                               await _launchUPIIntent(displayPrice, widget.session.bookingId ?? 'BK-1234');
                               await BookingService().confirmPayment(widget.session.bookingId!, method: 'upi');
                             } else {
                               // Cash selected
                               await Future.delayed(const Duration(seconds: 1));
                             }
                             
                             if (mounted) {
                               Navigator.pop(context); // Close loading
                               Navigator.pushReplacement(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => RatingFeedbackPage(session: widget.session),
                                 ),
                               );
                             }
                          } else {
                            String timing = _selectedMethod.contains('UPI') ? 'prepaid' : 'postpaid';
                            final bookingId = await BookingService().createBooking(
                              userId: currentUserId,
                              serviceType: widget.session.category ?? 'General Service',
                              lat: widget.session.pickupLocation?.latitude ?? 28.6139,
                              lng: widget.session.pickupLocation?.longitude ?? 77.2090,
                              address: widget.session.pickupAddress ?? 'Current Location',
                              estimatedPrice: widget.session.price ?? 1200,
                              isWaitAndSave: widget.isWaitAndSave,
                              paymentTiming: timing,
                            );
  
                            widget.session.bookingId = bookingId;

                            if (timing == 'prepaid' && bookingId != null) {
                               await _launchUPIIntent(displayPrice, bookingId);
                               await BookingService().confirmPayment(bookingId, method: 'upi');
                            }
  
                            if (mounted) {
                              Navigator.pop(context); // Close loading
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchingProviderPage(session: widget.session),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context); // Close loading
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: $e')));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFinalPayment ? Colors.green : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isFinalPayment ? 'Pay & Complete' : 'Book Service', 
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
        );
      }
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon, Color color) {
    bool isSelected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF001233))),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            else
              Icon(Icons.circle_outlined, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUPIIntent(String amount, String transactionNote) async {
    // Actual business UPI ID
    final String upiId = 'ddayal7143@okaxis';
    final String payeeName = 'Pequire Services';
    
    final Uri upiUri = Uri.parse(
      'upi://pay?pa=$upiId&pn=$payeeName&am=$amount&cu=INR&tn=Payment for $transactionNote'
    );

    try {
      // Android 11+ often blocks canLaunchUrl for custom schemes even if added to queries.
      // So we force launch it and catch the exception if it fails.
      await launchUrl(upiUri, mode: LaunchMode.externalApplication);
      // We wait a few seconds so when they return, we assume payment was done (Phase 1 zero-cost assumption)
      await Future.delayed(const Duration(seconds: 3));
    } catch (e) {
      throw Exception("No UPI app found or could not launch: $e");
    }
  }
}

