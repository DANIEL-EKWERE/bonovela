import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../controller/drama_player_controller.dart';

/// Grid of episode numbers; locked ones show a padlock.
class EpisodesSheet extends GetView<DramaPlayerController> {
  const EpisodesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final d = controller.drama;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      d.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(onPressed: Get.back, icon: const Icon(AppIcons.close, size: 20)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${d.isCompleted ? 'Complete' : 'Updating'} · ${d.episodeCount} episodes',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final current = controller.episode.value;
                controller.service.unlocked.length; // rebuild after unlocks
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: d.episodeCount,
                  itemBuilder: (_, i) {
                    final ep = i + 1;
                    final open = controller.service.canWatch(d, ep);
                    final active = ep == current;
                    return InkWell(
                      onTap: () => controller.jumpTo(ep),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: active ? AppColors.blush : AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: active ? AppColors.primary : Colors.transparent),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                '$ep',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: active ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (!open)
                              const Positioned(
                                top: 3,
                                right: 4,
                                child: Icon(AppIcons.lockFill, size: 11, color: AppColors.textHint),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
