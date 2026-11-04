import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../widgets/drama_cover.dart';
import '../../widgets/ui_kit.dart';
import 'controller/drama_list_controller.dart';

class DramaListScreen extends GetView<DramaListController> {
  const DramaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SubPage(
      title: controller.title,
      background: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.dramas.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final d = controller.dramas[i];
          return InkWell(
            onTap: () => controller.play(d),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DramaCover(drama: d, width: 92),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        '${d.genre} · ${d.episodeCount} episodes${d.isCompleted ? '' : ' · Updating'}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d.synopsis,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
