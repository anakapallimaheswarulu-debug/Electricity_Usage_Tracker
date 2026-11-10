
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/electricity_reading.dart';
import '../services/database_service.dart';

class AnalyticsScreen extends StatefulWidget {
  final int userId;

  const AnalyticsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  List<ElectricityReading> readings = [];
  bool isLoading = true;

  late final AnimationController _animationController;

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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    loadAnalytics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadAnalytics() async {
    try {
      final data = await DatabaseService.instance.getReadings(
        widget.userId,
      );

      data.sort((a, b) => a.date.compareTo(b.date));

      if (!mounted) return;

      setState(() {
        readings = data;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => isLoading = false);
      _showMessage('Unable to load analytics.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: surface,
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  double get averageUsage {
    if (readings.isEmpty) return 0;

    return readings.fold<double>(
          0,
          (total, reading) => total + reading.units,
        ) /
        readings.length;
  }

  double get averageBill {
    if (readings.isEmpty) return 0;

    return readings.fold<double>(
          0,
          (total, reading) => total + reading.billAmount,
        ) /
        readings.length;
  }

  ElectricityReading? get highestUsageReading {
    if (readings.isEmpty) return null;

    return readings.reduce(
      (a, b) => a.units >= b.units ? a : b,
    );
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
    } catch (_) {
      return date;
    }
  }

  String _shortDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      return '${parsedDate.day} ${months[parsedDate.month - 1]}';
    } catch (_) {
      return '';
    }
  }

  String get energyInsight {
    if (readings.isEmpty) {
      return 'Add meter readings to get personalized energy insights.';
    }

    if (readings.length == 1) {
      return 'Add another reading to compare your electricity usage and identify trends.';
    }

    final latest = readings[readings.length - 1];
    final previous = readings[readings.length - 2];

    if (latest.units > previous.units) {
      return 'Your latest electricity usage is higher than your previous reading. Consider checking high-power appliances to reduce future consumption.';
    }

    if (latest.units < previous.units) {
      return 'Good job! Your latest electricity usage is lower than your previous reading.';
    }

    return 'Your electricity usage is unchanged compared with your previous reading.';
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
          'Analytics',
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.insights_rounded,
              color: accentColor,
              size: 26,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (isDark)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => CustomPaint(
                  painter: AnalyticsEnergyPainter(
                    progress: _animationController.value,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            background.withValues(alpha: 0.45),
                            background.withValues(alpha: 0.88),
                          ]
                        : [
                            background.withValues(alpha: 0.10),
                            background.withValues(alpha: 0.30),
                          ],
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(color: accentColor),
            )
          else
            _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      color: accentColor,
      backgroundColor: surface,
      onRefresh: loadAnalytics,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: [
          _buildHeader(),
          const SizedBox(height: 22),
          _buildSummarySection(),
          const SizedBox(height: 28),
          _sectionTitle('Monthly Consumption', Icons.bolt_rounded),
          const SizedBox(height: 12),
          _buildUsageChart(),
          const SizedBox(height: 28),
          _sectionTitle('Monthly Bill Amount', Icons.currency_rupee_rounded),
          const SizedBox(height: 12),
          _buildBillChart(),
          const SizedBox(height: 24),
          _buildEnergyInsight(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF10263B),
                  Color(0xFF151B35),
                  Color(0xFF21153B),
                ]
              : const [
                  Color(0xFFE2EDFF),
                  Color(0xFFEDE6FF),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 22,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, purpleColor],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Electricity Analytics',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Understand your electricity consumption',
                  style: TextStyle(
                    color: mutedColor,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                icon: Icons.bolt_rounded,
                title: 'Average Usage',
                value: readings.isEmpty
                    ? '--'
                    : '${averageUsage.toStringAsFixed(0)} kWh',
                accent: accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                icon: Icons.currency_rupee_rounded,
                title: 'Average Bill',
                value: readings.isEmpty
                    ? '₹--'
                    : '₹${averageBill.toStringAsFixed(0)}',
                accent: purpleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _summaryCard(
          icon: Icons.trending_up_rounded,
          title: 'Highest Usage',
          value: highestUsageReading == null
              ? '--'
              : '${highestUsageReading!.units.toStringAsFixed(0)} kWh • ${formatDate(highestUsageReading!.date)}',
          accent: isDark
              ? const Color(0xFFFFD60A)
              : const Color(0xFFB77900),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.06),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accent, size: 23),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: TextStyle(
              color: mutedColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: accentColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageChart() {
    return _chartContainer(
      child: readings.isEmpty
          ? _emptyChart('No readings available')
          : BarChart(
              BarChartData(
                maxY: _chartMaxUsage(),
                minY: 0,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _usageInterval(),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: borderColor.withValues(alpha: 0.65),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: _usageInterval(),
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= readings.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: Text(
                            _shortDate(readings[index].date),
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(readings.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: readings[index].units,
                        width: 19,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [accentColor, purpleColor],
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: _chartMaxUsage(),
                          color: surfaceAlt.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
    );
  }

  Widget _buildBillChart() {
    return _chartContainer(
      child: readings.isEmpty
          ? _emptyChart('No bill data available')
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: _chartMaxBill(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _billInterval(),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: borderColor.withValues(alpha: 0.65),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: _billInterval(),
                      getTitlesWidget: (value, meta) => Text(
                        '₹${value.toInt()}',
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= readings.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: Text(
                            _shortDate(readings[index].date),
                            style: TextStyle(
                              color: mutedColor,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      readings.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        readings[index].billAmount,
                      ),
                    ),
                    isCurved: true,
                    curveSmoothness: 0.25,
                    barWidth: 3.5,
                    color: purpleColor,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          purpleColor.withValues(alpha: 0.22),
                          purpleColor.withValues(alpha: 0.01),
                        ],
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: accentColor,
                          strokeWidth: 2,
                          strokeColor: surface,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _chartContainer({required Widget child}) {
    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(8, 20, 16, 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.025),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _emptyChart(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: mutedColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEnergyInsight() {
    final latestUnits =
        readings.isEmpty ? 0.0 : readings.last.units;
    final previousUnits =
        readings.length < 2 ? latestUnits : readings[readings.length - 2].units;

    final isIncreasing = readings.length > 1 && latestUnits > previousUnits;
    final isDecreasing = readings.length > 1 && latestUnits < previousUnits;

    final insightColor = isIncreasing
        ? (isDark ? const Color(0xFFFFB347) : const Color(0xFFB45309))
        : isDecreasing
            ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16803D))
            : accentColor;

    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: insightColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.lightbulb_rounded,
              color: insightColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Energy Insight',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  energyInsight,
                  style: TextStyle(
                    color: mutedColor,
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

  double _chartMaxUsage() {
    if (readings.isEmpty) return 100;

    double highest = 0;

    for (final reading in readings) {
      if (reading.units > highest) highest = reading.units;
    }

    if (highest < 100) return 100;

    return ((highest / 50).ceil() * 50) + 50;
  }

  double _usageInterval() {
    final max = _chartMaxUsage();

    if (max <= 200) return 50;
    if (max <= 500) return 100;

    return 200;
  }

  double _chartMaxBill() {
    if (readings.isEmpty) return 1000;

    double highest = 0;

    for (final reading in readings) {
      if (reading.billAmount > highest) highest = reading.billAmount;
    }

    if (highest < 500) return 500;

    return ((highest / 500).ceil() * 500) + 500;
  }

  double _billInterval() {
    final max = _chartMaxBill();

    if (max <= 2000) return 500;
    if (max <= 5000) return 1000;

    return 2000;
  }
}

class AnalyticsEnergyPainter extends CustomPainter {
  final double progress;

  AnalyticsEnergyPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final blueGlow = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x3300B7FF), Color(0x0000B7FF)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.15, size.height * 0.08),
          radius: size.width * 0.65,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.08),
      size.width * 0.65,
      blueGlow,
    );

    final purpleGlow = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x298B5CF6), Color(0x008B5CF6)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.9, size.height * 0.45),
          radius: size.width * 0.55,
        ),
      );

    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.45),
      size.width * 0.55,
      purpleGlow,
    );

    final gridPaint = Paint()
      ..color = const Color(0x1800B7FF)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 45) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y < size.height; y += 45) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final wavePaint = Paint()
      ..color = const Color(0x4400B7FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path();

    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height * 0.72 +
          math.sin(x / size.width * math.pi * 4 + progress * math.pi * 2) *
              24;

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant AnalyticsEnergyPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}