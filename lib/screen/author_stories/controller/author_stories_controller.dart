import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/api/api_client.dart';
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

  /// Pay-to-Read Application: choose the first chapter to lock.
  void applyPayToRead(AuthorStory s) {
    final count = chapterCount(s);
    if (count < 2) return toast('Pay-to-Read', 'Publish at least 2 chapters first.');
    final chapter = 2.obs;
    final message = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Pay-to-Read Application'),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose the first chapter readers unlock with coins. Your editor may choose a different chapter. "
                'Chapters before it stay free.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              DropdownButton<int>(
                value: chapter.value,
                isExpanded: true,
                items: [
                  for (var n = 2; n <= count; n++) DropdownMenuItem(value: n, child: Text('Lock from chapter $n')),
                ],
                onChanged: (v) => chapter.value = v ?? 2,
              ),
              TextField(
                controller: message,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Message to your editor (optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Get.back();
              final error = await _author.applyPayToRead(s, chapter.value, message.text.trim());
              error == null ? toast('Applied for Pay-to-Read', 'Status: Pending Review.') : toast('Not sent', error);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  /// The contract the Chief Editor sent: terms, then sign.
  void reviewContract(AuthorStory s) {
    final agreed = false.obs;
    final signing = false.obs;
    // The Chief Editor's contract template, filled in for this book.
    final terms = ''.obs;
    final signer = ''.obs;
    final name = ''.obs;
    _author.contract(s).then((c) {
      terms.value = c.text;
      signer.value = c.signer;
    });
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
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(Get.context!).height * 0.45),
                child: SingleChildScrollView(
                  child: Text(
                    terms.value.isNotEmpty
                        ? terms.value
                        : '1. Rights. You grant Bonovela the non-exclusive right to publish your book in the Bonovela '
                              'apps and website.\n\n2. Earnings. You receive a profit share of coins spent unlocking '
                              'your chapters and gifts sent to your book.\n\n3. Updates. Ongoing books should update '
                              'regularly.\n\n4. Content. The work is original and follows the Bonovela Author Policy.',
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ),
              ),
              CheckboxListTile(
                value: agreed.value,
                onChanged: (v) => agreed.value = v ?? false,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('I have read and accept the contract terms, and my electronic signature is binding.'),
              ),
              TextField(
                onChanged: (v) => name.value = v,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Sign with your full legal name',
                  hintText: signer.value.isEmpty ? null : signer.value,
                  helperText: signer.value.isEmpty ? null : 'Type it exactly as on your application: ${signer.value}',
                ),
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: 'Sign contract',
                loading: signing.value,
                onTap: agreed.value && name.value.trim().isNotEmpty
                    ? () async {
                        signing.value = true;
                        try {
                          await _author.signContract(s, name.value);
                          Get.back();
                          toast('Contract signed ✍️', 'Bonovela will add its signature shortly.');
                        } on ApiException catch (e) {
                          toast("Couldn't sign yet", e.message);
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

  void editStory(AuthorStory s) {
    if (s.underReview) return toast("Can't edit this book now", s.lockReason);
    Get.toNamed(AppRoutes.storyForm, arguments: s.id);
  }

  void openChapters(AuthorStory s) => Get.toNamed(AppRoutes.storyChapters, arguments: s.id);

  void addChapter(AuthorStory s) => Get.toNamed(AppRoutes.chapterEditor, arguments: {'storyId': s.id});

  bool canApply(AuthorStory s) {
    _author.chapters.length; // re-check when chapters change
    return _author.canApplyForContract(s);
  }

  void applyForContract(AuthorStory s) => Get.toNamed(AppRoutes.contractApplication, arguments: s.id);

  void deleteStory(AuthorStory s) {
    final error = _author.deleteStory(s.id);
    if (error != null) return toast("Can't delete this book", error);
    toast('Story deleted', s.displayTitle);
  }
}
