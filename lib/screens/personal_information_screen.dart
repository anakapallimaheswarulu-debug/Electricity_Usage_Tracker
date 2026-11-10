import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../database/database_helper.dart';

class PersonalInformationScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String userEmail;

  const PersonalInformationScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController nameController;
  late final TextEditingController emailController;

  bool isSaving = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.userName,
    );

    emailController = TextEditingController(
      text: widget.userEmail,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> saveInformation() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF24101A),
          content: Text(
            'Please fill in all fields.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      return;
    }

    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF24101A),
          content: Text(
            'Please enter a valid email address.',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Update name
      if (name != widget.userName) {
        final rowsUpdated =
            await DatabaseHelper.instance.updateUserName(
          id: widget.userId,
          name: name,
        );

        debugPrint(
          'NAME UPDATE - userId: ${widget.userId}',
        );

        debugPrint(
          'NAME UPDATE - rowsUpdated: $rowsUpdated',
        );

        final updatedUser =
            await DatabaseHelper.instance.getUserById(
          widget.userId,
        );

        debugPrint(
          'NAME UPDATE - database name: '
          '${updatedUser?['name']}',
        );
      }

      // Update email
      if (email != widget.userEmail) {
        final emailExists =
            await DatabaseHelper.instance.emailExists(email);

        if (emailExists) {
          if (!mounted) return;

          setState(() {
            isSaving = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF24101A),
              content: Text(
                'This email is already registered.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );

          return;
        }

        final rowsUpdated =
            await DatabaseHelper.instance.updateUserEmail(
          id: widget.userId,
          email: email,
        );

        debugPrint(
          'EMAIL UPDATE - userId: ${widget.userId}',
        );

        debugPrint(
          'EMAIL UPDATE - rowsUpdated: $rowsUpdated',
        );

        final updatedUser =
            await DatabaseHelper.instance.getUserById(
          widget.userId,
        );

        debugPrint(
          'EMAIL UPDATE - database email: '
          '${updatedUser?['email']}',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF102B24),
          content: Text(
            'Personal information updated successfully!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      Navigator.pop(
        context,
        {
          'name': name,
          'email': email,
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF24101A),
          content: Text(
            'Update failed: $e',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      debugPrint(
        'PERSONAL INFORMATION UPDATE ERROR: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle:
                    _animationController.value *
                    math.pi *
                    2,
                child: child,
              );
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 18),
              child: Icon(
                Icons.manage_accounts_rounded,
                color: Color(0xFF00B7FF),
                size: 26,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ProfileEnergyPainter(
                    animationValue:
                        _animationController.value,
                  ),
                );
              },
            ),
          ),

          Positioned.fill(
            child: Container(
              color: const Color(0xDD070B14),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                18,
                12,
                18,
                30,
              ),
              child: Column(
                children: [
                  _buildProfileHeader(),

                  const SizedBox(height: 24),

                  _buildSectionTitle(
                    'ACCOUNT DETAILS',
                  ),

                  const SizedBox(height: 12),

                  _buildNameField(),

                  const SizedBox(height: 18),

                  _buildEmailField(),

                  const SizedBox(height: 26),

                  _buildSaveButton(),

                  const SizedBox(height: 22),

                  _buildSecurityCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PROFILE HEADER
  // ------------------------------------------------------------

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF101F38),
            Color(0xFF211637),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF00B7FF)
              .withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B7FF)
                .withValues(alpha: 0.08),
            blurRadius: 28,
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final pulse =
                  0.94 +
                  math.sin(
                        _animationController.value *
                            math.pi *
                            2,
                      ) *
                      0.06;

              return Transform.scale(
                scale: pulse,
                child: child,
              );
            },
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF00B7FF),
                    Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00B7FF)
                        .withValues(alpha: 0.24),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 45,
              ),
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Your Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Update your personal information',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF00B7FF)
                  .withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00B7FF)
                    .withValues(alpha: 0.20),
              ),
            ),
            child: const Text(
              'ACCOUNT SETTINGS',
              style: TextStyle(
                color: Color(0xFF00B7FF),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6),
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // NAME FIELD
  // ------------------------------------------------------------

  Widget _buildNameField() {
    return _buildInputContainer(
      icon: Icons.person_outline_rounded,
      label: 'Full Name',
      child: TextField(
        controller: nameController,
        textCapitalization:
            TextCapitalization.words,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: const Color(0xFF00B7FF),
        decoration: const InputDecoration(
          hintText: 'Enter your full name',
          hintStyle: TextStyle(
            color: Color(0xFFB5C0D2),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // EMAIL FIELD
  // ------------------------------------------------------------

  Widget _buildEmailField() {
    return _buildInputContainer(
      icon: Icons.email_outlined,
      label: 'Email Address',
      child: TextField(
        controller: emailController,
        keyboardType:
            TextInputType.emailAddress,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: const Color(0xFF00B7FF),
        decoration: const InputDecoration(
          hintText: 'Enter your email address',
          hintStyle: TextStyle(
            color: Color(0xFFB5C0D2),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // INPUT CONTAINER
  // ------------------------------------------------------------

  Widget _buildInputContainer({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF00B7FF),
              size: 19,
            ),

            const SizedBox(width: 8),

            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF101827),
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFF26354D)
                  .withValues(alpha: 0.9),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B7FF)
                    .withValues(alpha: 0.045),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 4),

              // IMPORTANT:
              // Expanded gives the TextField proper width.
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // SAVE BUTTON
  // ------------------------------------------------------------

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 57,
      child: ElevatedButton.icon(
        onPressed:
            isSaving ? null : saveInformation,
        icon: isSaving
            ? const SizedBox(
                width: 21,
                height: 21,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.save_rounded,
                size: 22,
              ),
        label: Text(
          isSaving
              ? 'SAVING...'
              : 'SAVE CHANGES',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF8B5CF6),
          disabledBackgroundColor:
              const Color(0xFF403A50),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SECURITY CARD
  // ------------------------------------------------------------

  Widget _buildSecurityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF101827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B5CF6)
              .withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(13),
              color: const Color(0xFF8B5CF6)
                  .withValues(alpha: 0.10),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFF8B5CF6),
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Your updated information is stored securely in the app database.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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
}

// ============================================================
// ANIMATED BACKGROUND
// ============================================================

class ProfileEnergyPainter extends CustomPainter {
  final double animationValue;

  ProfileEnergyPainter({
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // ----------------------------------------------------------
    // BLUE GLOW
    // ----------------------------------------------------------

    final blueGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00B7FF)
              .withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            width * 0.08,
            height * 0.16,
          ),
          radius: width * 0.65,
        ),
      );

    canvas.drawCircle(
      Offset(
        width * 0.08,
        height * 0.16,
      ),
      width * 0.65,
      blueGlow,
    );

    // ----------------------------------------------------------
    // PURPLE GLOW
    // ----------------------------------------------------------

    final purpleGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8B5CF6)
              .withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(
            width * 0.90,
            height * 0.82,
          ),
          radius: width * 0.62,
        ),
      );

    canvas.drawCircle(
      Offset(
        width * 0.90,
        height * 0.82,
      ),
      width * 0.62,
      purpleGlow,
    );

    // ----------------------------------------------------------
    // HORIZONTAL ENERGY LINES
    // ----------------------------------------------------------

    final dataPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF00B7FF)
          .withValues(alpha: 0.045);

    for (int i = 0; i < 9; i++) {
      final y =
          height *
          (0.10 + i * 0.105);

      final shift =
          animationValue *
          width *
          0.30;

      canvas.drawLine(
        Offset(
          -width * 0.2 + shift,
          y,
        ),
        Offset(
          width * 0.8 + shift,
          y,
        ),
        dataPaint,
      );
    }

    // ----------------------------------------------------------
    // FLOATING PARTICLES
    // ----------------------------------------------------------

    for (int i = 0; i < 28; i++) {
      final seed = i * 15.73;

      final x =
          ((math.sin(seed) + 1) / 2) *
          width;

      final baseY =
          ((math.cos(seed * 0.67) + 1) / 2) *
          height;

      final y =
          (baseY +
                  animationValue *
                      height *
                      0.08 +
                  i * 2.1) %
              height;

      final radius =
          0.7 +
          ((math.sin(seed * 1.8) + 1) / 2) *
              1.4;

      final particleColor =
          i % 2 == 0
              ? const Color(0xFF00B7FF)
              : const Color(0xFF8B5CF6);

      final particlePaint = Paint()
        ..color = particleColor
            .withValues(alpha: 0.18);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        particlePaint,
      );
    }

    // ----------------------------------------------------------
    // ENERGY NODES
    // ----------------------------------------------------------

    for (int i = 0; i < 4; i++) {
      final x =
          width *
          (0.15 + i * 0.25);

      final y =
          height *
          (0.32 +
              math.sin(
                    animationValue *
                            math.pi *
                            2 +
                        i,
                  ) *
                  0.05);

      final nodePaint = Paint()
        ..color = const Color(0xFF00B7FF)
            .withValues(alpha: 0.15);

      canvas.drawCircle(
        Offset(x, y),
        3.5,
        nodePaint,
      );

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF00B7FF)
            .withValues(alpha: 0.07);

      canvas.drawCircle(
        Offset(x, y),
        10 +
            math.sin(
                  animationValue *
                          math.pi *
                          2 +
                      i,
                ) *
                2.5,
        ringPaint,
      );
    }

    // ----------------------------------------------------------
    // MOVING SIGNAL DOT
    // ----------------------------------------------------------

    final signalX =
        (animationValue *
                width *
                1.3) %
            (width + 80) -
        40;

    final signalPaint = Paint()
      ..color = const Color(0xFF00B7FF)
          .withValues(alpha: 0.22);

    canvas.drawCircle(
      Offset(
        signalX,
        height * 0.60,
      ),
      3,
      signalPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant ProfileEnergyPainter oldDelegate,
  ) {
    return oldDelegate.animationValue !=
        animationValue;
  }
}