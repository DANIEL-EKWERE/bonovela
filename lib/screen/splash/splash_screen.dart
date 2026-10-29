import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'controller/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Matches the logo's off-white background so the JPG edges disappear.
      backgroundColor: const Color(0xFFFFF7F4),
      body: Column(
        children: [
          const Spacer(flex: 3),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
            child: Image.asset(AppConstants.logoAsset, width: 240),
          ),
          const Spacer(flex: 2),
          const Text(
            'Stories that stay with you',
            style: TextStyle(color: AppColors.plum, fontSize: 14, letterSpacing: 0.4),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
