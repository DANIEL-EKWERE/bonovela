import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_icons.dart';
import '../../core/data/author_data.dart';
import '../../widgets/author_cover.dart';
import '../../widgets/common.dart';
import 'controller/story_form_controller.dart';
import 'widgets/story_form_sheets.dart';

class StoryFormScreen extends GetView<StoryFormController> {
  const StoryFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        // Back steps through the form before leaving it.
        canPop: controller.step.value == 0,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.back();
        },
        child: Scaffold(
          backgroundColor: controller.step.value == 2 ? AppColors.surface : Colors.white,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => controller.step.value == 0 ? Get.back() : controller.back(),
              icon: const Icon(AppIcons.back, size: 20),
            ),
            title: const Text('Novel Information'),
            actions: [
              if (controller.step.value == 0)
                TextButton.icon(
                  onPressed: controller.skip,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(AppIcons.arrowRight, size: 14, color: AppColors.primary),
                  label: const Text(
                    'SKIP',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          body: switch (controller.step.value) {
            0 => _Basics(),
            1 => _Details(),
            _ => _Review(),
          },
        ),
      ),
    );
  }
}

/// Red asterisk + label.
class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        const TextSpan(
          text: '*',
          style: TextStyle(color: AppColors.error),
        ),
        TextSpan(text: text),
      ],
    ),
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  );
}

class _Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Pill(this.label, {required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.primary : AppColors.divider, width: selected ? 1.5 : 1),
      ),
      child: Text(label, style: TextStyle(color: selected ? AppColors.primary : AppColors.textPrimary)),
    ),
  );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  /// Null shows a fixed value with no chevron.
  final VoidCallback? onTap;

  const _Row({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          _Label(label),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 15)),
          if (onTap != null) const Icon(AppIcons.chevronRight, size: 18, color: AppColors.textSecondary),
        ],
      ),
    ),
  );
}

