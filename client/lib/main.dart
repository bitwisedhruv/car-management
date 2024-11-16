import 'package:client/core/theme/theme.dart';
import 'package:client/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightMode,
      // darkTheme: AppTheme.darkMode,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
