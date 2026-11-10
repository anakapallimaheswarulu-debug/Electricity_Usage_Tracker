
import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ElectricityUsageTracker());
}

class ElectricityUsageTracker extends StatefulWidget {
  const ElectricityUsageTracker({super.key});

  @override
  State<ElectricityUsageTracker> createState() =>
      _ElectricityUsageTrackerState();
}

class _ElectricityUsageTrackerState
    extends State<ElectricityUsageTracker> {
  final ThemeController _themeController = ThemeController.instance;

  late final Future<void> _themeLoadFuture;

  @override
  void initState() {
    super.initState();
    _themeLoadFuture = _themeController.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Electricity Usage Tracker',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeController.themeMode,
          home: FutureBuilder<void>(
            future: _themeLoadFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return const SplashScreen();
            },
          ),
        );
      },
    );
  }
}