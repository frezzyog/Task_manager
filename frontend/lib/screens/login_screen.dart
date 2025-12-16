import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui'; // For ImageFilter
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Handle keyboard manually or let it float
      body: Stack(
        children: [
          // 1. Background Visuals (Geometric Lines)
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0B0E14),
              child: CustomPaint(painter: GridPainter()),
            ),
          ),
          
          // 2. Glow Effects
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF246BFD).withOpacity(0.15),
                boxShadow: [BoxShadow(color: const Color(0xFF246BFD).withOpacity(0.4), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),

          // 3. Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                
                // Hero Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLAN,',
                        style: GoogleFonts.dmSans(
                          fontSize: 42,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'MANAGE &',
                        style: GoogleFonts.dmSans(
                          fontSize: 42,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.7),
                          height: 1.1,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'TRACK',
                            style: GoogleFonts.dmSans(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF246BFD), // Electric Blue
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF246BFD).withOpacity(0.2),
                              border: Border.all(color: const Color(0xFF246BFD)),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF246BFD), size: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'TASK',
                            style: GoogleFonts.dmSans(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Stay organized and boost productivity with our task management app. Prioritize tasks effortlessly.',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 3),

                // Login Form Area (Bottom)
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181C26).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF246BFD),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                                ),
                                child: auth.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Get Started',
                                            style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward_rounded, size: 20),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey.shade500),
                              children: const [
                                TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(color: Color(0xFF246BFD), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}

// Background Grid Painter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
