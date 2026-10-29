import 'dart:io';

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
import 'package:bonovela/main.dart';

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
      AppRoutes.categories: null,
      AppRoutes.viewAll: {'title': 'All', 'books': MockData.books.take(5).toList()},
      AppRoutes.authorProfile: book.author,
      AppRoutes.editProfile: null,
      AppRoutes.followList: 1,
      AppRoutes.inbox: null,
      AppRoutes.authorCenter: null,
      AppRoutes.exchange: null,
      AppRoutes.gems: null,
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
    };

    // Each tab of the shell.
    for (final label in ['Library', 'Discover', 'Short', 'Rank', 'Profile']) {
      await tester.tap(find.text(label).last);
      await _settle(tester);
    }

    for (final MapEntry(key: route, value: args) in routes.entries) {
      Get.toNamed(route, arguments: args);
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