// ── Step 1 ───────────────────────────────────────────────────────────────────
class _Basics extends GetView<StoryFormController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => showCoverSheet(context, controller),
                    child: Obx(
                      () => Stack(
                        alignment: Alignment.center,
                        children: [
                          AuthorCover(
                            story: controller.story,
                            coverIndex: controller.coverIndex.value,
                            coverPath: controller.coverPath.value,
                            title: controller.title.value.isEmpty ? 'Your Title' : controller.title.value,
                            width: 96,
                          ),
                          if (controller.isPickingCover.value)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        _Label('Book Cover'),
                        SizedBox(height: 8),
                        Text(
                          'Cover size: 600×800;\nFile format: .jpg .png;',
                          style: TextStyle(color: AppColors.textSecondary, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _Label('Book Title'),
              TextField(
                controller: controller.titleController,
                maxLength: 60,
                onChanged: (v) => controller.title.value = v,
                decoration: const InputDecoration(
                  hintText: 'The title has a limit of 60 characters.',
                  filled: false,
                  border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              // English only for now; a picker returns when more languages do.
              const _Row(label: 'Language', value: 'ENGLISH'),
              const SizedBox(height: 20),
              const _Label('Target Audience'),
              const SizedBox(height: 12),
              Obx(
                () => Row(
                  children: [
                    _Pill(
                      'Female',
                      selected: controller.audience.value == 'female',
                      onTap: () => controller.audience.value = 'female',
                    ),
                    const SizedBox(width: 12),
                    _Pill(
                      'Male',
                      selected: controller.audience.value == 'male',
                      onTap: () => controller.audience.value = 'male',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _Label('Content Rating'),
              const SizedBox(height: 12),
              Obx(() {
                final info = AuthorData.ratingInfo[controller.rating.value];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final r in AuthorData.ratings)
                          _Pill(r, selected: controller.rating.value == r, onTap: () => controller.rating.value = r),
                      ],
                    ),
                    if (info != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 14),
                        padding: const EdgeInsets.all(10),
                        color: const Color(0xFFFFEEF0),
                        child: Text(
                          '${info.$1}\n${info.$2}',
                          style: const TextStyle(color: AppColors.error, fontSize: 13, height: 1.4),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Obx(() => GradientButton(label: 'NEXT', onTap: controller.basicsOk ? controller.next : null)),
          ),
        ),
      ],
    );
  }
}

// ── Step 2 ───────────────────────────────────────────────────────────────────
class _Details extends GetView<StoryFormController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Obx(
                () => _Row(
                  label: 'Novel Type',
                  value: controller.novelType.value,
                  onTap: () => showChoiceSheet(
                    context,
                    title: 'Novel Type',
                    options: AuthorData.novelTypes,
                    value: controller.novelType,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const _Label('Story Length'),
              const SizedBox(height: 12),
              Obx(
                () => Row(
                  children: [
                    for (final (label, short) in const [('Novel', false), ('Short Story', true)]) ...[
                      _Pill(
                        label,
                        selected: controller.isShort.value == short,
                        // Signed books can't change length: pricing and shelves depend on it.
                        onTap: () {
                          if (!controller.story.signed) controller.isShort.value = short;
                        },
                      ),
                      const SizedBox(width: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Obx(
                () => _Row(
                  label: 'Genre',
                  value: controller.genre.value,
                  onTap: () =>
                      showChoiceSheet(context, title: 'Genre', options: AuthorData.genres, value: controller.genre),
                ),
              ),
              _Row(label: 'Tags', value: 'Edit Tags', onTap: () => showTagsSheet(context, controller)),
              const SizedBox(height: 8),
              const Text(
                'Bonovela will promote your book to readers who share the same interests, based on your tags.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final e in controller.tagsByGroup.entries) ...[
                      const SizedBox(height: 14),
                      Text(e.key, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in e.value)
                            Container(
                              padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
                              decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(t, style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                                  GestureDetector(
                                    onTap: () => controller.removeTag(t),
                                    child: const Padding(
                                      padding: EdgeInsets.all(2),
                                      child: Icon(AppIcons.close, size: 14, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _Label('Synopsis'),
              const SizedBox(height: 4),
              const Text(
                'Please write a description for your story with ${AppConstants.synopsisMinWords} to '
                '${AppConstants.synopsisMaxWords} words.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  TextField(
                    controller: controller.synopsisController,
                    onChanged: (v) => controller.synopsis.value = v,
                    minLines: 8,
                    maxLines: 14,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 30),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 8,
                    child: Obx(
                      () => Text(
                        '${controller.synopsisWords} / ${AppConstants.synopsisMinWords}–${AppConstants.synopsisMaxWords} words',
                        style: TextStyle(
                          fontSize: 12,
                          color: controller.synopsis.value.isEmpty || controller.synopsisOk
                              ? AppColors.textHint
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _BackComplete(),
      ],
    );
  }
}

class _BackComplete extends GetView<StoryFormController> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.back,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: const StadiumBorder(),
                ),
                child: const Text('BACK'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => GradientButton(
                  label: 'COMPLETE',
                  onTap: controller.step.value == 2 || controller.detailsOk ? controller.complete : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 3 ───────────────────────────────────────────────────────────────────
class _Review extends GetView<StoryFormController> {
  @override
  Widget build(BuildContext context) {
    Widget field(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '—' : value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );

    Widget card(List<Widget> children) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );

    final c = controller;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              card([
                Center(
                  child: AuthorCover(
                    story: c.story,
                    coverIndex: c.coverIndex.value,
                    coverPath: c.coverPath.value,
                    title: c.title.value,
                    width: 100,
                  ),
                ),
                const SizedBox(height: 20),
                field('Book Title', c.title.value),
                field('Language', c.language.value),
              ]),
              card([
                field('Novel Type', c.novelType.value),
                field('Story Length', c.isShort.value ? 'Short Story' : 'Novel'),
                field('Genre', c.genre.value),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tags:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final t in c.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(6)),
                              child: Text(t, style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]),
              card([
                field('Target Audience', c.audience.value.capitalizeFirst ?? ''),
                field('Content Rating', c.rating.value),
              ]),
              card([field('Synopsis', c.synopsis.value.trim())]),
            ],
          ),
        ),
        _BackComplete(),
      ],
    );
  }
}
