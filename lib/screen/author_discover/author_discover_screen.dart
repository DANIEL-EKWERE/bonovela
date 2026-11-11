import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_icons.dart';

/// Author Center › Benefits: Writer's Benefits 2026.
class AuthorDiscoverScreen extends StatelessWidget {
  const AuthorDiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.light,
      appBar: AppBar(
        leading: IconButton(onPressed: Get.back, icon: const Icon(AppIcons.arrowLeft)),
        title: const Text('Benefits'),
      ),
      body: ListView(
        children: [
          const _Hero(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Exclusive(),
                const SizedBox(height: 56),
                const _Heading('SHORT STORIES\nPERFORMANCE BENEFITS'),
                const _BenefitCard(
                  ribbon: 'First milestone bonus',
                  title: r'$50 Performance Bonus',
                  table: [
                    ['Royalty Share Target', 'Bonus'],
                    [r'$100', r'$50 USD'],
                  ],
                  body: [
                    _Para(
                      lead: 'How to qualify:',
                      text:
                          r'Generate at least $100 in royalty share within 136 days. Once the earnings are verified, '
                          r'the author can claim the $50 performance bonus.',
                    ),
                    _Para(text: 'The 136-day qualifying period applies to this first milestone.'),
                  ],
                ),
                const SizedBox(height: 28),
                const _BenefitCard(
                  ribbon: 'Second milestone bonus',
                  title: r'$120 Performance Bonus',
                  table: [
                    ['Additional Royalty Share', 'Bonus'],
                    [r'$500', r'$120 USD'],
                  ],
                  body: [
                    _Para(
                      lead: 'How to qualify:',
                      text:
                          r'After claiming the first $50 bonus, generate an additional $500 in royalty share to '
                          r'qualify for the $120 bonus.',
                    ),
                    _Para(
                      lead: 'No extra deadline:',
                      text: 'Authors can take the time they need to reach this second milestone.',
                    ),
                  ],
                ),
                const SizedBox(height: 56),
                const _Heading('NON-EXCLUSIVE CONTRACT BENEFITS'),
                const _BenefitCard(
                  ribbon: 'Completion bonus',
                  title: r'$40 USD Completion Bonus',
                  table: [
                    ['Minimum Completed Word Count', 'Required Profit Share', 'Bonus'],
                    ['150,000 words', r'$60', r'$40 USD'],
                  ],
                  body: [_Qualify(), _WordCountNote()],
                ),
                const SizedBox(height: 56),
                const _Withdrawal(),
                const SizedBox(height: 56),
                const _Heading('QUESTIONS & ANSWERS'),
                for (var i = 0; i < _faqs.length; i++) ...[
                  _Faq(number: i + 1, question: _faqs[i].$1, answer: _faqs[i].$2),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 40),
                const _Footer(),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 48),
            color: _C.pink,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: const Text(
              'BONOVELA · WRITE YOUR STORY. GROW WITH US.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.75,
                letterSpacing: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Colours of the Writer's Benefits design.
abstract final class _C {
  static const pink = Color(0xFFED4F98);
  static const ink = Color(0xFF492F42);
  static const soft = Color(0xFFF58AB8);
  static const light = Color(0xFFFFEAF4);
  static const line = Color(0xFFF7BEDA);

  static Color inkAlpha(double a) => ink.withValues(alpha: a);

  static final cardShadow = [
    BoxShadow(color: pink.withValues(alpha: .45), blurRadius: 32, offset: const Offset(0, 12), spreadRadius: -20),
  ];
}

const _faqs = [
  (
    'Does Bonovela currently offer Exclusive Contracts?',
    'No. Exclusive benefits are marked as coming soon. The current contract benefit described here is for '
        'Non-Exclusive authors.',
  ),
  (
    'How is the first Short Stories bonus calculated?',
    r'The author must accumulate $100 in royalty share within the 136-day qualifying period. After verification, '
        r'the author can claim a $50 bonus.',
  ),
  (
    'Does the second Short Stories bonus have a deadline?',
    r'No. After claiming the first $50 reward, the author can continue toward an additional $500 in royalty share '
        'without another time limit.',
  ),
  (
    'Does 150,000 words guarantee the Non-Exclusive Completion Bonus?',
    r'No. The book must also be published on Bonovela first, reach at least $60 in total author profit share, and '
        'be marked completed within 136 days after signing.',
  ),
  (
    'What is the minimum withdrawal amount?',
    r'The minimum withdrawal threshold is $100 USD. A request can be made when the eligible balance reaches this '
        "amount, in line with Bonovela's payment procedures.",
  ),
];

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    const white = Colors.white;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment(-0.35, -1), end: Alignment(0.35, 1), colors: [_C.soft, _C.light]),
      ),
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(16)),
                child: const Text('B', style: TextStyle(color: _C.pink, fontSize: 36, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Text(
                'bonovela',
                style: TextStyle(
                  color: white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: _C.inkAlpha(.3), offset: const Offset(0, 3), blurRadius: 3)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'A CELEBRATION OF YOUR CREATIVITY',
            textAlign: TextAlign.center,
            style: TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2.2),
          ),
          const SizedBox(height: 16),
          Text(
            "WRITER'S\nBENEFITS 2026",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1.05,
              shadows: [Shadow(color: _C.pink.withValues(alpha: .45), offset: const Offset(0, 4), blurRadius: 4)],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(999)),
            child: const Text(
              'BONOVELA AUTHOR BENEFIT PROGRAMME',
              textAlign: TextAlign.center,
              style: TextStyle(color: _C.pink, fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(32)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 1.54,
                child: Image.asset(
                  'assets/images/writer_benefits_hero.webp',
                  fit: BoxFit.cover,
                  semanticLabel: 'A Bonovela author reading and writing among flowers',
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: _C.pink, borderRadius: BorderRadius.circular(28), boxShadow: _C.cardShadow),
            child: const Text(
              'Discover the rewards available to Bonovela authors. Keep writing, grow your readership, and reach '
              'exciting royalty and completion milestones!',
              style: TextStyle(color: white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _Exclusive extends StatelessWidget {
  const _Exclusive();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        CustomPaint(
          painter: _DashedBorder(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .8),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                const Text(
                  'Benefits for Exclusive Contracts',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _C.pink, fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(
                  'Exclusive contracts are not currently available. Stay tuned for future updates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _C.inkAlpha(.7), fontSize: 18, height: 1.75),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -22,
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: _C.pink, borderRadius: BorderRadius.circular(24)),
            child: const Text(
              'EXCLUSIVE · COMING SOON',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.9),
            ),
          ),
        ),
      ],
    );
  }
}

/// 3px dashed soft-pink outline with 32px corners.
class _DashedBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _C.soft
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(32)).deflate(1.5));
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 14) {
        canvas.drawPath(metric.extractPath(d, d + 8), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 36),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(color: _C.pink, fontSize: 30, fontWeight: FontWeight.w800, height: 1.25),
    ),
  );
}

