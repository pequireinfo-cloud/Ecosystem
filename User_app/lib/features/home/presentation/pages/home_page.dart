import 'package:flutter/material.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/features/auth/domain/entities/user_entity.dart';
import 'package:pequire_user_app/features/dashboard/presentation/pages/dashboard/home_tab.dart';
import 'package:pequire_user_app/features/quick_fix/presentation/pages/quick_fix/capture_issue_page.dart';


class HomePage extends StatefulWidget {
  final UserEntity user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  void _handleQuickFix() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CaptureIssuePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomeTab(user: widget.user),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SizedBox(
            width: 180,
            height: 60,
            child: FloatingActionButton.extended(
              onPressed: _handleQuickFix,
              backgroundColor: AppColors.secondary,
              icon: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 24),
              label: const Text(
                'QUICK FIX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }
}

