
import 'dart:math';

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  late final AnimationController _animationController;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get background =>
      isDark ? const Color(0xFF050914) : const Color(0xFFF4F6FC);

  Color get surface =>
      isDark ? const Color(0xFF101827) : Colors.white;

  Color get primaryText =>
      isDark ? const Color(0xFFF5F7FF) : const Color(0xFF17213B);

  Color get secondaryText =>
      isDark ? const Color(0xFF9AA8BD) : const Color(0xFF46536B);

  Color get accent =>
      isDark ? const Color(0xFF00B7FF) : const Color(0xFF1769D2);

  Color get purple =>
      isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6741C8);

  Color get borderColor =>
      isDark ? const Color(0xFF33445E) : const Color(0xFFB9C5DA);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await DatabaseHelper.instance.loginUser(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (user == null) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password.')),
        );
        return;
      }

      final userId = user['id'] as int;
      final userName = user['name'] as String;
      final userEmail = user['email'] as String;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, $userName!')),
      );

      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            userId: userId,
            userName: userName,
            userEmail: userEmail,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Stack(
        children: [
          if (isDark)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: CyberBackgroundPainter(
                      progress: _animationController.value,
                    ),
                  );
                },
              ),
            )
          else
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF4F6FC),
                      Color(0xFFE6EEFF),
                      Color(0xFFF4F6FC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 30,
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        final glow = isDark
                            ? 18 +
                                (sin(_animationController.value * 2 * pi) +
                                        1) *
                                    7
                            : 12.0;

                        return Container(
                          width: 105,
                          height: 105,
                          decoration: BoxDecoration(
                            color: surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: accent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withValues(
                                  alpha: isDark ? 0.25 : 0.12,
                                ),
                                blurRadius: glow,
                                spreadRadius: isDark ? 3 : 1,
                              ),
                              if (isDark)
                                BoxShadow(
                                  color: purple.withValues(alpha: 0.15),
                                  blurRadius: 35,
                                  spreadRadius: 5,
                                ),
                            ],
                          ),
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: accent,
                            size: 60,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Power Your Insights',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Track your electricity usage, analyze consumption\n'
                      'and estimate your monthly bill.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 35),
                    _buildInputField(
                      controller: emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18),
                    _buildInputField(
                      controller: passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: secondaryText,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              accent.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: isDark ? 0 : 3,
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
                                  Icon(Icons.login_rounded, size: 25),
                                  SizedBox(width: 12),
                                  Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have an account? Register",
                        style: TextStyle(
                          color: accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
        color: primaryText,
        fontSize: 16,
      ),
      cursorColor: accent,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: accent),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(color: secondaryText),
        hintStyle: TextStyle(
          color: secondaryText.withValues(alpha: 0.75),
        ),
        filled: true,
        fillColor: surface.withValues(alpha: isDark ? 0.85 : 0.96),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
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
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }
}

class CyberBackgroundPainter extends CustomPainter {
  final double progress;

  CyberBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);

    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF030712),
          Color(0xFF071326),
          Color(0xFF050914),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final topGlow = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x2200B7FF), Color(0x0000B7FF)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.15),
          radius: size.width * 0.65,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.15),
      size.width * 0.65,
      topGlow,
    );

    final purpleGlow = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x228B5CF6), Color(0x008B5CF6)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width, size.height * 0.55),
          radius: size.width * 0.6,
        ),
      );

    canvas.drawCircle(
      Offset(size.width, size.height * 0.55),
      size.width * 0.6,
      purpleGlow,
    );

    for (int i = 0; i < 38; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.5 + random.nextDouble() * 1.5;
      final y = (baseY + progress * size.height * speed) % size.height;
      final radius = 1 + random.nextDouble() * 2;

      final particlePaint = Paint()
        ..color = i.isEven
            ? const Color(0x9900B7FF)
            : const Color(0x668B5CF6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }

    for (int i = 0; i < 7; i++) {
      final y = size.height * (0.12 + i * 0.12);
      final offset = sin(progress * 2 * pi + i) * 35;
      final startX = -30 + offset;
      final path = Path()..moveTo(startX, y);

      for (int j = 0; j < 6; j++) {
        final x = startX + j * (size.width / 5.0);
        final pointY = y + sin(progress * 2 * pi + j + i) * 10;
        path.lineTo(x, pointY);
      }

      final sparkPaint = Paint()
        ..color = i.isEven
            ? const Color(0x4400D9FF)
            : const Color(0x338B5CF6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawPath(path, sparkPaint);
    }

    for (int wave = 0; wave < 3; wave++) {
      final path = Path();
      final waveY = size.height - 95 + wave * 18;
      path.moveTo(0, waveY);

      for (int x = 0; x <= size.width; x += 10) {
        final y = waveY + sin(x / 45 + progress * 2 * pi + wave) * 8;
        path.lineTo(x.toDouble(), y);
      }

      final wavePaint = Paint()
        ..color = wave == 0
            ? const Color(0x4400B7FF)
            : const Color(0x228B5CF6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawPath(path, wavePaint);
    }

    for (int i = 0; i < 5; i++) {
      final x = size.width * (0.1 + i * 0.2);
      final y = size.height - 90 + sin(progress * 2 * pi + i) * 15;

      final nodePaint = Paint()
        ..color = const Color(0xAA00D9FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(Offset(x, y), 2.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CyberBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}