class _BenefitCard extends StatelessWidget {
  final String ribbon;
  final String title;
  final List<List<String>> table;
  final List<Widget> body;

  const _BenefitCard({required this.ribbon, required this.title, required this.table, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(top: 16, bottom: 28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .82),
        border: Border.all(color: _C.line),
        borderRadius: BorderRadius.circular(28),
        boxShadow: _C.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: _C.soft,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(999)),
            ),
            child: Text(
              ribbon,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _C.pink, fontSize: 24, fontWeight: FontWeight.w700, height: 1.25),
                ),
                const SizedBox(height: 24),
                _Table(rows: table),
                ...body,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Table extends StatelessWidget {
  final List<List<String>> rows;

  const _Table({required this.rows});

  @override
  Widget build(BuildContext context) {
    Widget cell(String text, {bool header = false}) => Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: header ? 16 : 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: header ? Colors.white : _C.ink,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.375,
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(border: Border.all(color: _C.line)),
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: const BoxDecoration(color: _C.soft),
            children: [for (final t in rows.first) cell(t, header: true)],
          ),
          for (final row in rows.skip(1)) TableRow(children: [for (final t in row) cell(t)]),
        ],
      ),
    );
  }
}

class _Para extends StatelessWidget {
  final String? lead;
  final String text;

  const _Para({this.lead, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20),
    child: Text.rich(
      TextSpan(
        style: TextStyle(color: _C.inkAlpha(.75), fontSize: 16, height: 1.75),
        children: [
          if (lead != null)
            TextSpan(
              text: '$lead ',
              style: const TextStyle(color: _C.pink, fontWeight: FontWeight.w700),
            ),
          TextSpan(text: text),
        ],
      ),
    ),
  );
}

