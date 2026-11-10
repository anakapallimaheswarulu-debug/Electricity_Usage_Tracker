
import 'package:flutter/material.dart';

import '../models/electricity_reading.dart';
import '../services/database_service.dart';

class AlertsScreen extends StatefulWidget {
  final int userId;

  const AlertsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<ElectricityReading> readings = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadAlerts();
  }

  Future<void> loadAlerts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        hasError = false;
      });
    }

    try {
      final data = await DatabaseService.instance.getReadings(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        readings = data;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  ElectricityReading? get latestReading =>
      readings.isEmpty ? null : readings.first;

  ElectricityReading? get previousReading =>
      readings.length < 2 ? null : readings[1];

  bool get hasHighUsage {
    final latest = latestReading;
    final previous = previousReading;

    if (latest == null || previous == null) return false;

    return latest.units > previous.units;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final latest = latestReading;

    final accent = isDark
        ? const Color(0xFF00B7FF)
        : const Color(0xFF1769D2);

    final purple = isDark
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF6741C8);

    final yellow = isDark
        ? const Color(0xFFFFD60A)
        : const Color(0xFFB88600);

    final orange = isDark
        ? const Color(0xFFFFA726)
        : const Color(0xFFB85C00);

    final textColor = theme.colorScheme.onSurface;
    final secondaryColor =
        theme.textTheme.bodyMedium?.color ??
        (isDark
            ? const Color(0xFF9AA8BD)
            : const Color(0xFF46536B));

    final surface = theme.colorScheme.surface;
    final borderColor = isDark
        ? const Color(0xFF29364B)
        : const Color(0xFFCFD8E8);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Alerts & Notifications',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Icon(
              Icons.notifications_active_rounded,
              color: yellow,
              size: 25,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: accent,
        backgroundColor: surface,
        onRefresh: loadAlerts,
        child: isLoading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.35,
                  ),
                  Center(
                    child: CircularProgressIndicator(color: accent),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Loading your alerts...',
                      style: TextStyle(color: secondaryColor),
                    ),
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                children: [
                  _buildHeader(
                    isDark: isDark,
                    surface: surface,
                    textColor: textColor,
                    secondaryColor: secondaryColor,
                    yellow: yellow,
                    borderColor: borderColor,
                  ),

                  const SizedBox(height: 22),

                  if (hasError)
                    _buildErrorCard(
                      accent: accent,
                      surface: surface,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      borderColor: borderColor,
                    )
                  else ...[
                    _alertCard(
                      icon: Icons.warning_amber_rounded,
                      iconColor: orange,
                      title: 'High Usage Warning',
                      message: hasHighUsage
                          ? 'Your latest recorded usage is higher than your previous recorded usage.'
                          : readings.length < 2
                              ? 'Add at least two readings to compare your electricity usage.'
                              : 'Your latest recorded usage is not higher than your previous recorded usage.',
                      time: 'Usage check',
                      surface: surface,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 15),

                    _alertCard(
                      icon: Icons.calendar_month_rounded,
                      iconColor: accent,
                      title: 'Monthly Reading Reminder',
                      message:
                          'Remember to add your current meter reading every month to keep your usage records updated.',
                      time: 'Reminder',
                      surface: surface,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 15),

                    _alertCard(
                      icon: Icons.receipt_long_rounded,
                      iconColor: purple,
                      title: 'Bill Estimate Available',
                      message: latest == null
                          ? 'Add a meter reading to calculate your estimated electricity bill.'
                          : 'Your latest estimated electricity bill is ₹${latest.billAmount.toStringAsFixed(2)}.',
                      time: 'Bill update',
                      surface: surface,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 15),

                    _alertCard(
                      icon: Icons.lightbulb_outline_rounded,
                      iconColor: yellow,
                      title: 'Energy Saving Tip',
                      message:
                          'Switch off appliances when they are not in use to help reduce electricity consumption.',
                      time: 'Energy tip',
                      surface: surface,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 22),

                    _buildCaughtUpCard(
                      accent: accent,
                      surface: surface,
                      textColor: textColor,
                      secondaryColor: secondaryColor,
                      borderColor: borderColor,
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildHeader({
    required bool isDark,
    required Color surface,
    required Color textColor,
    required Color secondaryColor,
    required Color yellow,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? const [
                  Color(0xFF21172F),
                  Color(0xFF111E32),
                ]
              : const [
                  Color(0xFFFFF7D9),
                  Color(0xFFEAF1FF),
                ],
        ),
        border: Border.all(
          color: yellow.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: yellow.withValues(alpha: 0.16),
              border: Border.all(
                color: yellow.withValues(alpha: 0.45),
              ),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: yellow,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stay Updated',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Important updates about your electricity usage.',
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required Color surface,
    required Color textColor,
    required Color secondaryColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 27,
            ),
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
                  time,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard({
    required Color accent,
    required Color surface,
    required Color textColor,
    required Color secondaryColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: accent,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'Could not load alerts',
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your saved readings and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryColor),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: loadAlerts,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaughtUpCard({
    required Color accent,
    required Color surface,
    required Color textColor,
    required Color secondaryColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 34,
              color: accent,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'You are all caught up!',
            style: TextStyle(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'These are the current alerts available in your app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: secondaryColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}