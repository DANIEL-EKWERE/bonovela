import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:bonovela/screen/author_discover/author_discover_screen.dart';

void main() {
  testWidgets("Writer's Benefits lays out on a phone without overflow", (tester) async {
    tester.view.physicalSize = const Size(412 * 3, 915 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const GetMaterialApp(home: AuthorDiscoverScreen()));
    await tester.pumpAndSettle();
    expect(find.text("WRITER'S\nBENEFITS 2026"), findsOneWidget);
    await tester.scrollUntilVisible(find.text('BONOVELA · WRITE YOUR STORY. GROW WITH US.'), 400);
    expect(find.textContaining('What is the minimum withdrawal amount?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
