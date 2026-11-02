import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../widgets/common.dart';
import 'controller/chapter_editor_controller.dart';

class ChapterEditorScreen extends GetView<ChapterEditorController> {
  const ChapterEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.saveAndExit();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: false,
          leading: IconButton(onPressed: controller.saveAndExit, icon: const Icon(AppIcons.back, size: 20)),
          titleSpacing: 0,
          title: const Text('Save&Exit', style: TextStyle(fontSize: 16)),
          actions: [
            _RoundAction(icon: AppIcons.settings, onTap: () => _settings(context)),
            const SizedBox(width: 8),
            _RoundAction(icon: AppIcons.arrowRight, onTap: () => _release(context)),
            const SizedBox(width: 12),
          ],
        ),
        body: Column(
          children: [
            Container(
              color: AppColors.surface,
              child: TextField(
                controller: controller.titleController,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Chapter ${controller.chapter.number} title',
                  fillColor: AppColors.surface,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller.bodyController,
                onChanged: (v) => controller.body.value = v,
                expands: true,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 16, height: 1.6),
                decoration: const InputDecoration(
                  hintText: 'Start writing your chapter…',
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: SafeArea(
                top: false,
                child: Obx(
                  () => Text(
                    '${controller.words} Words (Ideal word count: '
                    '${ChapterEditorController.idealMin}-${ChapterEditorController.idealMax})',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _settings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.hasNote.value,
                onChanged: (v) => controller.hasNote.value = v,
                title: const Text('Additional Note Chapter'),
                subtitle: const Text('Shown to readers after the chapter', style: TextStyle(fontSize: 12)),
              ),
              if (controller.hasNote.value)
                TextField(
                  controller: controller.noteController,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    hintText: 'Note (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _release(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Release', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Text(
                  controller.story.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _Info('Chapter type', 'Normal chapter'),
                _Info('Word counts', '${controller.words}'),
                Row(
                  children: [
                    const Expanded(child: Text('Auto-publish', style: TextStyle(fontSize: 15))),
                    Switch(value: controller.autoPublish.value, onChanged: (v) => controller.autoPublish.value = v),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: Get.back,
                        style: TextButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.textPrimary,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GradientButton(
                        label: 'Release',
                        height: 46,
                        loading: controller.isReleasing.value,
                        onTap: controller.release,
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

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        Text(value, style: const TextStyle(color: AppColors.textHint)),
      ],
    ),
  );
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.buttonGradient),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}
