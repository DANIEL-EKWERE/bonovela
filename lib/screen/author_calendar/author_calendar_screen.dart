import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import 'controller/author_calendar_controller.dart';

class AuthorCalendarScreen extends GetView<AuthorCalendarController> {
  const AuthorCalendarScreen({super.key});

  static const _months = [
    'Jan.',
    'Feb.',
    'Mar.',
    'Apr.',
    'May',
    'June',
    'July',
    'Aug.',
    'Sept.',
    'Oct.',
    'Nov.',
    'Dec.',
  ];
  static const _weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: const Icon(AppIcons.arrowLeft)),
        title: const Text('Update Calendar'),
      ),
      body: Obx(() {
        final story = controller.story;
        if (story == null) {
          return const EmptyState(icon: AppIcons.calendar, message: 'Publish chapters to see your update calendar.');
        }
        final m = controller.month.value;
        final words = controller.wordsByDay;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _Dropdown(label: story.displayTitle, onTap: () => _pickStory(context)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Dropdown(
                    label: '${m.year}-${m.month.toString().padLeft(2, '0')}',
                    onTap: () => _pickMonth(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: Fmt.thousands(controller.wordsThisMonth),
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' words updated this month'),
                ],
              ),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final d in _weekdays)
                  Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.9,
              children: [
                for (var i = 0; i < controller.firstWeekday; i++) const SizedBox.shrink(),
                for (var day = 1; day <= controller.daysInMonth; day++)
                  _DayCell(day: day, words: words[day], future: controller.isFuture(day)),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                _Legend(color: AppColors.error, label: 'Not update'),
                SizedBox(width: 20),
                _Legend(color: AppColors.success, label: 'Update'),
              ],
            ),
          ],
        );
      }),
    );
  }

  void _pickStory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final s in controller.stories)
              ListTile(
                title: Text(
                  s.displayTitle,
                  style: TextStyle(color: controller.story?.id == s.id ? AppColors.primary : null),
                ),
                onTap: () {
                  controller.selectStory(s.id);
                  Get.back();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _pickMonth(BuildContext context) {
    final year = controller.month.value.year.obs;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => year.value--,
                      icon: const Icon(AppIcons.back, color: AppColors.primary, size: 18),
                    ),
                    Text('${year.value}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    IconButton(
                      onPressed: () => year.value++,
                      icon: const Icon(AppIcons.chevronRight, color: AppColors.primary, size: 18),
                    ),
                  ],
                ),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  childAspectRatio: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 0; i < 12; i++)
                      TextButton(
                        onPressed: () {
                          controller.selectMonth(year.value, i + 1);
                          Get.back();
                        },
                        child: Text(
                          _months[i],
                          style: TextStyle(
                            color: controller.month.value.year == year.value && controller.month.value.month == i + 1
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _Dropdown({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
          const Icon(AppIcons.caretDown, size: 16),
        ],
      ),
    ),
  );
}

class _DayCell extends StatelessWidget {
  final int day;
  final int? words;
  final bool future;

  const _DayCell({required this.day, required this.words, required this.future});

  @override
  Widget build(BuildContext context) {
    final updated = words != null;
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: updated ? AppColors.success : AppColors.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              color: updated ? Colors.white : (future ? AppColors.textHint : AppColors.textPrimary),
              fontWeight: updated ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          if (updated)
            Text(Fmt.compact(words!), style: const TextStyle(color: Colors.white, fontSize: 9))
          else if (!future)
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: AppColors.textSecondary)),
    ],
  );
}
