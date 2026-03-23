import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class InviteFriendsPage extends StatefulWidget {
  const InviteFriendsPage({super.key});

  @override
  State<InviteFriendsPage> createState() => _InviteFriendsPageState();
}

class _InviteFriendsPageState extends State<InviteFriendsPage> {
  final List<Map<String, dynamic>> _contacts = [
    {'name': 'Tynisha Obey', 'phone': '+1-300-555-0135', 'invited': false, 'image': 'https://i.pravatar.cc/150?u=1'},
    {'name': 'Florencio Dorrance', 'phone': '+1-202-555-0136', 'invited': true, 'image': 'https://i.pravatar.cc/150?u=2'},
    {'name': 'Chantal Shelburne', 'phone': '+1-300-555-0119', 'invited': false, 'image': 'https://i.pravatar.cc/150?u=3'},
    {'name': 'Maryland Winkles', 'phone': '+1-300-555-0161', 'invited': true, 'image': 'https://i.pravatar.cc/150?u=4'},
    {'name': 'Rodolfo Goode', 'phone': '+1-300-555-0136', 'invited': true, 'image': 'https://i.pravatar.cc/150?u=5'},
    {'name': 'Benny Spanbauer', 'phone': '+1-202-555-0167', 'invited': false, 'image': 'https://i.pravatar.cc/150?u=6'},
    {'name': 'Tyra Dhillon', 'phone': '+1-202-555-0119', 'invited': false, 'image': 'https://i.pravatar.cc/150?u=7'},
    {'name': 'Jamel Eusebio', 'phone': '+1-300-555-0171', 'invited': true, 'image': 'https://i.pravatar.cc/150?u=8'},
    {'name': 'Pedro Huard', 'phone': '+1-202-555-0171', 'invited': false, 'image': 'https://i.pravatar.cc/150?u=9'},
    {'name': 'Clinton Mcclure', 'phone': '+1-300-555-0171', 'invited': false, 'image': 'https://i.pravatar.cc/150?u=10'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Invite Friends',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(contact['image']),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact['phone'],
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _buildInviteButton(index),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInviteButton(int index) {
    final bool isInvited = _contacts[index]['invited'];
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _contacts[index]['invited'] = !isInvited;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isInvited ? Colors.white : AppColors.redesignPurple,
          foregroundColor: isInvited ? AppColors.redesignPurple : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isInvited ? const BorderSide(color: AppColors.redesignPurple) : BorderSide.none,
          ),
        ),
        child: Text(
          isInvited ? 'Invited' : 'Invite',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
