import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:get/get.dart';

import '../../../config/local_storage.dart';
import '../../../config/routes.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/chapter_model.dart';
import '../../../core/repository/book_repository.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';
import '../models/reader_settings.dart';

class ReaderController extends GetxController {
  final _repo = Get.find<BookRepository>();
  final _storage = Get.find<LocalStorage>();
  final _account = Get.find<AccountService>();

  static const _kSettings = 'reader_settings';

  late final String bookId;

  final Rxn<BookModel> book = Rxn<BookModel>();
  final RxList<ChapterModel> chapters = <ChapterModel>[].obs;
  final Rxn<ChapterModel> chapter = Rxn<ChapterModel>();
  final RxBool isLoading = true.obs;
  final RxBool isUnlocking = false.obs;

  final RxBool showControls = false.obs;
  final Rx<ReaderSettings> settings = const ReaderSettings().obs;

  /// 0–1 scroll position inside the current chapter.
  final RxDouble chapterProgress = 0.0.obs;
  final scrollController = ScrollController();
  Timer? _readingTimer;

  RxInt get coins => _account.coins;
  RxInt get bonus => _account.bonus;
  int get balance => coins.value + bonus.value;

  int get number => chapter.value?.number ?? 1;
  bool get hasPrev => number > 1;
  bool get hasNext => number < chapters.length;
  bool get onShelf => _storage.shelf.contains(bookId);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map;
    bookId = args['bookId'] as String;
    settings.value = ReaderSettings.fromJson(_storage.read<Map>(_kSettings));
    scrollController.addListener(_onScroll);
    // Feeds the daily reading rewards.
    _readingTimer = Timer.periodic(const Duration(minutes: 1), (_) => _account.addReadingMinute());
    _init((args['chapter'] as int?) ?? 1);
  }

  @override
  void onClose() {
    _readingTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> _init(int start) async {
    final results = await Future.wait([_repo.getBook(bookId), _repo.getChapters(bookId)]);
    book.value = results[0] as BookModel?;
    chapters.assignAll(results[1] as List<ChapterModel>);
    await loadChapter(start);
  }

  Future<void> loadChapter(int n) async {
    if (chapters.isNotEmpty) n = n.clamp(1, chapters.length);
    isLoading.value = true;
    showControls.value = false;
    var ch = await _repo.getChapter(bookId, n);
    if (ch.isLocked && autoUnlock && balance >= ch.coinPrice) {
      ch = await _repo.unlockChapter(bookId, n) ?? ch;
    }
    chapter.value = ch;
    _syncChapterList(ch);
    isLoading.value = false;
    chapterProgress.value = 0;
    if (scrollController.hasClients) scrollController.jumpTo(0);
    _storage.saveProgress(bookId, n);
  }

  void _syncChapterList(ChapterModel ch) {
    final i = chapters.indexWhere((c) => c.number == ch.number);
    if (i >= 0 && chapters[i].isLocked != ch.isLocked) chapters[i] = chapters[i].copyWith(isLocked: ch.isLocked);
  }

  void next() {
    if (hasNext) loadChapter(number + 1);
  }

  void prev() {
    if (hasPrev) loadChapter(number - 1);
  }

  Future<void> unlock() async {
    final ch = chapter.value;
    if (ch == null || !ch.isLocked) return;
    isUnlocking.value = true;
    final unlocked = await _repo.unlockChapter(bookId, ch.number);
    isUnlocking.value = false;
    if (unlocked == null) {
      toast('Not enough coins', 'Top up to keep reading.');
      topUp();
      return;
    }
    chapter.value = unlocked;
    _syncChapterList(unlocked);
  }

  void _onScroll() {
    final pos = scrollController.position;
    if (pos.maxScrollExtent > 0) {
      chapterProgress.value = (pos.pixels / pos.maxScrollExtent).clamp(0, 1);
    }
    // Scrolling hides the controls, like turning a page.
    if (showControls.value && pos.userScrollDirection != ScrollDirection.idle) showControls.value = false;
  }

  /// Auto Subscription for this book: unlock locked chapters on arrival.
  bool get autoUnlock => _account.autoUnlockBooks.contains(bookId);
  void setAutoUnlock(bool on) => _account.setAutoUnlock(bookId, on);

  void topUp() => Get.toNamed(AppRoutes.topUp);

  void toggleControls() => showControls.toggle();

  void toggleShelf() {
    _storage.toggleShelf(bookId);
    toast(onShelf ? 'Added to library' : 'Removed from library', book.value?.title ?? '');
  }

  // ── Settings ───────────────────────────────────────────────────────────────
  void updateSettings(ReaderSettings s) {
    settings.value = s;
    _storage.write(_kSettings, s.toJson());
  }

  void changeFont(double delta) => updateSettings(settings.value.copyWith(
        fontSize: (settings.value.fontSize + delta).clamp(ReaderSettings.minFont, ReaderSettings.maxFont),
      ));

  void toggleNight() {
    final night = ReaderTheme.all.length - 1;
    updateSettings(settings.value.copyWith(themeIndex: settings.value.themeIndex == night ? 0 : night));
  }

  /// Leaving a book you've read a few chapters of offers to shelve it.
  bool get shouldOfferShelf => !onShelf && number >= 3;

  void addToShelf() => _storage.addToShelf(bookId);
}
