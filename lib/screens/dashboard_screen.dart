
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/electricity_reading.dart';
import '../services/database_service.dart';
import 'add_reading_screen.dart';
import 'usage_history_screen.dart';
import 'analytics_screen.dart';
import 'bill_estimate_screen.dart';
import 'alerts_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String userEmail;

  const DashboardScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  List<ElectricityReading> readings = [];
  bool isLoading = true;

  late String currentName;
  late String currentEmail;
  late AnimationController _animationController;

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get background =>
      isDark ? const Color(0xFF070B14) : const Color(0xFFF4F6FC);

  Color get surface =>
      isDark ? const Color(0xFF101827) : Colors.white;

  Color get surfaceAlt =>
      isDark ? const Color(0xFF182337) : const Color(0xFFE9EEFA);

  Color get textColor =>
      isDark ? const Color(0xFFF5F7FF) : const Color(0xFF17213B);

  Color get mutedColor =>
      isDark ? const Color(0xFF9AA8BD) : const Color(0xFF46536B);

  Color get accentColor =>
      isDark ? const Color(0xFF00B7FF) : const Color(0xFF1769D2);

  Color get purpleColor =>
      isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6741C8);

  Color get borderColor =>
      isDark ? const Color(0x44516D8C) : const Color(0xFFB9C5DA);

  @override
  void initState() {
    super.initState();

    currentName = widget.userName;
    currentEmail = widget.userEmail;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    loadDashboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadDashboard() async {
    try {
      final data = await DatabaseService.instance.getReadings(widget.userId);

      if (!mounted) return;

      setState(() {
        readings = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openHistory() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UsageHistoryScreen(userId: widget.userId),
      ),
    );

    if (mounted) {
      await loadDashboard();
    }
  }

  Future<void> openAnalytics() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyticsScreen(userId: widget.userId),
      ),
    );

    if (mounted) {
      await loadDashboard();
    }
  }

  Future<void> openProfile() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          userName: currentName,
          userEmail: currentEmail,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      currentName = result['name'] ?? currentName;
      currentEmail = result['email'] ?? currentEmail;
    });
  }

  ElectricityReading? get latestReading =>
      readings.isEmpty ? null : readings[0];

  ElectricityReading? get previousReading =>
      readings.length < 2 ? null : readings[1];

  double get latestUsage => latestReading?.units ?? 0;

  double get latestBill => latestReading?.billAmount ?? 0;

  double? get usageChangePercent {
    if (previousReading == null || previousReading!.units == 0) {
      return null;
    }

    return ((latestUsage - previousReading!.units) /
            previousReading!.units) *
        100;
  }

  String get comparisonText {
    if (readings.length < 2) {
      return 'Add another reading to compare usage';
    }

    final change = usageChangePercent;

    if (change == null) {
      return 'Unable to compare usage';
    }

    if (change > 0) {
      return 'Usage increased by ${change.toStringAsFixed(1)}%';
    }

    if (change < 0) {
      return 'Usage decreased by ${change.abs().toStringAsFixed(1)}%';
    }

    return 'No change in usage';
  }

  Color get comparisonColor {
    final change = usageChangePercent;

    if (change == null) return mutedColor;

    if (change > 0) {
      return isDark
          ? const Color(0xFFFFB347)
          : const Color(0xFFB45309);
    }

    if (change < 0) {
      return isDark
          ? const Color(0xFF4ADE80)
          : const Color(0xFF16803D);
    }

    return mutedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textColor,
        elevation: 0,
        title: Text(
          'Electricity Tracker',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: Icon(
              Icons.notifications_none_rounded,
              color: accentColor,
              size: 26,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AlertsScreen(userId: widget.userId),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: accentColor),
            )
          : Stack(
              children: [
                if (isDark)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) => CustomPaint(
                        painter: DashboardEnergyPainter(
                          progress: _animationController.value,
                        ),
                      ),
                    ),
                  ),
                RefreshIndicator(
                  color: accentColor,
                  backgroundColor: surface,
                  onRefresh: loadDashboard,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                    children: [
                      _buildWelcomeSection(),
                      const SizedBox(height: 22),
                      _buildMainUsageCard(),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              icon: Icons.currency_rupee_rounded,
                              title: 'Estimated Bill',
                              value: latestReading == null
                                  ? '₹--'
                                  : '₹${latestBill.toStringAsFixed(0)}',
                              iconColor: isDark
                                  ? const Color(0xFFFFD60A)
                                  : const Color(0xFFB77900),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              icon: Icons.bolt_rounded,
                              title: 'Previous Usage',
                              value: previousReading == null
                                  ? '--'
                                  : '${previousReading!.units.toStringAsFixed(0)} kWh',
                              iconColor: purpleColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      _sectionHeader(),
                      const SizedBox(height: 14),
                      _actionCard(
                        icon: Icons.add_circle_outline_rounded,
                        title: 'Add Meter Reading',
                        subtitle: 'Enter your latest meter reading',
                        accent: accentColor,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddReadingScreen(
                                userId: widget.userId,
                              ),
                            ),
                          );

                          if (mounted) {
                            await loadDashboard();
                          }
                        },
                      ),
                      const SizedBox(height: 11),
                      _actionCard(
                        icon: Icons.history_rounded,
                        title: 'Usage History',
                        subtitle: 'View your previous readings',
                        accent: purpleColor,
                        onTap: openHistory,
                      ),
                      const SizedBox(height: 11),
                      _actionCard(
                        icon: Icons.bar_chart_rounded,
                        title: 'Analytics',
                        subtitle: 'Analyze your electricity consumption',
                        accent: accentColor,
                        onTap: openAnalytics,
                      ),
                      const SizedBox(height: 11),
                      _actionCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'Bill Estimate',
                        subtitle: 'Calculate your estimated bill',
                        accent: isDark
                            ? const Color(0xFFFFD60A)
                            : const Color(0xFFB77900),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BillEstimateScreen(),
                            ),
                          );

                          if (mounted) {
                            await loadDashboard();
                          }
                        },
                      ),
                      const SizedBox(height: 22),
                      _buildComparisonCard(),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              color: isDark
                                  ? const Color(0xFF4ADE80)
                                  : const Color(0xFF16803D),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Your electricity data is stored locally on this device.',
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: NavigationBar(
          height: 72,
          backgroundColor: surface,
          elevation: 0,
          selectedIndex: 0,
          indicatorColor: accentColor.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            if (index == 1) {
              openHistory();
            }
            if (index == 2) {
              openAnalytics();
            }
            if (index == 3) {
              openProfile();
            }
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: mutedColor),
              selectedIcon: Icon(
                Icons.dashboard_rounded,
                color: accentColor,
              ),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded, color: mutedColor),
              selectedIcon: Icon(Icons.history_rounded, color: accentColor),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: mutedColor),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: accentColor),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: mutedColor),
              selectedIcon: Icon(Icons.person_rounded, color: accentColor),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME BACK',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                currentName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your electricity overview is ready',
                style: TextStyle(color: mutedColor, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: surfaceAlt,
            shape: BoxShape.circle,
            border: Border.all(color: accentColor, width: 1.5),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.20),
                      blurRadius: 18,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.person_outline_rounded,
            color: accentColor,
            size: 27,
          ),
        ),
      ],
    );
  }

  Widget _buildMainUsageCard() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF1B304B),
                  Color(0xFF121E34),
                  Color(0xFF1B1736),
                ]
              : const [
                  Color(0xFFE4EEFF),
                  Color(0xFFF0EAFE),
                  Color(0xFFFFFFFF),
                ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDark
              ? const Color(0x7764C9FF)
              : const Color(0xFFB9C9E8),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? accentColor : purpleColor)
                .withValues(alpha: isDark ? 0.12 : 0.06),
            blurRadius: 22,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: isDark
                      ? const Color(0xFFFFD60A)
                      : const Color(0xFFB77900),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT USAGE',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'LATEST METER DATA',
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.bolt_rounded,
                color: accentColor.withValues(alpha: 0.55),
                size: 27,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                latestReading == null
                    ? '--'
                    : latestUsage.toStringAsFixed(0),
                style: TextStyle(
                  color: textColor,
                  fontSize: 49,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 9),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  'kWh',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            latestReading == null
                ? 'Add a meter reading to begin tracking'
                : 'Electricity consumed in your latest reading',
            style: TextStyle(color: mutedColor, fontSize: 13),
          ),
          const SizedBox(height: 19),
          Divider(color: borderColor),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(Icons.insights_rounded, color: purpleColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  readings.length < 2
                      ? 'Add more readings to see usage trends'
                      : comparisonText,
                  style: TextStyle(
                    color: readings.length < 2 ? textColor : comparisonColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 23),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: TextStyle(color: mutedColor, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 39,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                color: textColor,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Manage your electricity usage',
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback onTap,
  }) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: accent.withValues(alpha: 0.10),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(color: mutedColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: accent,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: purpleColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.compare_arrows_rounded,
              color: purpleColor,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Previous Reading Comparison',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  comparisonText,
                  style: TextStyle(
                    color: comparisonColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

// Cyber effects are displayed only in Dark Cyber mode.
class DashboardEnergyPainter extends CustomPainter {
  final double progress;

  DashboardEnergyPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final blueGlow = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x4400B7FF), Color(0x0000B7FF)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.13),
          radius: size.width * 0.62,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.13),
      size.width * 0.62,
      blueGlow,
    );

    final purpleGlow = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x388B5CF6), Color(0x008B5CF6)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.08, size.height * 0.68),
          radius: size.width * 0.58,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.68),
      size.width * 0.58,
      purpleGlow,
    );

    final random = Random(72);

    for (int i = 0; i < 34; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final x = baseX + sin(progress * 2 * pi + i) * 11;
      final y = baseY + cos(progress * 2 * pi + i * 0.8) * 14;
      final radius = 1.3 + random.nextDouble() * 2.2;
      final opacity = 0.45 +
          ((sin(progress * 2 * pi + i * 1.7) + 1) / 2) * 0.45;

      final paint = Paint()
        ..color = i % 4 == 0
            ? Color.fromRGBO(139, 92, 246, opacity)
            : Color.fromRGBO(0, 183, 255, opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    final gridPaint = Paint()
      ..color = const Color(0x214AA3D8)
      ..strokeWidth = 1;

    for (int i = 1; i < 10; i++) {
      final y = size.height * 0.10 + i * 65;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 1; i < 6; i++) {
      final x = size.width * 0.10 + i * 75;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final path = Path()..moveTo(0, size.height * 0.82);

    for (double x = 0; x <= size.width; x += 8) {
      final y =
          size.height * 0.82 + sin(x / 42 + progress * 2 * pi) * 9;
      path.lineTo(x, y);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x5500B7FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final signalX =
        (progress * size.width * 1.4) % (size.width + 100) - 50;
    final signalY = size.height * 0.82 +
        sin(signalX / 42 + progress * 2 * pi) * 9;

    canvas.drawCircle(
      Offset(signalX, signalY),
      7,
      Paint()
        ..color = const Color(0x5500B7FF)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawCircle(
      Offset(signalX, signalY),
      3.2,
      Paint()..color = const Color(0xFF00C8FF),
    );
  }

  @override
  bool shouldRepaint(covariant DashboardEnergyPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}