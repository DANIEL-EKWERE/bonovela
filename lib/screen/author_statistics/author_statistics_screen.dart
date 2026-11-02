import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/utils/formatters.dart';
import '../../widgets/ui_kit.dart';
import 'controller/author_statistics_controller.dart';

class AuthorStatisticsScreen extends GetView<AuthorStatisticsController> {
  const AuthorStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return SubPage(
      title: 'Statistics',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            color: const Color(0xFFFFF8D9),
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Tips: For a more precise outcome, data displayed here is a comparison between yesterday and the day before.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Title('Release Statistics'),
                _StatCard([
                  ('Word Count', Fmt.compact(c.wordsYesterday), 'yesterday'),
                  ('Ave. chapter length', Fmt.compact(c.avgChapterLength), 'all chapters'),
                  ('Updating days', '${c.updatingDaysThisMonth}', 'this month'),
                ]),
                const _Title('Reading Statistics'),
                _StatCard([
                  ('Subscribers', '${c.subscribers}', 'accumulated'),
                  ('Views', Fmt.compact(c.views), 'accumulated'),
                  ('3rd Chap Reading rate', c.thirdChapterRate, 'last 30 days'),
                ]),
                const _Title('Interactive Statistics'),
                _StatCard([
                  ('Comments', '${c.comments}', 'accumulated'),
                  ('Thumb-ups', '${c.thumbsUp}', 'accumulated'),
                  ('Votes got', '${c.votes}', 'this month'),
                ]),
                Row(
                  children: [
                    const _Title('Promotion'),
                    const SizedBox(width: 8),
                    Flexible(
                      child: GestureDetector(
                        onTap: c.howToPromote,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.blush, borderRadius: BorderRadius.circular(10)),
                          child: const Text(
                            'How to get my book promoted?',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(AppIcons.info, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'We are still gathering the data for today. Please check back tomorrow.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Date', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                const SizedBox(height: 8),
                                Text(c.today, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const Expanded(
                            child: Column(
                              children: [
                                Text('Position', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                SizedBox(height: 8),
                                Text('No result', style: TextStyle(color: AppColors.textHint)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const _Title('Reader Gender'),
                WhiteCard(child: _GenderRing(split: c.genderSplit)),
                const _Title('Reading-period Distribution'),
                const WhiteCard(
                  child: SizedBox(
                    height: 120,
                    child: Center(
                      child: Text('Sorry! No data found.', style: TextStyle(color: AppColors.textHint)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String text;

  const _Title(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 12, 2, 10),
    child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
  );
}

class _StatCard extends StatelessWidget {
  final List<(String, String, String)> items;

  const _StatCard(this.items);

  @override
  Widget build(BuildContext context) => WhiteCard(
    child: Row(
      children: [
        for (final (label, value, period) in items)
          Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(period, style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
              ],
            ),
          ),
      ],
    ),
  );
}

class _GenderRing extends StatelessWidget {
  final (double, double, double) split;

  const _GenderRing({required this.split});

  static const _colors = [Color(0xFF4C8DFF), AppColors.primary, AppColors.textHint];
  static const _labels = ['MALE', 'FEMALE', 'RATHER NOT SAY'];

  @override
  Widget build(BuildContext context) {
    final values = [split.$1, split.$2, split.$3];
    return Row(
      children: [
        SizedBox(width: 110, height: 110, child: CustomPaint(painter: _RingPainter(values, _colors))),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, color: _colors[i]),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_labels[i], style: const TextStyle(fontSize: 12))),
                      Text('${(values[i] * 100).round()}%', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              const Text('last 30 days', style: TextStyle(fontSize: 11, color: AppColors.textHint)),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _RingPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.16;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arcRect = rect.deflate(stroke / 2);
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) {
      canvas.drawArc(arcRect, 0, 2 * pi, false, paint..color = AppColors.divider);
      return;
    }
    var start = -pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * pi;
      canvas.drawArc(arcRect, start, sweep, false, paint..color = colors[i]);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.values != values;
}
