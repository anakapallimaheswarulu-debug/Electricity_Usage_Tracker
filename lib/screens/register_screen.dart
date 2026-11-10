
import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Please fill all fields');
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showMessage('Please enter a valid email address');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters');
      return;
    }

    setState(() => isLoading = true);

    try {
      final exists = await DatabaseHelper.instance.emailExists(email);

      if (!mounted) return;

      if (exists) {
        setState(() => isLoading = false);
        _showMessage('This email is already registered.');
        return;
      }

      await DatabaseHelper.instance.insertUser(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage('Registration successful!');

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage('Registration failed. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark
            ? const Color(0xFF182337)
            : const Color(0xFF263653),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final background = theme.scaffoldBackgroundColor;
    final surface = theme.cardTheme.color ??
        (isDark ? const Color(0xFF101827) : Colors.white);
    final textColor = theme.colorScheme.onSurface;
    final secondaryColor = theme.textTheme.bodyMedium?.color ??
        (isDark ? const Color(0xFF9AA8BD) : const Color(0xFF46536B));
    final accent = isDark
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF1769D2);
    final borderColor = isDark
        ? const Color(0xFF34415A)
        : const Color(0xFFB9C5DA);

    return Scaffold(
      backgroundColor: background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF070B14),
                    Color(0xFF11102A),
                    Color(0xFF070B14),
                  ]
                : const [
                    Color(0xFFF4F6FC),
                    Color(0xFFEAF0FF),
                    Color(0xFFF8FAFF),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: 'Back to login',
                      ),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.65),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(
                                alpha: isDark ? 0.20 : 0.10,
                              ),
                              blurRadius: 22,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add_alt_1_rounded,
                          color: accent,
                          size: 43,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Be First to Create and Analyse',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Create your account and keep usage tracking of '
                      'your electricity consumption.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: secondaryColor,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildInputField(
                      controller: nameController,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      icon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      surface: surface,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      accent: accent,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      surface: surface,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      accent: accent,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: passwordController,
                      label: 'Password',
                      hint: 'Create a password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: obscurePassword,
                      surface: surface,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      accent: accent,
                      borderColor: borderColor,
                      suffixIcon: IconButton(
                        tooltip: obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: secondaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildInputField(
                      controller: confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      icon: Icons.verified_user_outlined,
                      obscureText: obscureConfirmPassword,
                      surface: surface,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      accent: accent,
                      borderColor: borderColor,
                      suffixIcon: IconButton(
                        tooltip: obscureConfirmPassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword =
                                !obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: secondaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              accent.withValues(alpha: 0.5),
                          elevation: isDark ? 4 : 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_alt_1_rounded),
                                  SizedBox(width: 10),
                                  Text(
                                    'CREATE ACCOUNT',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color surface,
    required Color textColor,
    required Color secondaryColor,
    required Color accent,
    required Color borderColor,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: accent),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(color: secondaryColor),
        hintStyle: TextStyle(
          color: secondaryColor.withValues(alpha: 0.75),
        ),
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: accent,
            width: 1.7,
          ),
        ),
      ),
    );
  }
}