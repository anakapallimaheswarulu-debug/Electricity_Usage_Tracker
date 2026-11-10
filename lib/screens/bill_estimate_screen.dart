
import 'dart:math' as math;

import 'package:flutter/material.dart';

class BillEstimateScreen extends StatefulWidget {
  const BillEstimateScreen({super.key});

  @override
  State<BillEstimateScreen> createState() => _BillEstimateScreenState();
}

class _BillEstimateScreenState extends State<BillEstimateScreen>
    with SingleTickerProviderStateMixin {
  final previousController = TextEditingController();
  final currentController = TextEditingController();
  final tariffController = TextEditingController(text: '7');

  double units = 0;
  double bill = 0;

  late final AnimationController _animationController;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get background =>
      isDark ? const Color(0xFF070B14) : const Color(0xFFF4F6FC);

  Color get surface =>
      isDark ? const Color(0xFF101827) : Colors.white;

  Color get textColor =>
      isDark ? const Color(0xFFF5F7FF) : const Color(0xFF17213B);

  Color get secondaryText =>
      isDark ? const Color(0xFF9AA8BD) : const Color(0xFF46536B);

  Color get accent =>
      isDark ? const Color(0xFF00B7FF) : const Color(0xFF1769D2);

  Color get purple =>
      isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6741C8);

  Color get borderColor =>
      isDark ? const Color(0xFF26354D) : const Color(0xFFB9C5DA);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat();
  }

  void calculateBill() {
    final previous = double.tryParse(previousController.text);
    final current = double.tryParse(currentController.text);
    final tariff = double.tryParse(tariffController.text);

    if (previous == null ||
        current == null ||
        tariff == null ||
        previous < 0 ||
        current < 0 ||
        tariff < 0 ||
        previousController.text.trim().isEmpty ||
        currentController.text.trim().isEmpty ||
        tariffController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isDark ? const Color(0xFF24101A) : const Color(0xFFFFE8E8),
          content: Text(
            'Enter valid, non-negative readings and tariff.',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF9B1C1C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      return;
    }

    if (current < previous) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isDark ? const Color(0xFF24101A) : const Color(0xFFFFE8E8),
          content: Text(
            'Current reading cannot be less than previous reading.',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF9B1C1C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      units = current - previous;
      bill = units * tariff;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    previousController.dispose();
    currentController.dispose();
    tariffController.dispose();
    super.dispose();
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
          'Bill Estimate',
          style: TextStyle(
            color: textColor,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Icon(
              Icons.receipt_long_rounded,
              color: isDark ? const Color(0xFFFFD60A) : purple,
              size: 25,
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
                builder: (context, child) {
                  return CustomPaint(
                    painter: BillEstimateEnergyPainter(
                      animationValue: _animationController.value,
                    ),
                  );
                },
              ),
            ),
          if (isDark)
            Positioned.fill(
              child: Container(color: const Color(0xCC070B14)),
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
                  _inputField(
                    controller: previousController,
                    label: 'Previous Meter Reading',
                    hint: 'Example: 1250',
                    icon: Icons.speed_rounded,
                    suffix: 'kWh',
                  ),
                  const SizedBox(height: 18),
                  _inputField(
                    controller: currentController,
                    label: 'Current Meter Reading',
                    hint: 'Example: 1435',
                    icon: Icons.electric_meter_rounded,
                    suffix: 'kWh',
                  ),
                  const SizedBox(height: 18),
                  _inputField(
                    controller: tariffController,
                    label: 'Electricity Tariff',
                    hint: 'Example: 7',
                    icon: Icons.currency_rupee_rounded,
                    suffix: '/ unit',
                    prefix: '₹ ',
                  ),
                  const SizedBox(height: 24),
                  _buildCalculateButton(),
                  const SizedBox(height: 22),
                  if (units > 0 || bill > 0) _resultCard(),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
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
              ? const [Color(0xFF17132F), Color(0xFF10253D)]
              : const [Color(0xFFE6EEFF), Color(0xFFF0E9FF)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: purple.withValues(alpha: isDark ? 0.4 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: isDark ? 0.13 : 0.07),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [purple, accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimate Your Electricity Bill',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Calculate your expected bill using meter readings and tariff.',
                  style: TextStyle(
                    color: secondaryText,
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String suffix,
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
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
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
            hintStyle: TextStyle(color: secondaryText.withValues(alpha: 0.8), fontSize: 14),
            prefixText: prefix,
            prefixStyle: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            prefixIcon: Icon(icon, color: accent),
            filled: true,
            fillColor: surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(color: borderColor.withValues(alpha: 0.8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(17),
              borderSide: BorderSide(color: purple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 57,
      child: ElevatedButton.icon(
        onPressed: calculateBill,
        icon: const Icon(Icons.calculate_rounded, size: 23),
        label: const Text(
          'CALCULATE BILL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          elevation: isDark ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  Widget _resultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF111E32), Color(0xFF211637)]
              : const [Colors.white, Color(0xFFEAF1FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: purple.withValues(alpha: isDark ? 0.5 : 0.22)),
        boxShadow: [
          BoxShadow(
            color: purple.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            color: isDark ? const Color(0xFFFFD60A) : purple,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            'Estimated Bill',
            style: TextStyle(
              color: secondaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '₹${bill.toStringAsFixed(2)}',
            style: TextStyle(
              color: textColor,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Divider(color: borderColor),
          const SizedBox(height: 15),
          _resultRow('Units Consumed', '${units.toStringAsFixed(2)} kWh',
              Icons.bolt_rounded, accent),
          const SizedBox(height: 14),
          _resultRow('Tariff', '₹${tariffController.text} / unit',
              Icons.currency_rupee_rounded,
              isDark ? const Color(0xFFFFD60A) : purple),
        ],
      ),
    );
  }

  Widget _resultRow(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: accent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is an estimated bill. The actual electricity bill may vary depending on your electricity provider and applicable charges.',
              style: TextStyle(
                color: secondaryText,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BillEstimateEnergyPainter extends CustomPainter {
  final double animationValue;

  BillEstimateEnergyPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final purpleGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6).withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(width * 0.86, height * 0.18),
          radius: width * 0.7,
        ),
      );

    canvas.drawCircle(Offset(width * 0.86, height * 0.18), width * 0.7, purpleGlow);

    final blueGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00B7FF).withValues(alpha: 0.17),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(width * 0.12, height * 0.78),
          radius: width * 0.65,
        ),
      );

    canvas.drawCircle(Offset(width * 0.12, height * 0.78), width * 0.65, blueGlow);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.05);

    for (int i = -5; i < 15; i++) {
      final x = i * 55.0 + animationValue * 55;
      canvas.drawLine(Offset(x, 0), Offset(x - height * 0.35, height), linePaint);
    }

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFF00B7FF).withValues(alpha: 0.09);

    final wavePath = Path();
    for (double x = 0; x <= width; x += 5) {
      final normalized = x / width;
      final y = height * 0.60 +
          math.sin(normalized * math.pi * 4 + animationValue * math.pi * 2) * 24;
      if (x == 0) {
        wavePath.moveTo(x, y);
      } else {
        wavePath.lineTo(x, y);
      }
    }
    canvas.drawPath(wavePath, wavePaint);

    final secondWavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.08);

    final secondPath = Path();
    for (double x = 0; x <= width; x += 5) {
      final normalized = x / width;
      final y = height * 0.78 +
          math.sin(normalized * math.pi * 5 - animationValue * math.pi * 2) * 30;
      if (x == 0) {
        secondPath.moveTo(x, y);
      } else {
        secondPath.lineTo(x, y);
      }
    }
    canvas.drawPath(secondPath, secondWavePaint);

    for (int i = 0; i < 26; i++) {
      final seed = i * 13.47;
      final x = ((math.sin(seed) + 1) / 2) * width;
      final baseY = ((math.cos(seed * 0.61) + 1) / 2) * height;
      final y = (baseY + animationValue * height * 0.12 + i * 2.7) % height;
      final radius = 0.8 + ((math.sin(seed * 1.7) + 1) / 2) * 1.6;
      final paint = Paint()
        ..color = (i % 2 == 0
                ? const Color(0xFF8B5CF6)
                : const Color(0xFF00B7FF))
            .withValues(alpha: 0.23);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    for (int i = 0; i < 3; i++) {
      final x = width * (0.20 + i * 0.30);
      final y = height *
          (0.28 + math.sin(animationValue * math.pi * 2 + i * 1.5) * 0.07);

      final nodePaint = Paint()
        ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.17);
      canvas.drawCircle(Offset(x, y), 4, nodePaint);

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.08);

      canvas.drawCircle(
        Offset(x, y),
        11 + math.sin(animationValue * math.pi * 2 + i) * 3,
        ringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BillEstimateEnergyPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}