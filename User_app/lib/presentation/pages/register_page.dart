import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pequire_user_app/core/constants/app_colors.dart';
import 'package:pequire_user_app/core/constants/app_strings.dart';
import '../widgets/role_selection_widget.dart';
import '../state/auth_bloc.dart';
import '../state/auth_state.dart';
import '../../domain/entities/login_role.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  LoginRole _selectedRole = LoginRole.user;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage(user: state.user)),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Header Section (60%)
            Expanded(
              flex: 6,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: double.infinity,
                    color: AppColors.headerBackground,
                    child: Stack(
                      children: [
                        // Grid Painter Background
                        Positioned.fill(
                          child: CustomPaint(
                            painter: GridPainter(),
                          ),
                        ),
                        // Illustration
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Image.asset(
                              'assets/register_header.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // Back Button
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Form Section (40%)
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        AppStrings.registerTitle,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppStrings.registerSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      RoleSelectionWidget(
                        selectedRole: _selectedRole,
                        onRoleChanged: (role) {
                          setState(() {
                            _selectedRole = role;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: AppStrings.emailHint,
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: AppStrings.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F7),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    final email = _emailController.text.trim();
                                    final password = _passwordController.text.trim();

                                    if (email.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please fill in all fields'),
                                        ),
                                      );
                                      return;
                                    }

                                    context.read<AuthBloc>().add(
                                          RegisterSubmitted(
                                            email: email,
                                            password: password,
                                            role: _selectedRole,
                                          ),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: state is AuthLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    AppStrings.registerButton,
                                    style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: RichText(
                          text: const TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            children: [
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const double spacing = 30.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

