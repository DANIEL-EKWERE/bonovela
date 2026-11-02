import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/data/author_data.dart';
import '../../../widgets/author_cover.dart';
import '../../../widgets/common.dart';
import '../controller/story_form_controller.dart';

const _sheetShape = RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16)));

/// "Edit the book cover": recommended covers or upload from device.
void showCoverSheet(BuildContext context, StoryFormController c) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: _sheetShape,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text('Edit the book cover', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
          ListTile(
            leading: const Icon(AppIcons.image),
            title: const Text('Recommended book covers'),
            onTap: () {
              Get.back();
              _showRecommendedCovers(context, c);
            },
          ),
          ListTile(
            leading: const Icon(AppIcons.upload),
            title: const Text('Book covers on your device'),
            subtitle: const Text('600×800 · .jpg .png', style: TextStyle(fontSize: 12)),
            onTap: () {
              Get.back();
              c.pickFromDevice();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

void _showRecommendedCovers(BuildContext context, StoryFormController c) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: _sheetShape,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recommended book covers', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Obx(
              () => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < AppColors.coverPalettes.length; i++)
                    GestureDetector(
                      onTap: () => c.pickCover(i),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: c.coverPath.isEmpty && c.coverIndex.value == i
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: AuthorCover(
                          story: c.story,
                          coverIndex: i,
                          coverPath: '',
                          title: c.title.value.isEmpty ? 'Your Title' : c.title.value,
                          width: 70,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Single-choice list with a Done button (Genre, Language, Novel type).
void showChoiceSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required RxString value,
}) {
  final draft = value.value.obs;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: _sheetShape,
    builder: (_) => SizedBox(
      height: MediaQuery.sizeOf(context).height * (options.length > 8 ? 0.8 : 0.5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
                TextButton(
                  onPressed: () {
                    value.value = draft.value;
                    Get.back();
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(
              () => ListView(
                children: [
                  for (final o in options)
                    ListTile(
                      title: Text(o),
                      trailing: Icon(
                        draft.value == o ? AppIcons.radioOn : AppIcons.radioOff,
                        color: draft.value == o ? AppColors.primary : AppColors.textHint,
                      ),
                      onTap: () => draft.value = o,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Tags: Style / Character / Setting tabs, multi-select chips.
void showTagsSheet(BuildContext context, StoryFormController c) {
  c.openTagPicker();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFFF5F8),
    shape: _sheetShape,
    builder: (_) => SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.62,
      child: Obx(() {
        final (hint, options) = AuthorData.tagGroups[c.tagTab.value]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text('Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(
                    '${c.tagDraft.length}/${StoryFormController.maxTags}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AppColors.blushDeep, borderRadius: BorderRadius.circular(6)),
              child: Row(
                children: [
                  for (final g in AuthorData.tagGroups.keys)
                    TextButton(
                      onPressed: () => c.tagTab.value = g,
                      child: Text(
                        g,
                        style: TextStyle(
                          color: c.tagTab.value == g ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: c.tagTab.value == g ? FontWeight.w600 : FontWeight.w400,
                          decoration: c.tagTab.value == g ? TextDecoration.underline : null,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                color: Colors.white,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    Text(hint, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in options)
                          GestureDetector(
                            onTap: () => c.toggleTag(t),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: c.tagDraft.contains(t) ? AppColors.blush : AppColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: c.tagDraft.contains(t) ? AppColors.primary : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                t,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: c.tagDraft.contains(t) ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: Get.back,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GradientButton(label: 'OK', height: 46, onTap: c.confirmTags),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    ),
  );
}
