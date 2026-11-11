import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/models/author_models.dart';
import '../../../core/services/author_service.dart';
import '../../../widgets/common.dart';
import '../../../widgets/ui_kit.dart';

class AuthorStoriesController extends GetxController {
  final _author = Get.find<AuthorService>();

  final RxBool tipsExpanded = false.obs;

  RxList<AuthorStory> get stories => _author.stories;

  int chapterCount(AuthorStory s) => _author.published(s.id).length;
  int words(AuthorStory s) => _author.totalWords(s.id);

  int views(AuthorStory s) => s.views;
  int likes(AuthorStory s) => _author.commentsFor(s).length;

  Future<void> refreshStories() => _author.sync();

  /// The contract the Chief Editor sent: terms, then sign.
  void reviewContract(AuthorStory s) {
    final agreed = false.obs;
    final signing = false.obs;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your contract', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Non-Exclusive contract · ${s.displayTitle}', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 14),
              const Text(
                '1. Rights. You grant Bonovela the non-exclusive right to publish your book in the Bonovela apps '
                'and website.\n\n2. Earnings. You receive a profit share of coins spent unlocking your chapters '
                'and gifts sent to your book, paid monthly once your balance reaches the payout threshold.\n\n'
                '3. Updates. Ongoing books should update regularly.\n\n4. Content. The work is original and follows '
                'the Bonovela content guidelines.',
                style: TextStyle(fontSize: 13, height: 1.5),
              ),
              CheckboxListTile(
                value: agreed.value,
                onChanged: (v) => agreed.value = v ?? false,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('I have read and accept the contract terms.'),
              ),
              GradientButton(
                label: 'Sign contract',
                loading: signing.value,
                onTap: agreed.value
                    ? () async {
                        signing.value = true;
                        try {
                          await _author.signContract(s);
                          Get.back();
                          toast('Signed 🎉', '"${s.displayTitle}" is under contract.');
                        } catch (_) {
                          toast("Couldn't sign yet", 'Check your connection and try again.');
                        } finally {
                          signing.value = false;
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  DateTime lastUpdate(AuthorStory s) => s.updatedAt;

  void newStory() => Get.toNamed(AppRoutes.storyForm);

  void editStory(AuthorStory s) => Get.toNamed(AppRoutes.storyForm, arguments: s.id);

  void openChapters(AuthorStory s) => Get.toNamed(AppRoutes.storyChapters, arguments: s.id);

  void addChapter(AuthorStory s) => Get.toNamed(AppRoutes.chapterEditor, arguments: {'storyId': s.id});

  bool canApply(AuthorStory s) {
    _author.chapters.length; // re-check when chapters change
    return _author.canApplyForContract(s);
  }

  void applyForContract(AuthorStory s) => Get.toNamed(AppRoutes.contractApplication, arguments: s.id);

  void deleteStory(AuthorStory s) {
    _author.deleteStory(s.id);
    toast('Story deleted', s.displayTitle);
  }
}
