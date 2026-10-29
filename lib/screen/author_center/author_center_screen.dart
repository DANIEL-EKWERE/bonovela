import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/common.dart';
import '../../widgets/ui_kit.dart';
import 'controller/author_center_controller.dart';

class AuthorCenterScreen extends GetView<AuthorCenterController> {
  const AuthorCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: 'Author Center',
      body: Obx(() => controller.isAuthor ? _Dashboard() : _Intro()),
    );
  }
}

class _Intro extends GetView<AuthorCenterController> {
  @override
  Widget build(BuildContext context) {
    const perks = [
      (Icons.payments_outlined, 'Earn from every unlock', 'Get a share of coins spent on your chapters.'),
      (Icons.campaign_outlined, 'Get featured', 'Top new stories are promoted on Discover.'),
      (Icons.insights_outlined, 'Track your readers', 'See reads, followers and reviews in one place.'),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Icon(Icons.edit_note_rounded, size: 72, color: AppColors.primary),
        const SizedBox(height: 8),
        const Text('Write on Bonovela',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Share your stories with readers who can\'t wait for the next chapter.',
            textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        for (final (icon, title, body) in perks)
          WhiteCard(
            child: Row(
              children: [
                Icon(icon, color: AppColors.plumLight, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        GradientButton(label: 'Become an author', onTap: controller.becomeAuthor),
      ],
    );
  }
}

class _Dashboard extends GetView<AuthorCenterController> {
  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final user = controller.user.value!;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        WhiteCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.plum,
                child: Text(user.initial, style: const TextStyle(color: Colors.white, fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(user.penName.isNotEmpty ? user.penName : user.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
              ),
            ],
          ),
        ),
        WhiteCard(
          child: Row(
            children: [
              _Stat('${controller.drafts.length}', 'Stories'),
              const _Stat('0', 'Reads'),
              const _Stat('0', 'Followers'),
              const _Stat('0', 'Earned'),
            ],
          ),
        ),
        Row(
          children: [
            const Expanded(child: Text('My works', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
            TextButton.icon(
              onPressed: () => _showCreate(context),
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              label: const Text('New story', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        if (controller.drafts.isEmpty)
          const SizedBox(
            height: 220,
            child: EmptyState(icon: Icons.auto_stories_outlined, message: 'No stories yet. Start your first one!'),
          ),
        for (final d in controller.drafts)
          WhiteCard(
            padding: EdgeInsets.zero,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${d.genre} · Draft · ${d.chapters} chapters · ${Fmt.date(d.updatedAt)}',
                  style: const TextStyle(fontSize: 12)),
              trailing: IconButton(
                onPressed: () => controller.deleteDraft(d),
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textHint),
              ),
              onTap: () => toast('Chapter editor', 'Writing chapters comes in the next build.'),
            ),
          ),
      ],
    );
  }

  void _showCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New story', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(controller: controller.titleController, decoration: const InputDecoration(hintText: 'Title')),
            const SizedBox(height: 12),
            Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    for (final g in AppConstants.genres)
                      ChoiceChip(
                        label: Text(g),
                        selected: controller.genre.value == g,
                        onSelected: (_) => controller.genre.value = g,
                        selectedColor: AppColors.blush,
                        showCheckmark: false,
                      ),
                  ],
                )),
            const SizedBox(height: 12),
            TextField(
              controller: controller.synopsisController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Synopsis',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Save draft',
              width: double.infinity,
              onTap: () {
                if (controller.createStory()) Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
}
