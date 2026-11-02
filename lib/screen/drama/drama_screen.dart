import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../widgets/common.dart';
import 'controller/drama_controller.dart';

class DramaScreen extends GetView<DramaController> {
  const DramaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeaderBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text('Drama', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primaryLight, AppColors.plumLight],
                            ),
                          ),
                          child: const Icon(AppIcons.dramaFill, size: 56, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(12)),
                          child: const Text(
                            'COMING SOON',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your favourite stories, now as short dramas',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bite-sized episodes you can watch in minutes. We\'re putting the finishing touches on it.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 28),
                        Obx(
                          () => controller.notify.value
                              ? OutlinedButton.icon(
                                  onPressed: controller.toggleNotify,
                                  icon: const Icon(AppIcons.check, size: 18),
                                  label: const Text('You\'ll be notified'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(220, 48),
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                    shape: const StadiumBorder(),
                                  ),
                                )
                              : GradientButton(label: 'Notify me', width: 220, onTap: controller.toggleNotify),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
