
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../services/database_service.dart';
import '../theme/theme_controller.dart';
import 'login_screen.dart';
import 'personal_information_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  double tariff = 7.0;
  bool isLoading = true;

  late String currentName;
  late String currentEmail;

  late final AnimationController _animationController;

  bool get isDark =>
      Theme.of(context).brightness == Brightness.dark;

  Color get textColor =>
      isDark ? Colors.white : const Color(0xFF17213B);

  Color get secondaryTextColor =>
      isDark ? Colors.white70 : const Color(0xFF46536B);

  Color get accentColor =>
      isDark ? const Color(0xFF00B7FF) : const Color(0xFF1769D2);

  Color get purpleColor =>
      isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6741C8);

  Color get cardColor =>
      isDark ? const Color(0xFF101827) : Colors.white;

  @override
  void initState() {
    super.initState();

    currentName = widget.userName;
    currentEmail = widget.userEmail;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 11),
    )..repeat();

    loadTariff();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // LOAD TARIFF FROM SQLITE

  Future<void> loadTariff() async {
    try {
      final savedTariff =
          await DatabaseService.instance.getTariff();

      if (!mounted) return;

      setState(() {
        tariff = savedTariff;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load tariff: $e')),
      );
    }
  }

  // PERSONAL INFORMATION

  Future<void> openPersonalInformationScreen() async {
    try {
      final user =
          await DatabaseHelper.instance.getUserByEmail(
        currentEmail,
      );

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User information could not be found.'),
          ),
        );
        return;
      }

      final result = await Navigator.of(context)
          .push<Map<String, String>>(
        MaterialPageRoute(
          builder: (_) => PersonalInformationScreen(
            userId: user['id'] as int,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information updated successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  void closeProfile() {
    Navigator.pop(
      context,
      {
        'name': currentName,
        'email': currentEmail,
      },
    );
  }

  // ELECTRICITY TARIFF

  Future<void> showTariffDialog() async {
    final controller = TextEditingController(
      text: tariff.toStringAsFixed(2),
    );

    String? errorText;

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dialogIsDark =
                Theme.of(context).brightness == Brightness.dark;

            final dialogTextColor = dialogIsDark
                ? Colors.white
                : const Color(0xFF17213B);

            return AlertDialog(
              title: const Text('Electricity Tariff'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the electricity cost per unit.',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: dialogTextColor),
                    decoration: InputDecoration(
                      labelText: 'Tariff per unit',
                      prefixText: '₹ ',
                      suffixText: '/ unit',
                      errorText: errorText,
                    ),
                    onChanged: (_) {
                      if (errorText != null) {
                        setDialogState(() => errorText = null);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final value =
                        double.tryParse(controller.text.trim());

                    if (value == null ||
                        !value.isFinite ||
                        value <= 0) {
                      setDialogState(() {
                        errorText = 'Enter a valid amount above zero.';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, value);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    try {
      await DatabaseService.instance.updateTariff(result);

      if (!mounted) return;

      setState(() {
        tariff = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tariff updated to ₹${result.toStringAsFixed(2)} per unit.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update tariff: $e')),
      );
    }
  }

  // BUILD PROFILE

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: closeProfile,
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ProfileScreenPainter(
                          _animationController.value,
                          isDark: isDark,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: backgroundColor.withValues(
                      alpha: isDark ? 0.72 : 0.25,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20, 10, 20, 30,
                  ),
                  child: Column(
                    children: [
                      _profileHeader(),
                      const SizedBox(height: 25),

                      _sectionTitle(
                        'ACCOUNT',
                        Icons.person_outline,
                      ),
                      const SizedBox(height: 12),

                      _profileOption(
                        icon: Icons.person_outline,
                        iconColor: accentColor,
                        title: 'Personal Information',
                        subtitle: 'View and update your information',
                        onTap: openPersonalInformationScreen,
                      ),
                      const SizedBox(height: 12),

                      _profileOption(
                        icon: Icons.email_outlined,
                        iconColor: purpleColor,
                        title: 'Email Address',
                        subtitle: currentEmail,
                        onTap: () {},
                      ),

                      const SizedBox(height: 25),

                      _sectionTitle('PREFERENCES', Icons.tune),
                      const SizedBox(height: 12),

                      _appearanceOption(),

                      const SizedBox(height: 12),

                      _profileOption(
                        icon: Icons.notifications_outlined,
                        iconColor: const Color(0xFFE6A817),
                        title: 'Notifications',
                        subtitle: 'Manage usage alerts and reminders',
                        onTap: () {
                          Navigator.pushNamed(context, '/alerts');
                        },
                      ),
                      const SizedBox(height: 12),

                      _profileOption(
                        icon: Icons.currency_rupee,
                        iconColor: isDark
                            ? const Color(0xFF00E5A0)
                            : const Color(0xFF087F5B),
                        title: 'Electricity Tariff',
                        subtitle:
                            'Current tariff: ₹${tariff.toStringAsFixed(2)} per unit',
                        onTap: showTariffDialog,
                      ),

                      const SizedBox(height: 25),

                      _sectionTitle('APPLICATION', Icons.apps_outlined),
                      const SizedBox(height: 12),

                      _profileOption(
                        icon: Icons.info_outline,
                        iconColor: accentColor,
                        title: 'About',
                        subtitle: 'Electricity Usage Tracker',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Electricity Usage Tracker',
                            applicationVersion: '1.0.0',
                            applicationIcon: Icon(
                              Icons.bolt,
                              color: isDark
                                  ? const Color(0xFFFFD60A)
                                  : const Color(0xFFE6A817),
                              size: 40,
                            ),
                            children: [
                              Text(
                                'A Flutter application for monitoring electricity consumption and estimating electricity bills.',
                                style: TextStyle(color: textColor),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      _profileOption(
                        icon: Icons.help_outline,
                        iconColor: purpleColor,
                        title: 'Help & Support',
                        subtitle: 'Get help using the application',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Help & Support coming soon'),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                      _logoutButton(),
                      const SizedBox(height: 25),

                      Text(
                        'ELECTRICITY USAGE TRACKER',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'VERSION 1.0.0',
                        style: TextStyle(
                          color: secondaryTextColor.withValues(alpha: 0.8),
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // PROFILE HEADER

  Widget _profileHeader() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final pulse =
            (math.sin(_animationController.value * math.pi * 2) + 1) / 2;

        final borderColor = accentColor.withValues(
          alpha: isDark ? 0.35 : 0.30,
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [
                      Color(0xFF101827),
                      Color(0xFF17132C),
                    ]
                  : const [
                      Color(0xFFFFFFFF),
                      Color(0xFFEAEFFF),
                    ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(
                  alpha: isDark ? 0.10 + pulse * 0.08 : 0.07,
                ),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: purpleColor.withValues(
                  alpha: isDark ? 0.08 + pulse * 0.06 : 0.04,
                ),
                blurRadius: 35,
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          purpleColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.25),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 55,
                    ),
                  ),
                  Positioned(
                    right: 7,
                    bottom: 8,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF00E5A0)
                            : const Color(0xFF087F5B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cardColor,
                          width: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Text(
                currentName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),

              Text(
                currentEmail,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 17),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt,
                      color: isDark
                          ? const Color(0xFFFFD60A)
                          : const Color(0xFFB87900),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'ENERGY MONITOR',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // APPEARANCE SELECTOR

  Widget _appearanceOption() {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, child) {
        final selectedMode = ThemeController.instance.themeMode;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: isDark ? 0.96 : 0.98),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: purpleColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      color: purpleColor,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appearance',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Choose your preferred theme',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _themeChoice(
                      mode: ThemeMode.dark,
                      title: 'Dark Cyber',
                      icon: Icons.dark_mode_rounded,
                      selected: selectedMode == ThemeMode.dark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _themeChoice(
                      mode: ThemeMode.light,
                      title: 'Premium Light',
                      icon: Icons.light_mode_rounded,
                      selected: selectedMode == ThemeMode.light,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Your selection is saved automatically.',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _themeChoice({
    required ThemeMode mode,
    required String title,
    required IconData icon,
    required bool selected,
  }) {
    final choiceColor =
        mode == ThemeMode.dark ? const Color(0xFF00B7FF) : purpleColor;

    return InkWell(
      onTap: () async {
        try {
          await ThemeController.instance.setTheme(mode);
        } catch (e) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not save theme preference: $e'),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? choiceColor.withValues(alpha: isDark ? 0.13 : 0.09)
              : (isDark
                  ? const Color(0xFF182337)
                  : const Color(0xFFF4F6FC)),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selected
                ? choiceColor
                : (isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : const Color(0xFFB9C5DA)),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: choiceColor, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: selected ? choiceColor : secondaryTextColor,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // SECTION TITLE

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(icon, color: accentColor, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }

  // PROFILE OPTION

  Widget _profileOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: isDark ? 0.94 : 0.98),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : const Color(0xFFB9C5DA),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 25),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LOGOUT

  Widget _logoutButton() {
    final logoutColor = const Color(0xFFE5485D);

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Logout'),
                content: const Text(
                  'Are you sure you want to logout?',
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text('Logout'),
                  ),
                ],
              );
            },
          );
        },
        icon: Icon(Icons.logout_rounded, color: logoutColor),
        label: Text(
          'Logout',
          style: TextStyle(
            color: isDark ? Colors.white : logoutColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: logoutColor.withValues(alpha: 0.5),
          ),
          backgroundColor: logoutColor.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

// ANIMATED PROFILE BACKGROUND

class ProfileScreenPainter extends CustomPainter {
  final double animation;
  final bool isDark;

  ProfileScreenPainter(
    this.animation, {
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final blue = isDark
        ? const Color(0xFF00B7FF)
        : const Color(0xFF1769D2);

    final purple = isDark
        ? const Color(0xFF8B5CF6)
        : const Color(0xFF6741C8);

    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.035)
        : const Color(0xFF6479B8).withValues(alpha: 0.09);

    final center = Offset(width * 0.78, height * 0.25);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animation * math.pi * 2);

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = purple.withValues(alpha: isDark ? 0.18 : 0.13);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: width * 0.95,
        height: width * 0.42,
      ),
      orbitPaint,
    );

    canvas.rotate(math.pi / 2.5);

    final orbitPaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = blue.withValues(alpha: isDark ? 0.13 : 0.12);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: width * 0.82,
        height: width * 0.30,
      ),
      orbitPaint2,
    );

    canvas.restore();

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          purple.withValues(alpha: isDark ? 0.12 : 0.08),
          purple.withValues(alpha: isDark ? 0.03 : 0.025),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(width * 0.82, height * 0.22),
          radius: width * 0.55,
        ),
      );

    canvas.drawCircle(
      Offset(width * 0.82, height * 0.22),
      width * 0.55,
      glowPaint,
    );

    // Background grid

    final gridPaint = Paint()
      ..strokeWidth = 0.5
      ..color = gridColor;

    const gridSize = 42.0;

    for (double x = 0; x <= width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    for (double y = 0; y <= height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Floating particles

    final particlePaint = Paint();

    for (int i = 0; i < 32; i++) {
      final seed = i * 1.731;

      final x = ((math.sin(seed * 3.7) + 1) / 2) * width;

      final baseY =
          ((math.cos(seed * 2.4) + 1) / 2) * height;

      final movement =
          math.sin(animation * math.pi * 2 + seed) * 18;

      final y = baseY + movement;

      final radius =
          1.0 + ((math.sin(seed) + 1) / 2) * 1.8;

      final alpha = isDark
          ? 0.10 +
              ((math.sin(animation * math.pi * 2 + seed) + 1) /
                      2) *
                  0.20
          : 0.10;

      particlePaint.color =
          (i % 2 == 0 ? blue : purple).withValues(alpha: alpha);

      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }

    // Moving energy line

    final path = Path();
    final waveY = height * 0.72;

    path.moveTo(0, waveY);

    for (double x = 0; x <= width; x += 8) {
      final y = waveY +
          math.sin(
                x * 0.018 + animation * math.pi * 4,
              ) *
              12;

      path.lineTo(x, y);
    }

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = blue.withValues(alpha: isDark ? 0.10 : 0.13);

    canvas.drawPath(path, wavePaint);

    // Energy nodes

    for (int i = 0; i < 4; i++) {
      final nodeX = width * (0.12 + i * 0.25);

      final nodeY = height *
          (0.48 +
              math.sin(animation * math.pi * 2 + i) * 0.035);

      final nodeGlow = Paint()
        ..color = blue.withValues(alpha: isDark ? 0.08 : 0.07);

      canvas.drawCircle(Offset(nodeX, nodeY), 14, nodeGlow);

      final nodePaint = Paint()
        ..color = blue.withValues(alpha: isDark ? 0.45 : 0.38);

      canvas.drawCircle(Offset(nodeX, nodeY), 2.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(
    covariant ProfileScreenPainter oldDelegate,
  ) {
    return oldDelegate.animation != animation ||
        oldDelegate.isDark != isDark;
  }
}