import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controller/reader_controller.dart';
import '../models/reader_settings.dart';

ShapeBorder get _sheetShape =>
    const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16)));

void showReaderSettings(BuildContext context) {
  final c = Get.find<ReaderController>();
  c.showControls.value = false;
  showModalBottomSheet(
    context: context,
    shape: _sheetShape,
    backgroundColor: c.settings.value.theme.chrome,
    builder: (_) => Obx(() {
      final s = c.settings.value;
      final text = s.theme.text;
      final label = TextStyle(color: text.withValues(alpha: 0.6), fontSize: 13);

      Widget pill(String title, bool selected, VoidCallback onTap) => Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selected ? AppColors.primary : text.withValues(alpha: 0.15)),
                  color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                ),
                child: Text(title,
                    style: TextStyle(color: selected ? AppColors.primary : text, fontSize: 13)),
              ),
            ),
          );

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Text size', style: label),
              Row(
                children: [
                  IconButton(
                    onPressed: () => c.changeFont(-1),
                    icon: Icon(Icons.text_decrease_rounded, color: text),
                  ),
                  Expanded(
                    child: Slider(
                      value: s.fontSize,
                      min: ReaderSettings.minFont,
                      max: ReaderSettings.maxFont,
                      divisions: (ReaderSettings.maxFont - ReaderSettings.minFont).toInt(),
                      onChanged: (v) => c.updateSettings(s.copyWith(fontSize: v)),
                    ),
                  ),
                  IconButton(
                    onPressed: () => c.changeFont(1),
                    icon: Icon(Icons.text_increase_rounded, color: text),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Line spacing', style: label),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final (i, h) in ReaderSettings.lineHeights.indexed)
                    pill(['Compact', 'Normal', 'Relaxed'][i], s.lineHeight == h,
                        () => c.updateSettings(s.copyWith(lineHeight: h))),
                ],
              ),
              const SizedBox(height: 16),
              Text('Font', style: label),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final f in ReaderSettings.fonts)
                    pill(f, s.fontFamily == f, () => c.updateSettings(s.copyWith(fontFamily: f))),
                ],
              ),
              const SizedBox(height: 16),
              Text('Page colour', style: label),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (final (i, t) in ReaderTheme.all.indexed)
                    GestureDetector(
                      onTap: () => c.updateSettings(s.copyWith(themeIndex: i)),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: t.background,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: s.themeIndex == i ? AppColors.primary : text.withValues(alpha: 0.15),
                                width: s.themeIndex == i ? 2.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text('Aa', style: TextStyle(color: t.text, fontSize: 13)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(t.name, style: TextStyle(color: text.withValues(alpha: 0.6), fontSize: 11)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }),
  );
}

void showReaderContents(BuildContext context) {
  final c = Get.find<ReaderController>();
  c.showControls.value = false;
  final theme = c.settings.value.theme;
  // Open scrolled near the current chapter.
  final scroll = ScrollController(initialScrollOffset: ((c.number - 4) * 48.0).clamp(0, double.infinity));
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: _sheetShape,
    backgroundColor: theme.chrome,
    builder: (_) => SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    c.book.value?.title ?? 'Contents',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: theme.text, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                Text('${c.chapters.length} chapters',
                    style: TextStyle(color: theme.text.withValues(alpha: 0.6), fontSize: 13)),
              ],
            ),
          ),
          Divider(color: theme.text.withValues(alpha: 0.1)),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              itemExtent: 48,
              itemCount: c.chapters.length,
              itemBuilder: (_, i) {
                final ch = c.chapters[i];
                final current = ch.number == c.number;
                return ListTile(
                  dense: true,
                  title: Text(
                    ch.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: current ? AppColors.primary : theme.text,
                      fontWeight: current ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: ch.isLocked
                      ? Icon(Icons.lock_outline_rounded, size: 18, color: theme.text.withValues(alpha: 0.4))
                      : null,
                  onTap: () {
                    Get.back();
                    c.loadChapter(ch.number);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  ).whenComplete(scroll.dispose);
}
