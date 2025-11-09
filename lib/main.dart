import 'package:flutter/material.dart';
import 'package:laundry_app/screens/splash/splash_screen.dart';
import 'package:laundry_app/theme/app_colors.dart';

void main() {
  runApp(LaundryApp());
}

class LaundryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laundry App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
    );
  }
}
