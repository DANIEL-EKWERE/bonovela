import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import 'controller/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF4F8), Color(0xFFF6E9FF), Color(0xFFFFEAF2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: controller.skip,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
                    label: const Text('Skip', style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
                  ),
                ),
                const Spacer(flex: 2),
                const Text('Choose a type',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                const Text('We\'ll fill your library with stories you\'ll love.',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                _TypeCard(
                  label: 'Female novels',
                  icon: Icons.face_3_rounded,
                  colors: const [AppColors.primaryLight, AppColors.primary],
                  onTap: () => controller.choose('female'),
                ),
                const SizedBox(height: 18),
                _TypeCard(
                  label: 'Male novels',
                  icon: Icons.face_6_rounded,
                  colors: const [Color(0xFF8FA8FF), Color(0xFF6C7CF0)],
                  onTap: () => controller.choose('male'),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _TypeCard({required this.label, required this.icon, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: colors.last.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: 12,
              bottom: -14,
              child: Icon(icon, size: 104, color: Colors.white.withValues(alpha: 0.85)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(label,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