class _Qualify extends StatelessWidget {
  const _Qualify();

  static const _steps = [
    'Sign a Non-Exclusive Contract with Bonovela.',
    'Publish the book on Bonovela before publishing it on another platform.',
    'Complete the book with at least 150,000 original words.',
    r'Reach at least $60 in total author profit share when the book is marked as completed.',
    'Mark the book as completed within 136 days from the contract signing date.',
  ];

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: _C.inkAlpha(.75), fontSize: 16, height: 1.75);
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How to qualify:',
            style: TextStyle(color: _C.pink, fontSize: 16, fontWeight: FontWeight.w700, height: 1.75),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _steps.length; i++)
            Padding(
              padding: EdgeInsets.only(left: 8, top: i == 0 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 20, child: Text('${i + 1}.', style: style)),
                  Expanded(child: Text(_steps[i], style: style)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _WordCountNote extends StatelessWidget {
  const _WordCountNote();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 28),
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: _C.light,
      border: Border(left: BorderSide(color: _C.pink, width: 5)),
    ),
    child: Text.rich(
      TextSpan(
        style: TextStyle(color: _C.inkAlpha(.8), fontSize: 16, height: 1.75),
        children: const [
          TextSpan(
            text: 'Understanding the word count: ',
            style: TextStyle(color: _C.ink, fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text:
                'The 150,000-word requirement means the completed manuscript must contain at least 150,000 words '
                "in total. It is the book's overall word count—not 150,000 words per month. The \$60 profit-share "
                'requirement is a separate earnings condition. Reaching the word count alone does not qualify a '
                'book for the bonus.',
          ),
        ],
      ),
    ),
  );
}

class _Withdrawal extends StatelessWidget {
  const _Withdrawal();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
    decoration: BoxDecoration(color: _C.pink, borderRadius: BorderRadius.circular(32), boxShadow: _C.cardShadow),
    child: const Column(
      children: [
        Text(
          'MINIMUM WITHDRAWAL THRESHOLD',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.25),
        ),
        SizedBox(height: 8),
        Text(
          r'$100 USD',
          style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w800, height: 1.1),
        ),
        SizedBox(height: 12),
        Text(
          r'Authors can request a withdrawal once their eligible account balance reaches $100, subject to '
          "Bonovela's withdrawal rules.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.75),
        ),
      ],
    ),
  );
}

class _Faq extends StatelessWidget {
  final int number;
  final String question;
  final String answer;

  const _Faq({required this.number, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .82),
      border: Border.all(color: _C.line),
      borderRadius: BorderRadius.circular(28),
      boxShadow: _C.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number. $question',
          style: const TextStyle(color: _C.pink, fontSize: 18, fontWeight: FontWeight.w700, height: 1.55),
        ),
        const SizedBox(height: 12),
        Text(
          answer,
          style: TextStyle(color: _C.inkAlpha(.75), fontSize: 16, height: 1.75),
        ),
      ],
    ),
  );
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .7),
          border: Border.all(color: _C.soft),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: Image.asset(
                'assets/images/writer_benefits_pencil.webp',
                fit: BoxFit.contain,
                semanticLabel: 'A writer sitting on a giant pink pencil',
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'KEEP WRITING. YOUR STORY MATTERS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _C.pink, fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),
      Text.rich(
        TextSpan(
          style: TextStyle(color: _C.inkAlpha(.75), fontSize: 18, fontWeight: FontWeight.w700, height: 1.75),
          children: const [
            TextSpan(text: 'For more details, please refer to the '),
            TextSpan(
              text: "Bonovela Author's Guidebook",
              style: TextStyle(color: _C.pink, decoration: TextDecoration.underline, decorationColor: _C.pink),
            ),
            TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      Text(
        'All rewards are subject to eligibility checks and verification. Content containing plagiarism, copied '
        'material, repetitive or meaningless chapters, or other policy violations may be disqualified from writer '
        'benefits. Bonovela reserves the right to review reward eligibility in accordance with its publishing '
        'policies.',
        textAlign: TextAlign.center,
        style: TextStyle(color: _C.inkAlpha(.6), fontSize: 14, height: 2),
      ),
    ],
  );
}
