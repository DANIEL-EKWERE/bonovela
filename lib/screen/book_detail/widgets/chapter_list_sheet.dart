import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/book_detail_controller.dart';

void showChapterList(BuildContext context, BookDetailController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (_, scroll) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text('Contents', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${controller.chapters.length} chapters',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: scroll,
                  itemCount: controller.chapters.length,
                  itemBuilder: (_, i) {
                    final ch = controller.chapters[i];
                    final current = controller.hasProgress && controller.resumeChapter == ch.number;
                    return ListTile(
                      dense: true,
                      title: Text(
                        ch.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: current ? AppColors.primary : AppColors.textPrimary,
                          fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      trailing: ch.isLocked
                          ? const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.textHint)
                          : null,
                      onTap: () {
                        Get.back();
                        controller.read(ch.number);
                      },
                    );
                  },
                )),
          ),
        ],
      ),
    ),
  );
}
