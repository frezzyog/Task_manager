import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F172A);
    const accentOrange = Color(0xFFE67E22);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create Account',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join the team & get productive',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.blueGrey.shade200,
                ),
              ),
              const SizedBox(height: 48),

              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDarkTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        icon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildDarkTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        icon: Icons.alternate_email_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildDarkTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        obscureText: _obscurePassword,
                        onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 20),
                      
                      _buildDarkTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_reset_rounded,
                        isPassword: true,
                        obscureText: _obscureConfirm,
                        onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      const SizedBox(height: 24),

                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          if (auth.errorMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(color: Color(0xFFFF4757), fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      Consumer<AuthProvider>(
                        builder: (context, auth, _) {
                          return ElevatedButton(
                            onPressed: auth.isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('GET STARTED'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggle,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      cursorColor: const Color(0xFFE67E22),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade400, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.blueGrey.shade400,
                  size: 20,
                ),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF0F172A),
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE67E22), width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label is required';
        return null;
      },
    );
  }
}
