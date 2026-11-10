
import 'package:flutter/material.dart';
import 'landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LandingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark
        ? const Color(0xFF070B14)
        : const Color(0xFFF4F6FC);

    final surface = isDark
        ? const Color(0xFF101827)
        : Colors.white;

    final primaryText = isDark
        ? const Color(0xFFF5F7FF)
        : const Color(0xFF17213B);

    final secondaryText = isDark
        ? const Color(0xFF9AA8BD)
        : const Color(0xFF46536B);

    final accent = isDark
        ? const Color(0xFF00B7FF)
        : const Color(0xFF1769D2);

    final iconColor = isDark
        ? const Color(0xFFFFD60A)
        : const Color(0xFF6741C8);

    return Scaffold(
      backgroundColor: background,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF070B14),
                    Color(0xFF101827),
                    Color(0xFF070B14),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFFF4F6FC),
                    Color(0xFFE6EEFF),
                    Color(0xFFF4F6FC),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: accent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                        blurRadius: 25,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 70,
                    color: iconColor,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'Electricity Usage Tracker',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Monitor • Analyze • Save Energy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}