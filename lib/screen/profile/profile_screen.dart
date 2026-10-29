import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: HeaderBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              _UserHeader(),
              const SizedBox(height: 12),
              _WalletCard(),
              const SizedBox(height: 12),
              _SubscriptionBanner(),
              const SizedBox(height: 12),
              _Menu(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserHeader extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.user.value;
      return Column(
        children: [
          InkWell(
            onTap: controller.openHeader,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: user == null ? AppColors.blushDeep : AppColors.plum,
                  child: user == null
                      ? const Icon(Icons.person_rounded, color: Colors.white, size: 32)
                      : Text(user.initial,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user?.name ?? 'Sign in / Sign up',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (controller.isPlus) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.diamond_rounded, color: AppColors.primary, size: 18),
                          ],
                        ],
                      ),
                      Text(
                        user == null ? 'Sync your library and wallet across devices' : 'ID: ${user.id}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
              ],
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                _Stat(value: user.followers, label: 'Followers', onTap: () => controller.open(AppRoutes.followList, arguments: 0)),
                Container(width: 1, height: 24, color: AppColors.divider),
                _Stat(
                  value: controller.following.length,
                  label: 'Following',
                  onTap: () => controller.open(AppRoutes.followList, arguments: 1),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  final VoidCallback onTap;

  const _Stat({required this.value, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Text('$value', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

class _WalletCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    Widget balance(String kind, RxInt value, String label) => Row(
          children: [
            CurrencyIcon(kind, size: 22),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text('${value.value}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        );

    return WhiteCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => controller.open(AppRoutes.wallet),
            child: const Row(
              children: [
                Text('My Wallet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                Spacer(),
                Text('Detail', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textHint),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              balance('coins', controller.coins, 'Coins'),
              const SizedBox(width: 24),
              balance('bonus', controller.bonus, 'Bonus'),
              const Spacer(),
              GradientButton(
                label: 'TOP UP',
                height: 38,
                fontSize: 14,
                onTap: () => controller.openAuthed(AppRoutes.topUp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubscriptionBanner extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.open(AppRoutes.subscription),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.plum, AppColors.plumLight]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Obx(() {
          controller.user.value; // rebuild on login/logout
          final plus = controller.isPlus;
          return Row(
            children: [
              const Icon(Icons.diamond_rounded, color: AppColors.blushDeep),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plus ? 'Bonovela Plus · Active' : 'Subscription Center',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    const Text('Unlimited reading of all short stories',
                        style: TextStyle(color: AppColors.blushDeep, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Text(plus ? 'VIEW' : 'GO',
                    style: const TextStyle(color: AppColors.plum, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Menu extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: Obx(() => Column(
            children: [
              MenuTile(
                icon: Icons.mail_outline_rounded,
                title: 'Inbox',
                trailing: controller.unread > 0 ? _Badge(controller.unread) : null,
                onTap: () => controller.open(AppRoutes.inbox),
              ),
              MenuTile(
                icon: Icons.edit_note_rounded,
                title: 'Author Center',
                onTap: () => controller.openAuthed(AppRoutes.authorCenter),
              ),
              MenuTile(
                icon: Icons.card_giftcard_rounded,
                title: 'Earn Rewards',
                trailing: const Icon(Icons.redeem_rounded, color: AppColors.primary, size: 20),
                onTap: () => controller.open(AppRoutes.rewards),
              ),
              MenuTile(
                icon: Icons.swap_horiz_rounded,
                title: 'Exchange',
                onTap: () => controller.openAuthed(AppRoutes.exchange),
              ),
              MenuTile(
                icon: Icons.diamond_outlined,
                iconColor: const Color(0xFF3FB8E6),
                title: 'Gems',
                value: '${controller.gems.value}',
                onTap: () => controller.open(AppRoutes.gems),
              ),
              MenuTile(icon: Icons.history_rounded, title: 'Viewed', onTap: controller.openViewed),
              MenuTile(
                icon: Icons.headset_mic_outlined,
                title: 'Online Service',
                onTap: () => controller.open(AppRoutes.onlineService),
              ),
              MenuTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => controller.open(AppRoutes.settings),
              ),
            ],
          )),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;

  const _Badge(this.count);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(10)),
        child: Text(count > 99 ? '99+' : '$count', style: const TextStyle(color: Colors.white, fontSize: 11)),
      );
}
