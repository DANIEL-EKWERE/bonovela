import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bonovela/config/local_storage.dart';
import 'package:bonovela/config/routes.dart';
import 'package:bonovela/core/data/mock_data.dart';
import 'package:bonovela/core/repository/book_repository.dart';
import 'package:bonovela/core/repository/mock_book_repository.dart';
import 'package:bonovela/core/services/account_service.dart';
import 'package:bonovela/core/services/ads_service.dart';
import 'package:bonovela/core/data/drama_data.dart';
import 'package:bonovela/core/services/author_service.dart';
import 'package:bonovela/core/services/drama_service.dart';
import 'package:bonovela/main.dart';
import 'package:bonovela/screen/discover/controller/discover_controller.dart';

/// Opens every route on a phone-sized screen and fails on any exception
/// (GetX misuse, layout overflow, bad arguments).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('bonovela_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => dir.path,
    );
  });

  tearDownAll(() => dir.delete(recursive: true));

  testWidgets('every screen builds', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.runAsync(() async {
      await Get.putAsync<LocalStorage>(() => LocalStorage().init(), permanent: true);
      await Get.putAsync<AccountService>(() => AccountService().init(), permanent: true);
      Get.put<AuthorService>(AuthorService().init(), permanent: true);
      Get.put<DramaService>(DramaService().init(), permanent: true);
      Get.put<AdsService>(AdsService(), permanent: true);
    });
    Get.put<BookRepository>(MockBookRepository(), permanent: true);

    await tester.pumpWidget(const BonovelaApp());
    await _settle(tester, seconds: 2); // splash → onboarding (first launch)

    // Onboarding: choosing a type fills the shelf and opens Library.
    expect(find.text('Choose a type'), findsOneWidget);
    await tester.tap(find.text('Female novels'));
    await _settle(tester);
    expect(Get.find<LocalStorage>().shelf, isNotEmpty);
    expect(find.text('Recommended'), findsWidgets);

    final book = MockData.books.first;
    final short = MockData.books.firstWhere((b) => b.isShort);
    final routes = <String, dynamic>{
      AppRoutes.bookDetail: book.id,
      AppRoutes.reader: {'bookId': book.id, 'chapter': 1},
      AppRoutes.comments: book.id,
      AppRoutes.search: null,
      AppRoutes.paymentInfo: {'withdraw': true},
      AppRoutes.withdrawals: null,
      AppRoutes.categories: null,
      AppRoutes.rank: null,
      AppRoutes.viewAll: {'title': 'All', 'books': MockData.books.take(5).toList()},
      AppRoutes.authorProfile: book.author,
      AppRoutes.editProfile: null,
      AppRoutes.followList: 1,
      AppRoutes.inbox: null,
      AppRoutes.authorCenter: null,
      AppRoutes.exchange: null,
      AppRoutes.vouchers: null,
      AppRoutes.wallet: null,
      AppRoutes.topUp: null,
      AppRoutes.transactionHistory: null,
      AppRoutes.bonusHistory: null,
      AppRoutes.chapterUnlocked: null,
      AppRoutes.expenseRecord: null,
      AppRoutes.autoSubscription: null,
      AppRoutes.rewards: null,
      AppRoutes.subscription: null,
      AppRoutes.onlineService: null,
      AppRoutes.settings: null,
      AppRoutes.language: null,
      AppRoutes.pushSettings: null,
      AppRoutes.termsPolicy: null,
      AppRoutes.legalDoc: 'Privacy Policy',
      AppRoutes.login: null,
      AppRoutes.authEmail: null,
      AppRoutes.signUp: 'new.reader@example.com',
      AppRoutes.verifyEmail: 'new.reader@example.com',
      AppRoutes.signIn: AccountService.demoEmail,
      AppRoutes.onboarding: null,
      AppRoutes.dramaList: {'title': 'Trending', 'dramas': DramaData.dramas.take(5).toList()},
      AppRoutes.dramaPlayer: {'dramaId': DramaData.dramas.first.id, 'episode': 1},
      '${AppRoutes.dramaPlayer}?locked': {'dramaId': DramaData.dramas[1].id, 'episode': 8},
    };

    // Each tab of the shell.
    for (final label in ['Library', 'Discover', 'Short', 'Drama', 'Profile']) {
      await tester.tap(find.text(label).last);
      await _settle(tester);
    }

    // Romance tab sections, in order.
    final discover = Get.find<DiscoverController>();
    discover.loadTab('Romance');
    await _settle(tester);
    expect(discover.feeds['Romance']!.map((f) => f.title).toList(), [
      'Love on Top',
      'Best Romance',
      "Editor's Picks",
      'Recommended',
    ]);
    expect(discover.feeds['Romance']!.every((f) => f.books.isNotEmpty), isTrue);

    for (final MapEntry(key: route, value: args) in routes.entries) {
      Get.toNamed(route.split('?').first, arguments: args);
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: route);
      Get.back();
      await _settle(tester);
    }

    // Sign up → verify signs the new user in and closes the flow.
    final account = Get.find<AccountService>();
    account.register('new.reader@example.com', 'abc123');
    Get.toNamed(AppRoutes.login);
    await _settle(tester);
    Get.toNamed(AppRoutes.verifyEmail, arguments: 'new.reader@example.com');
    await _settle(tester);
    await tester.tap(find.text('Jump to email box'));
    await _settle(tester, seconds: 2);
    expect(account.user.value?.email, 'new.reader@example.com');
    expect(Get.currentRoute, AppRoutes.main);

    // Password sign-in with the demo account.
    account.logout();
    expect(account.signIn(AccountService.demoEmail, 'wrong'), isNotNull);
    expect(account.signIn(AccountService.demoEmail, AccountService.demoPassword), isNull);
    expect(account.lastAccount.value?['email'], AccountService.demoEmail);

    // Author Center: become an author, create a story, release a chapter,
    // then open every author screen and tab.
    account.becomeAuthor();
    final author = Get.find<AuthorService>();
    final story = author.newStory()
      ..title = 'Love and Lies'
      ..coverIndex = 2
      ..audience = 'female'
      ..rating = '16+'
      ..genre = 'Romance'
      ..tags = ['Contemporary', 'Divorce']
      ..synopsis = List.filled(60, 'word').join(' ');
    author.saveStory(story);
    expect(story.isInfoComplete, isTrue);

    // Device cover: copied into app storage, shown instead of the palette,
    // and deleted with the story.
    final coverFile = await tester.runAsync(() async {
      final src = File('${dir.path}/picked.jpg')..writeAsBytesSync([0xFF, 0xD8, 0xFF]);
      return author.importCover(src.path, story.id);
    });
    expect(File(coverFile!).existsSync(), isTrue);
    story.coverPath = coverFile;
    author.saveStory(story);
    expect(story.hasCover, isTrue);
    final ch = author.newChapter(story.id)
      ..title = 'The Night Before'
      ..content = List.filled(650, 'text').join(' ');
    author.publishChapter(ch);
    expect(author.totalWords(story.id), 650);
    expect(author.commentsFor(story), isNotEmpty);

    Get.toNamed(AppRoutes.authorCenter);
    await _settle(tester);
    for (final label in ['Benefits', 'Calendar', 'Comments', 'Income', 'Stories']) {
      await tester.tap(find.text(label).last);
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: 'author tab $label');
    }
    for (final MapEntry(key: route, value: args) in <String, dynamic>{
      AppRoutes.storyForm: story.id,
      AppRoutes.storyChapters: story.id,
      AppRoutes.chapterEditor: {'storyId': story.id, 'chapterId': ch.id},
      AppRoutes.authorStatistics: story.id,
      AppRoutes.contractApplication: story.id,
    }.entries) {
      Get.toNamed(route.split('?').first, arguments: args);
      await _settle(tester);
      expect(tester.takeException(), isNull, reason: route);
      Get.back();
      await _settle(tester);
    }
    // New-story form, through all three steps.
    Get.toNamed(AppRoutes.storyForm);
    await _settle(tester);
    expect(find.text('Novel Information'), findsOneWidget);
    Get.back();
    await _settle(tester);
    Get.back(); // author center
    await _settle(tester);

    // Tip sheet from the reader: Vote and Gift tabs, voucher voting, and a
    // gift the reader can't afford is refused.
    Get.toNamed(AppRoutes.reader, arguments: {'bookId': book.id, 'chapter': 1});
    await _settle(tester);
    await tester.tapAt(tester.getCenter(find.byType(Scaffold).last)); // show reader controls
    await _settle(tester);
    await tester.tap(find.byTooltip('Tip this book'));
    await _settle(tester);
    expect(find.text('Gift'), findsWidgets);
    expect(find.textContaining('Coins Balance'), findsOneWidget);
    await tester.tap(find.text('Vote').first);
    await _settle(tester);
    expect(find.textContaining('votes this week'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'tip sheet');
    Get.back(); // sheet
    await _settle(tester);
    Get.back(); // reader
    await _settle(tester);
    account.addVouchers(5, 'Test');
    expect(account.vote(book.id, book.title, 3), isTrue);
    expect(account.vouchers.value, 2);
    expect(account.bookVotes[book.id], 3);
    expect(account.vote(book.id, book.title, 9), isFalse);
    expect(
      account.sendGift(bookId: book.id, title: book.title, gift: 'Crown', price: 999999, votes: 68),
      isFalse,
    );

    // A locked chapter renders the unlock card.
    Get.toNamed(AppRoutes.reader, arguments: {'bookId': book.id, 'chapter': 11});
    await _settle(tester);
    expect(find.textContaining('Unlock'), findsWidgets);
    Get.back();
    await _settle(tester);

    // Shorts lock after chapter 3 without Plus.
    Get.toNamed(AppRoutes.reader, arguments: {'bookId': short.id, 'chapter': 4});
    await _settle(tester);
    expect(find.textContaining('Unlock'), findsWidgets);
    Get.back();
    await _settle(tester);
  });
}

/// The mock repository sleeps ~350 ms per call; spinners never settle, so
/// pump fixed frames instead of pumpAndSettle.
Future<void> _settle(WidgetTester tester, {int seconds = 1}) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
