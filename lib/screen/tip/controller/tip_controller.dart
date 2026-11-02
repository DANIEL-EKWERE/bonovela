import 'package:get/get.dart';

import '../../../config/routes.dart';
import '../../../core/data/mock_data.dart';
import '../../../core/models/book_model.dart';
import '../../../core/services/account_service.dart';
import '../../../widgets/ui_kit.dart';
import '../models/gift_item.dart';

/// Vote / Gift sheet for one book.
class TipController extends GetxController {
  final _account = Get.find<AccountService>();

  final String bookId;

  TipController(this.bookId);

  late final BookModel book = MockData.books.firstWhere((b) => b.id == bookId);

  /// 0 = Vote, 1 = Gift
  final RxInt tab = 1.obs;
  final RxInt giftIndex = 0.obs;
  final RxInt voteCount = 1.obs;
  final RxBool isSending = false.obs;

  final gifts = GiftItem.all;
  static const voteSteps = [1, 5, 10];

  RxInt get coins => _account.coins;
  RxInt get bonus => _account.bonus;
  RxInt get vouchers => _account.vouchers;

  int get balance => coins.value + bonus.value;
  GiftItem get gift => gifts[giftIndex.value];
  bool get canAffordGift => balance >= gift.price;

  /// Mock weekly votes from other readers, plus this reader's.
  int get bookVotes => 40 + book.coverSeed % 300 + (_account.bookVotes[bookId] ?? 0);

  void selectGift(int i) => giftIndex.value = i;

  void setVotes(int n) => voteCount.value = n.clamp(1, vouchers.value < 1 ? 1 : vouchers.value);

  bool _needsLogin() {
    if (_account.isLoggedIn) return false;
    Get.back();
    Get.toNamed(AppRoutes.login);
    return true;
  }

  Future<void> sendGift() async {
    if (_needsLogin()) return;
    if (!canAffordGift) {
      Get.back();
      Get.toNamed(AppRoutes.topUp);
      return;
    }
    isSending.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final g = gift;
    final ok = _account.sendGift(bookId: bookId, title: book.title, gift: g.name, price: g.price, votes: g.votes);
    isSending.value = false;
    if (ok) {
      Get.back();
      toast('${g.emoji} ${g.name} sent!', '${book.author} thanks you · +${g.votes} votes for this book');
    }
  }

  Future<void> vote() async {
    if (_needsLogin()) return;
    if (vouchers.value < 1) {
      Get.back();
      Get.toNamed(AppRoutes.vouchers);
      return;
    }
    final n = voteCount.value.clamp(1, vouchers.value);
    isSending.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    _account.vote(bookId, book.title, n);
    isSending.value = false;
    Get.back();
    toast('Voted!', '$n vote${n == 1 ? '' : 's'} for ${book.title}');
  }
}
