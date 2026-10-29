import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common.dart';
import 'controller/auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7F4), Color(0xFFFFF0F6), Color(0xFFF6E9FF)],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            final last = controller.lastAccount.value;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  ),
                ),
                // Logo JPG has an off-white background; blend it into the page.
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(AppConstants.logoAsset, height: 170),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Stories that stay with you',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                ),
                SizedBox(height: last != null ? 32 : 72),
                if (last != null) _LastAccountCard(account: last) else _Options(),
                const SizedBox(height: 24),
                _Terms(),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _LastAccountCard extends GetView<AuthController> {
  final Map account;

  const _LastAccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final name = account['name']?.toString() ?? '';
    final provider = account['provider']?.toString() ?? 'email';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.blushDeep,
            child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                style: const TextStyle(color: AppColors.plum, fontSize: 26, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            provider == 'email' ? account['email'].toString() : 'Signed in with $provider',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Obx(() => GradientButton(
                label: 'Continue',
                width: double.infinity,
                loading: controller.loadingProvider.value == provider,
                onTap: controller.continueLast,
              )),
          TextButton(
            onPressed: controller.useAnother,
            child: const Text('Use another account', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _Options extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    Widget button(String provider, IconData icon) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Obx(() {
            final loading = controller.loadingProvider.value == provider;
            return GestureDetector(
              onTap: loading ? null : () => controller.social(provider),
              child: Container(
                height: 50,
                decoration: BoxDecoration(gradient: AppColors.buttonGradient, borderRadius: BorderRadius.circular(25)),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    CircleAvatar(radius: 19, backgroundColor: Colors.white, child: Icon(icon, color: AppColors.primary)),
                    Expanded(
                      child: loading
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              ),
                            )
                          : Text('Sign in with $provider',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
            );
          }),
        );

    return Column(
      children: [
        button('Facebook', Icons.facebook_rounded),
        button('Google', Icons.g_mobiledata_rounded),
        button('Apple', Icons.apple_rounded),
        OutlinedButton.icon(
          onPressed: controller.email,
          icon: const Icon(Icons.mail_outline_rounded),
          label: const Text('Sign in with Email'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            foregroundColor: AppColors.plum,
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.blushDeep),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _Terms extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(() => Checkbox(
              value: controller.agreed.value,
              onChanged: (v) => controller.agreed.value = v ?? false,
              activeColor: AppColors.primary,
              shape: const CircleBorder(),
            )),
        Expanded(
          child: GestureDetector(
            onTap: controller.openTerms,
            child: const Text.rich(
              TextSpan(
                text: 'I have read and agree to the ',
                children: [
                  TextSpan(text: 'Terms of Use', style: TextStyle(color: AppColors.primary)),
                  TextSpan(text: ' and '),
                  TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary)),
                ],
              ),
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
