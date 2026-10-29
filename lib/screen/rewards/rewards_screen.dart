import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/rewards_controller.dart';
import 'models/reward_task.dart';

class RewardsScreen extends GetView<RewardsController> {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Earn Rewards',
      actions: [
        IconButton(
          onPressed: () => Get.defaultDialog(
            title: 'Rewards rules',
            middleText: 'Bonus from check-ins and tasks expires after 3 days. Daily tasks reset at midnight. '
                'Bonus is spent before coins when unlocking chapters.',
            textConfirm: 'OK',
            confirmTextColor: Colors.white,
            buttonColor: AppColors.primary,
            onConfirm: Get.back,
          ),
          icon: const Icon(Icons.help_outline_rounded),
        ),
      ],
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _CheckInHeader(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _TaskSection(title: 'General Benefits', tasks: RewardTask.general),
                _TaskSection(title: 'Follow & Invite', tasks: RewardTask.social),
                _ReadingSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInHeader extends GetView<RewardsController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.blushDeep, AppColors.surface],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Obx(() {
        controller.streak.value; // rebuild after check-in
        final streak = controller.activeStreak;
        final today = controller.checkedInToday;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CurrencyIcon('bonus'),
                const SizedBox(width: 6),
                Text('My Bonus ${controller.bonus.value}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            WhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Check-In Streak: $streak Day${streak == 1 ? '' : 's'}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: _DaySlot(
                            day: i + 1,
                            reward: controller.checkInRewards[i],
                            done: i < streak,
                            next: !today && i == streak,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GradientButton(
                      label: today ? 'Checked in today' : 'Check in',
                      width: 200,
                      onTap: today ? null : controller.checkIn,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _DaySlot extends StatelessWidget {
  final int day;
  final int reward;
  final bool done;
  final bool next;

  const _DaySlot({required this.day, required this.reward, required this.done, required this.next});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.primary : (next ? AppColors.blushDeep : AppColors.blush),
            border: next ? Border.all(color: AppColors.primary, width: 1.5) : null,
          ),
          child: Icon(done ? Icons.check_rounded : Icons.stars_rounded,
              color: done ? Colors.white : AppColors.primary, size: 18),
        ),
        const SizedBox(height: 4),
        Text('+$reward', style: const TextStyle(fontSize: 12)),
        Text('DAY $day', style: const TextStyle(fontSize: 9, color: AppColors.textHint)),
      ],
    );
  }
}

class _TaskSection extends GetView<RewardsController> {
  final String title;
  final List<RewardTask> tasks;

  const _TaskSection({required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(title,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
          ),
          for (final t in tasks)
            Obx(() {
              final running = controller.runningTask.value == t.key;
              final done = controller.isDone(t);
              final max = controller.max(t);
              return ListTile(
                leading: Icon(t.icon, color: AppColors.plumLight),
                title: Row(
                  children: [
                    const CurrencyIcon('bonus', size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text('${t.bonus} Bonus${max > 1 ? ' (${controller.progress(t)}/$max)' : ''}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ],
                ),
                subtitle: Text('${t.title} · ${t.description}', style: const TextStyle(fontSize: 12)),
                trailing: running
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : PillButton(
                        label: done ? 'Done' : (t.key == 'video' ? 'Watch' : 'Go'),
                        onTap: done ? null : () => controller.doTask(t),
                      ),
              );
            }),
        ],
      ),
    );
  }
}

class _ReadingSection extends GetView<RewardsController> {
  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Obx(() {
        final minutes = controller.readingMinutes.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Daily Reading Rewards',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  Text('Today: $minutes min', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            for (final m in ReadingMilestone.all)
              ListTile(
                leading: const Icon(Icons.menu_book_rounded, color: AppColors.plumLight),
                title: Row(
                  children: [
                    const CurrencyIcon('bonus', size: 16),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text('${m.bonus} Bonus',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                    if (m.gems > 0) ...[
                      const SizedBox(width: 8),
                      const CurrencyIcon('gems', size: 16),
                      Text(' +${m.gems}', style: const TextStyle(fontSize: 13)),
                    ],
                  ],
                ),
                subtitle: Text('Read for ${m.minutes} mins · ${minutes.clamp(0, m.minutes)} / ${m.minutes}',
                    style: const TextStyle(fontSize: 12)),
                trailing: controller.milestoneClaimed(m)
                    ? const PillButton(label: 'Done')
                    : PillButton(
                        label: minutes >= m.minutes ? 'Claim' : 'Go',
                        filled: minutes >= m.minutes,
                        onTap: minutes >= m.minutes ? () => controller.claimReading(m) : () => Get.back(),
                      ),
              ),
          ],
        );
      }),
    );
  }
}
