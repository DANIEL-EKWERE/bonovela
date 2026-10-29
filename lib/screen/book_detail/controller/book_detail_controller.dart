import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/local_storage.dart';
import '../../../config/routes.dart';
import '../../../core/models/book_model.dart';
import '../../../core/models/chapter_model.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/comment_model.dart';
import '../../../core/models/wallet_models.dart';
import '../../../core/repository/book_repository.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';

class BookDetailController extends GetxController {
  final _repo = Get.find<BookRepository>();
  final _storage = Get.find<LocalStorage>();
  final _account = Get.find<AccountService>();

  final String bookId;

  BookDetailController(this.bookId);

  final Rxn<BookModel> book = Rxn<BookModel>();
  final RxList<BookModel> related = <BookModel>[].obs;
  final RxList<ChapterModel> chapters = <ChapterModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool synopsisExpanded = false.obs;

  /// Fades the app bar title in once the header scrolls away.
  final scrollController = ScrollController();
  final RxBool collapsed = false.obs;

  bool get onShelf => _storage.shelf.contains(bookId);

  /// Chapter the READ button opens.
  int get resumeChapter => _storage.progressFor(bookId)?.chapter ?? 1;
  bool get hasProgress => _storage.progressFor(bookId) != null;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() => collapsed.value = scrollController.offset > 160);
    load();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    final b = await _repo.getBook(bookId);
    book.value = b;
    if (b != null) {
      final results = await Future.wait([_repo.getRelated(b), _repo.getChapters(bookId)]);
      related.assignAll(results[0] as List<BookModel>);
      chapters.assignAll(results[1] as List<ChapterModel>);
    }
    isLoading.value = false;
  }

  void toggleShelf() {
    _storage.toggleShelf(bookId);
    toast(onShelf ? 'Added to library' : 'Removed from library', book.value?.title ?? '');
  }

  void read([int? chapter]) {
    Get.toNamed(AppRoutes.reader, arguments: {'bookId': bookId, 'chapter': chapter ?? resumeChapter});
  }

  // ── Author ────────────────────────────────────────────────────────────────
  bool get followingAuthor => _account.following.contains(book.value?.author);

  void toggleFollowAuthor() {
    final author = book.value?.author;
    if (author == null) return;
    _account.toggleFollow(author);
    toast(followingAuthor ? 'Following $author' : 'Unfollowed $author');
  }

  void openAuthor() => Get.toNamed(AppRoutes.authorProfile, arguments: book.value!.author);

  // ── Comments ──────────────────────────────────────────────────────────────
  List<CommentModel> get comments {
    final b = book.value;
    if (b == null) return [];
    return [..._account.myComments.where((c) => c.bookId == bookId), ...MockData.commentsFor(b)];
  }

  void openComments() => Get.toNamed(AppRoutes.comments, arguments: bookId);

  // ── Support (gifting) ─────────────────────────────────────────────────────
  static const giftOptions = [10, 50, 100, 500];

  /// Mock count of readers who gifted, plus you once you do.
  int get supporters =>
      12 + (book.value?.coverSeed ?? 0) % 80 + (_account.transactions.any(_isMyGift) ? 1 : 0);

  bool _isMyGift(WalletTransaction t) => t.kind == TxKind.gift && t.bookId == bookId;

  void support(int amount) {
    if (!_account.isLoggedIn) {
      Get.toNamed(AppRoutes.login);
      return;
    }
    final ok = _account.spend(amount, title: 'Gift to ${book.value!.title}', kind: TxKind.gift, bookId: bookId);
    Get.back();
    if (ok) {
      toast('Thank you for your support 💗', '$amount coins sent to ${book.value!.author}');
    } else {
      toast('Not enough coins', 'Top up to support this author.');
      Get.toNamed(AppRoutes.topUp);
    }
  }

  void share() {
    _account.completeDailyTask('share', bonusAmount: 3, max: 1, source: 'Share a story');
    toast('Link copied', 'Share ${book.value?.title ?? 'this book'} with a friend.');
  }

  void report() => toast('Report sent', 'Thanks, we\'ll review this book.');
}
