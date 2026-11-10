
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/electricity_reading.dart';
import '../services/database_service.dart';

class AddReadingScreen extends StatefulWidget {
  final int userId;

  const AddReadingScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AddReadingScreen> createState() => _AddReadingScreenState();
}

class _AddReadingScreenState extends State<AddReadingScreen>
    with SingleTickerProviderStateMixin {
  final previousController = TextEditingController();
  final currentController = TextEditingController();
  final rateController = TextEditingController(text: '7');

  double units = 0;
  double estimatedBill = 0;

  late final AnimationController _animationController;
  bool isSaving = false;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get accent => isDark
      ? const Color(0xFF00B7FF)
      : const Color(0xFF1769D2);

  Color get purple => isDark
      ? const Color(0xFF8B5CF6)
      : const Color(0xFF6741C8);

  Color get yellow => isDark
      ? const Color(0xFFFFD60A)
      : const Color(0xFFE0A800);

  Color get textColor => Theme.of(context).colorScheme.onSurface;

  Color get mutedColor => Theme.of(context).colorScheme.onSurfaceVariant;

  Color get surfaceColor => Theme.of(context).colorScheme.surface;

  Color get borderColor => isDark
      ? const Color(0xFF26354D)
      : const Color(0xFFB9C5DA);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: error
            ? const Color(0xFFB3261E)
            : (isDark
                ? const Color(0xFF10251F)
                : const Color(0xFF176B45)),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  ({double previous, double current, double rate})? readInputs() {
    final previous = double.tryParse(previousController.text.trim());
    final current = double.tryParse(currentController.text.trim());
    final rate = double.tryParse(rateController.text.trim());

    if (previous == null || current == null || rate == null) {
      showMessage('Please enter valid numbers in all fields.', error: true);
      return null;
    }

    if (previous < 0 || current < 0 || rate < 0) {
      showMessage('Values cannot be negative.', error: true);
      return null;
    }

    if (current < previous) {
      showMessage(
        'Current reading cannot be less than previous reading.',
        error: true,
      );
      return null;
    }

    return (previous: previous, current: current, rate: rate);
  }

  void calculateUsage() {
    FocusScope.of(context).unfocus();

    if (previousController.text.trim().isEmpty ||
        currentController.text.trim().isEmpty ||
        rateController.text.trim().isEmpty) {
      showMessage('Please enter all readings.', error: true);
      return;
    }

    final values = readInputs();
    if (values == null) return;

    setState(() {
      units = values.current - values.previous;
      estimatedBill = units * values.rate;
    });
  }

  Future<void> saveReading() async {
    if (isSaving) return;

    FocusScope.of(context).unfocus();

    if (previousController.text.trim().isEmpty ||
        currentController.text.trim().isEmpty ||
        rateController.text.trim().isEmpty) {
      showMessage('Please enter all readings.', error: true);
      return;
    }

    final values = readInputs();
    if (values == null) return;

    final calculatedUnits = values.current - values.previous;
    final calculatedBill = calculatedUnits * values.rate;

    final reading = ElectricityReading(
      userId: widget.userId,
      previousReading: values.previous,
      currentReading: values.current,
      units: calculatedUnits,
      billAmount: calculatedBill,
      date: DateTime.now().toIso8601String(),
    );

    setState(() => isSaving = true);

    try {
      // Save the reading locally using SQLite only.
      await DatabaseService.instance.insertReading(reading);

      if (!mounted) return;

      setState(() {
        units = calculatedUnits;
        estimatedBill = calculatedBill;
      });

      showMessage('Reading saved successfully! ⚡');
    } catch (e) {
      if (!mounted) return;
      showMessage('Could not save reading. Please try again.', error: true);
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    previousController.dispose();
    currentController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Add Meter Reading',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Icon(
              Icons.bolt_rounded,
              color: yellow,
              size: 27,
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
                  painter: AddReadingEnergyPainter(
                    animationValue: _animationController.value,
                  ),
                ),
              ),
            ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildInputSection(
                    title: 'Previous Meter Reading',
                    subtitle: 'Enter your previous meter value',
                    controller: previousController,
                    hint: 'Example: 1250',
                    suffix: 'kWh',
                    icon: Icons.speed_rounded,
                  ),
                  const SizedBox(height: 18),
                  _buildInputSection(
                    title: 'Current Meter Reading',
                    subtitle: 'Enter your latest meter value',
                    controller: currentController,
                    hint: 'Example: 1435',
                    suffix: 'kWh',
                    icon: Icons.electric_meter_rounded,
                  ),
                  const SizedBox(height: 18),
                  _buildInputSection(
                    title: 'Electricity Tariff / Rate',
                    subtitle: 'Cost charged for each unit',
                    controller: rateController,
                    hint: 'Example: 7',
                    suffix: '/ unit',
                    prefix: '₹ ',
                    icon: Icons.currency_rupee_rounded,
                  ),
                  const SizedBox(height: 24),
                  _buildCalculateButton(),
                  const SizedBox(height: 22),
                  _buildResultCard(),
                  const SizedBox(height: 22),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF102C45), Color(0xFF17162F)]
              : const [Color(0xFFE1ECFF), Color(0xFFEDE5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          if (isDark)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final pulse = 0.94 +
                    math.sin(_animationController.value * math.pi * 2) * 0.06;
                return Transform.scale(scale: pulse, child: child);
              },
              child: _headerIcon(),
            )
          else
            _headerIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record Electricity Usage',
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF17213B),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter your meter readings and calculate your usage.',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.85)
                        : const Color(0xFF46536B),
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

  Widget _headerIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        gradient: LinearGradient(
          colors: [accent, purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.electric_meter_rounded,
        color: Colors.white,
        size: 29,
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String hint,
    required String suffix,
    required IconData icon,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: mutedColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          cursorColor: accent,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: mutedColor, fontSize: 14),
            prefixText: prefix,
            prefixStyle: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: mutedColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            prefixIcon: Icon(icon, color: accent),
            filled: true,
            fillColor: surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(color: borderColor.withValues(alpha: 0.8)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(color: accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: calculateUsage,
        icon: const Icon(Icons.calculate_rounded, size: 22),
        label: const Text(
          'CALCULATE USAGE',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF111E32), Color(0xFF1B1632)]
              : const [Color(0xFFFFFFFF), Color(0xFFEDE8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: purple.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: isDark ? 0.12 : 0.07),
            blurRadius: 22,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.insights_rounded, color: yellow, size: 22),
              const SizedBox(width: 9),
              Text(
                'Usage Summary',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _resultItem(
                  Icons.bolt_rounded,
                  'Units Used',
                  '${units.toStringAsFixed(1)} kWh',
                  accent,
                ),
              ),
              Container(
                width: 1,
                height: 65,
                color: borderColor.withValues(alpha: 0.7),
              ),
              Expanded(
                child: _resultItem(
                  Icons.currency_rupee_rounded,
                  'Estimated Bill',
                  '₹${estimatedBill.toStringAsFixed(2)}',
                  yellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultItem(
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 29),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: mutedColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isSaving ? null : saveReading,
        icon: isSaving
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_rounded, size: 22),
        label: Text(
          isSaving ? 'SAVING...' : 'SAVE READING',
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: purple, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}

class AddReadingEnergyPainter extends CustomPainter {
  final double animationValue;

  AddReadingEnergyPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00B7FF).withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(width * 0.18, height * 0.15),
          radius: width * 0.65,
        ),
      );

    canvas.drawCircle(
      Offset(width * 0.18, height * 0.15),
      width * 0.65,
      glowPaint,
    );

    final purplePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.14),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(width * 0.88, height * 0.68),
          radius: width * 0.7,
        ),
      );

    canvas.drawCircle(
      Offset(width * 0.88, height * 0.68),
      width * 0.7,
      purplePaint,
    );

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;

    for (double x = 0; x <= width; x += 42) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    for (double y = 0; y <= height; y += 42) {
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = const Color(0xFF00B7FF).withValues(alpha: 0.08);

    final path = Path();
    for (double x = 0; x <= width; x += 5) {
      final y = height * 0.70 +
          math.sin(
                (x / width) * math.pi * 5 + animationValue * math.pi * 2,
              ) *
              22;
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, wavePaint);

    for (int i = 0; i < 18; i++) {
      final seed = i * 17.31;
      final x = ((math.sin(seed) + 1) / 2) * width;
      final baseY = ((math.cos(seed * 0.7) + 1) / 2) * height;
      final y = (baseY + animationValue * height * 0.15 + i * 3) % height;
      final radius = 1.0 + ((math.sin(seed * 2) + 1) / 2) * 1.5;

      final particlePaint = Paint()
        ..color = (i.isEven
                ? const Color(0xFF00B7FF)
                : const Color(0xFF8B5CF6))
            .withValues(alpha: 0.25);

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant AddReadingEnergyPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}