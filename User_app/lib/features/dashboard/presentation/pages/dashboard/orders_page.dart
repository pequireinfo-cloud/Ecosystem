import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pequire_user_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/bloc/order_bloc.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/bloc/order_event.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/bloc/order_state.dart';
import 'package:pequire_user_app/injection_container.dart';
import 'chat_page.dart';
import 'tracking_page.dart';
import 'package:pequire_user_app/core/widgets/pequire_shimmer.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String userId = '';
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    return BlocProvider(
      create: (context) => sl<OrderBloc>()..add(GetUserOrders(userId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          title: const Text(
            'My Orders',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return PequireShimmer.ordersList();
            } else if (state is OrderLoaded) {
              if (state.orders.isEmpty) {
                return const Center(child: Text('No orders found'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(context, state.orders[index]);
                },
              );
            } else if (state is OrderError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> order) {
    final title = order['serviceType'] ?? 'General Service';
    final date = order['scheduledDate'] ?? 'Date TBD';
    final status = order['status'] ?? 'Unknown';
    
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'in-progress':
      case 'accepted':
        statusColor = const Color(0xFF2196F3);
        break;
      case 'pending':
        statusColor = const Color(0xFFFF9800);
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.build_circle_rounded,
                  color: statusColor,
                  size: 26,
                ),
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
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (status.toLowerCase() != 'completed') ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            userName: order['providerName'] ?? 'Provider',
                            serviceType: title,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('Chat'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      backgroundColor: const Color(0xFF6366F1).withOpacity(0.08),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackingPage(
                            serviceTitle: title,
                            orderId: order['_id'] ?? order['id'] ?? 'ORDER',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Track Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
