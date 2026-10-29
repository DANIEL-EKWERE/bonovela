import 'package:flutter_test/flutter_test.dart';

import 'package:bonovela/core/utils/formatters.dart';

void main() {
  test('compact number formatting', () {
    expect(Fmt.compact(950), '950');
    expect(Fmt.compact(1000), '1K');
    expect(Fmt.compact(12400), '12.4K');
    expect(Fmt.compact(2400000), '2.4M');
  });
}
