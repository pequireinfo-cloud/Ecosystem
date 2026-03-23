import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingManagementScreen extends StatelessWidget {
  const BookingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Booking Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded),
              label: const Text('Export CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _buildBookingStats(),
        const SizedBox(height: 32),
        _buildBookingTable(),
      ],
    );
  }

  Widget _buildBookingStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        int total = 0;
        int pending = 0;
        int accepted = 0;
        
        if (snapshot.hasData) {
          total = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            final status = (doc.data() as Map<String, dynamic>)['status'];
            if (status == 'pending') pending++;
            if (status == 'accepted') accepted++;
          }
        }

        return Row(
          children: [
            _statMiniCard('Total Bookings', total.toString(), Colors.blue),
            const SizedBox(width: 20),
            _statMiniCard('Pending', pending.toString(), Colors.orange),
            const SizedBox(width: 20),
            _statMiniCard('Accepted/Live', accepted.toString(), Colors.green),
          ],
        );
      }
    );
  }

  Widget _statMiniCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Real-time Bookings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No bookings found')));
              }

              return Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(1.5),
                },
                children: [
                  _tableHeader(),
                  ...snapshot.data!.docs.map((doc) => _tableRow(doc)).toList(),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
      children: ['ID', 'Service', 'Address', 'Status', 'Actions'].map((label) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B), fontSize: 13),
          ),
        );
      }).toList(),
    );
  }

  TableRow _tableRow(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id.substring(0, 8);
    final status = data['status'] ?? 'N/A';
    
    Color statusColor = Colors.grey;
    if (status == 'pending') statusColor = Colors.orange;
    if (status == 'accepted') statusColor = Colors.green;
    if (status == 'completed') statusColor = Colors.blue;

    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 16), child: Text('#$id')),
        Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 16), child: Text(data['serviceType'] ?? 'N/A')),
        Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 16), child: Text(data['address'] ?? 'N/A', maxLines: 1, overflow: TextOverflow.ellipsis)),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16), 
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8), 
          child: IconButton(icon: const Icon(Icons.more_vert_rounded, size: 20), onPressed: () {}),
        ),
      ],
    );
  }
}
