import 'package:flutter/material.dart';

class ReaderTheme {
  final String name;
  final Color background;
  final Color text;
  final Color chrome; // top/bottom bars

  const ReaderTheme(this.name, this.background, this.text, this.chrome);

  bool get isDark => background.computeLuminance() < 0.2;

  static const List<ReaderTheme> all = [
    ReaderTheme('White', Color(0xFFFFFFFF), Color(0xFF222222), Color(0xFFFFFFFF)),
    ReaderTheme('Blush', Color(0xFFFFF1F5), Color(0xFF2E1F27), Color(0xFFFFF7FA)),
    ReaderTheme('Sepia', Color(0xFFF6EEDC), Color(0xFF3B2F22), Color(0xFFFBF5E8)),
    ReaderTheme('Mint', Color(0xFFE6F2EA), Color(0xFF1F2E25), Color(0xFFF0F8F3)),
    ReaderTheme('Night', Color(0xFF17151A), Color(0xFFB9B4BE), Color(0xFF221F26)),
  ];
}

class ReaderSettings {
  final double fontSize;
  final double lineHeight;
  final int themeIndex;
  final String fontFamily;

  const ReaderSettings({
    this.fontSize = 18,
    this.lineHeight = 1.7,
    this.themeIndex = 0,
    this.fontFamily = 'Lora',
  });

  static const double minFont = 14;
  static const double maxFont = 28;
  static const List<double> lineHeights = [1.4, 1.7, 2.0];
  static const List<String> fonts = ['Lora', 'Merriweather', 'Poppins'];

  ReaderTheme get theme => ReaderTheme.all[themeIndex.clamp(0, ReaderTheme.all.length - 1)];

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    int? themeIndex,
    String? fontFamily,
  }) =>
      ReaderSettings(
        fontSize: fontSize ?? this.fontSize,
        lineHeight: lineHeight ?? this.lineHeight,
        themeIndex: themeIndex ?? this.themeIndex,
        fontFamily: fontFamily ?? this.fontFamily,
      );

  Map<String, dynamic> toJson() => {
        'fontSize': fontSize,
        'lineHeight': lineHeight,
        'themeIndex': themeIndex,
        'fontFamily': fontFamily,
      };

  factory ReaderSettings.fromJson(Map? j) {
    if (j == null) return const ReaderSettings();
    return ReaderSettings(
      fontSize: (j['fontSize'] as num?)?.toDouble() ?? 18,
      lineHeight: (j['lineHeight'] as num?)?.toDouble() ?? 1.7,
      themeIndex: (j['themeIndex'] as num?)?.toInt() ?? 0,
      fontFamily: j['fontFamily']?.toString() ?? 'Lora',
    );
  }
}
