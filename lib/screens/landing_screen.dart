
import 'package:flutter/material.dart';
import 'login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background = isDark
        ? const Color(0xFF070B14)
        : const Color(0xFFF4F6FC);
    final surface = isDark ? const Color(0xFF101827) : Colors.white;
    final primaryText = isDark
        ? const Color(0xFFF5F7FF)
        : const Color(0xFF17213B);
    final secondaryText = isDark
        ? const Color(0xFF9AA8BD)
        : const Color(0xFF46536B);
    final accent = isDark
        ? const Color(0xFF00B7FF)
        : const Color(0xFF1769D2);
    final purple = isDark
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF6741C8);
    final iconColor = isDark
        ? const Color(0xFFFFD60A)
        : const Color(0xFF6741C8);

    return Scaffold(
      backgroundColor: background,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
                    Color(0xFF070B14),
                    Color(0xFF101827),
                    Color(0xFF070B14),
                  ]
                : const [
                    Color(0xFFF4F6FC),
                    Color(0xFFE6EEFF),
                    Color(0xFFF4F6FC),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const Spacer(),

                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: accent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(
                          alpha: isDark ? 0.25 : 0.12,
                        ),
                        blurRadius: 30,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 75,
                    color: iconColor,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  'Electricity Usage Tracker',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  'Monitor your electricity consumption,\nanalyze your usage and estimate your bill.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FeatureItem(
                      icon: Icons.bolt_rounded,
                      text: 'Track\nUsage',
                      isDark: isDark,
                      surface: surface,
                      purple: purple,
                      iconColor: iconColor,
                      textColor: primaryText,
                    ),
                    FeatureItem(
                      icon: Icons.bar_chart_rounded,
                      text: 'Analyze\nUsage',
                      isDark: isDark,
                      surface: surface,
                      purple: purple,
                      iconColor: iconColor,
                      textColor: primaryText,
                    ),
                    FeatureItem(
                      icon: Icons.currency_rupee_rounded,
                      text: 'Estimate\nBill',
                      isDark: isDark,
                      surface: surface,
                      purple: purple,
                      iconColor: iconColor,
                      textColor: primaryText,
                    ),
                  ],
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: isDark ? 8 : 3,
                      shadowColor: accent.withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  'Save Energy • Save Money',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  final Color surface;
  final Color purple;
  final Color iconColor;
  final Color textColor;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.text,
    required this.isDark,
    required this.surface,
    required this.purple,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: purple.withValues(alpha: isDark ? 1 : 0.35),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}