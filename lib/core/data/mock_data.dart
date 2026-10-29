import '../models/book_model.dart';
import '../models/comment_model.dart';

/// Sample catalogue. All titles and blurbs are original placeholders.
class MockData {
  static final DateTime _now = DateTime.now();

  static BookModel _b(
    int id,
    String title,
    String author,
    String genre,
    List<String> tags,
    String synopsis, {
    double rating = 9.0,
    int views = 10000,
    int chapters = 120,
    bool completed = false,
    bool short = false,
    int daysAgo = 1,
  }) =>
      BookModel(
        id: 'b$id',
        title: title,
        author: author,
        synopsis: synopsis,
        genre: genre,
        tags: tags,
        rating: rating,
        views: views,
        chapterCount: chapters,
        wordCount: chapters * (short ? 1800 : 1400),
        isCompleted: completed,
        isShort: short,
        updatedAt: _now.subtract(Duration(days: daysAgo, hours: id)),
      );

  static final List<BookModel> books = [
    // ── Werewolf ────────────────────────────────────────────────────────────
    _b(1, 'Moonbound to the Exiled Alpha', 'Ivy Laurent', 'Werewolf', ['Alpha', 'Second Chance'],
        'Cast out of her pack on the night of her first shift, Selene finds shelter with the one wolf every pack fears: the alpha they exiled ten years ago.',
        rating: 9.6, views: 2400000, chapters: 210, completed: true, daysAgo: 30),
    _b(2, 'The Silver Pack\'s Forgotten Luna', 'Nora Vale', 'Werewolf', ['Luna', 'Rejected Mate'],
        'Rejected at her mating ceremony, Ayla leaves without a word. Five years later the Silver Pack needs a healer, and she is the only one left.',
        rating: 9.4, views: 1850000, chapters: 176, daysAgo: 0),
    _b(3, 'Howl of the Northern Wilds', 'Kade Rowan', 'Werewolf', ['Fast-Paced', 'Pack War'],
        'Three packs, one frozen border, and a lone she-wolf who knows the secret that started the war.',
        rating: 9.1, views: 640000, chapters: 98, daysAgo: 2),
    _b(4, 'Marked by the Lycan Prince', 'Ella Brooks', 'Werewolf', ['Royalty', 'Fated'],
        'A human servant in the Lycan court wakes with a mark she should not carry: the crown prince\'s own.',
        rating: 9.3, views: 1200000, chapters: 154, daysAgo: 1),
    _b(5, 'Her Wolf Woke at Midnight', 'Tessa Moon', 'Werewolf', ['Hidden Power', 'Revenge'],
        'Everyone called her wolfless. On her twenty-first birthday, the wolf that answered was the oldest bloodline alive.',
        rating: 9.0, views: 380000, chapters: 64, daysAgo: 0),
    _b(6, 'Alpha Rhys and the Runaway Healer', 'Mira Hale', 'Werewolf', ['Alpha', 'Slow Burn'],
        'She ran from her pack to save her life. He hunts runaways for a living. Neither expected the bond.',
        rating: 8.9, views: 210000, chapters: 47, daysAgo: 3),

    // ── Romance ─────────────────────────────────────────────────────────────
    _b(7, 'Contract Bride of the Cold CEO', 'Lena Hart', 'Romance', ['CEO', 'Contract Marriage'],
        'One year, one signature, no feelings. That was the deal, until her new husband started breaking every rule he wrote.',
        rating: 9.5, views: 3100000, chapters: 240, completed: true, daysAgo: 45),
    _b(8, 'After the Divorce, He Begged', 'Ruby Sloane', 'Romance', ['Divorce', 'Regret'],
        'For six years she was the perfect wife. The day she signed the papers, she became the woman he couldn\'t stop thinking about.',
        rating: 9.2, views: 1900000, chapters: 188, daysAgo: 0),
    _b(9, 'Secretly Married to My Rival', 'Clara Wynn', 'Romance', ['Enemies to Lovers', 'Comedy'],
        'A drunken night in Vegas, a marriage certificate, and a business rival she can\'t afford to divorce before the merger.',
        rating: 9.0, views: 720000, chapters: 132, daysAgo: 2),
    _b(10, 'Triplets for the Billionaire', 'June Avery', 'Romance', ['Babies', 'Second Chance'],
        'Five years after one night with a stranger, Harper meets her new boss, and he has her triplets\' eyes.',
        rating: 9.3, views: 2600000, chapters: 302, completed: true, daysAgo: 60),
    _b(11, 'The Heiress Who Came Back', 'Sofia Grant', 'Romance', ['Hidden Identity', 'Face-Slapping'],
        'They mocked the quiet girl from the countryside. None of them knew she owned the building they worked in.',
        rating: 9.1, views: 980000, chapters: 145, daysAgo: 1),
    _b(12, 'Love Letters to a Stranger', 'Amelia Reed', 'Romance', ['Sweet', 'Slow Burn'],
        'A misdelivered letter starts a correspondence that neither writer wants to end, or reveal.',
        rating: 8.8, views: 150000, chapters: 52, daysAgo: 4),

    // ── Mafia ───────────────────────────────────────────────────────────────
    _b(13, 'Sworn to the Don', 'Vera Costa', 'Mafia', ['Dark Romance', 'Arranged Marriage'],
        'To pay her father\'s debt, Gia marries the most dangerous man in Palermo. He wants her loyalty. She wants out.',
        rating: 9.4, views: 2200000, chapters: 199, completed: true, daysAgo: 20),
    _b(14, 'The Mafia Heir\'s Hostage', 'Nina Ricci', 'Mafia', ['Captive', 'Possessive'],
        'Wrong place, wrong time, wrong man. Now she knows his face, and he can\'t let her go.',
        rating: 9.0, views: 860000, chapters: 120, daysAgo: 1),
    _b(15, 'Blood Oath in Velvet', 'Dante Moretti', 'Mafia', ['Revenge', 'Action'],
        'A widow, a ledger of names, and the family that killed her husband sitting at her dinner table.',
        rating: 9.2, views: 540000, chapters: 88, daysAgo: 0),
    _b(16, 'Taming the Boss\'s Daughter', 'Lucia Ferro', 'Mafia', ['Bodyguard', 'Comedy'],
        'His job: keep the don\'s reckless daughter alive. Her goal: make him quit by Friday.',
        rating: 8.9, views: 330000, chapters: 76, daysAgo: 2),

    // ── Fantasy ─────────────────────────────────────────────────────────────
    _b(17, 'Reborn Before the Apocalypse', 'Owen Pike', 'Fantasy', ['Rebirth', 'System'],
        'Ninety days before the world ends, Lin wakes up in his old dorm room with every memory of the end.',
        rating: 9.5, views: 1700000, chapters: 260, daysAgo: 0),
    _b(18, 'The Dragon King\'s Mortal Bride', 'Aria Flint', 'Fantasy', ['Dragons', 'Fated'],
        'Every hundred years the kingdom sends the dragon a bride. None have returned. This time, the bride has a plan.',
        rating: 9.3, views: 1300000, chapters: 180, completed: true, daysAgo: 15),
    _b(19, 'Witch of the Hollow Court', 'Iris Black', 'Fantasy', ['Magic', 'Court Intrigue'],
        'The fae court needs a witch to break a curse. The witch they kidnapped needs them to never find out she can.',
        rating: 9.0, views: 420000, chapters: 95, daysAgo: 3),
    _b(20, 'System: Villainess Survival Guide', 'Mei Lan', 'Fantasy', ['Transmigration', 'Comedy'],
        'She woke up as the villainess fated to die in chapter ten. The system says: survive, and maybe get a happy ending.',
        rating: 9.1, views: 760000, chapters: 140, daysAgo: 1),

    // ── Urban ───────────────────────────────────────────────────────────────
    _b(21, 'The Live-In Son-in-Law Rises', 'Marcus Lee', 'Urban', ['Hidden Identity', 'Face-Slapping'],
        'For three years the family treated him like a servant. Today the richest clan in the city came looking for its heir.',
        rating: 9.4, views: 4500000, chapters: 420, daysAgo: 0),
    _b(22, 'Divine Doctor in the City', 'Leo Shaw', 'Urban', ['Medicine', 'Martial Arts'],
        'Trained on a mountain for ten years, a young doctor returns to the city with one rule: never refuse a patient.',
        rating: 9.0, views: 1100000, chapters: 310, daysAgo: 1),
    _b(23, 'Return of the War God', 'Ryan Cole', 'Urban', ['Action', 'Revenge'],
        'He came home a general. His family thinks he is a failed soldier. Let them.',
        rating: 8.9, views: 870000, chapters: 275, daysAgo: 2),
    _b(24, 'Billion-Dollar Comeback', 'Ethan Park', 'Urban', ['Business', 'Rebirth'],
        'Bankrupt at thirty, reborn at eighteen, with ten years of market crashes memorised.',
        rating: 9.2, views: 690000, chapters: 160, daysAgo: 0),

    // ── Shorts (complete in a sitting or two) ───────────────────────────────
    _b(31, 'The Night He Chose Her', 'Hana Cole', 'Romance', ['Tragic Love', 'Regret'],
        'On our anniversary he left to comfort his first love. I left too, for good.',
        views: 9100, chapters: 12, completed: true, short: true, daysAgo: 0),
    _b(32, 'Thirty Days Before I Leave My Alpha', 'Willa Grey', 'Werewolf', ['Alpha', 'Winning Back'],
        'I gave the pack thirty days to notice I was packing. Nobody noticed. Until day thirty-one.',
        views: 7600, chapters: 10, completed: true, short: true, daysAgo: 0),
    _b(33, 'Their Spare Daughter', 'Poppy Lane', 'Romance', ['Family Drama', 'Plot Twist'],
        'My parents always had a favourite. The day they needed my kidney, they remembered my name.',
        views: 5300, chapters: 9, completed: true, short: true, daysAgo: 1),
    _b(34, 'I Faked My Death at Our Wedding', 'Rosa Kim', 'Mafia', ['Revenge', 'Fake Death'],
        'The don wanted a bride for the merger. He got a funeral instead, and a ghost with a plan.',
        views: 12400, chapters: 14, completed: true, short: true, daysAgo: 1),
    _b(35, 'The Nerd Who Won the Bet', 'Kit Moreno', 'Urban', ['Campus', 'Feel-Good'],
        'They bet I couldn\'t get a date to prom. I got the school\'s scholarship, the date, and the last laugh.',
        views: 5700, chapters: 8, completed: true, short: true, daysAgo: 2),
    _b(36, 'Moon City Without You', 'Dara Quinn', 'Werewolf', ['Childhood Sweethearts', 'Tragic Love'],
        'He promised to wait for me at the city gate. Ten winters later, I came back. He hadn\'t.',
        views: 8830, chapters: 11, completed: true, short: true, daysAgo: 2),
    _b(37, 'Office Survival Game', 'Jun Seo', 'Fantasy', ['System', 'Workplace'],
        'At 9:01 a.m. the whole office was pulled into a game. Only the intern had read the rules.',
        views: 15600, chapters: 15, completed: true, short: true, daysAgo: 3),
    _b(38, 'The Toast at My Own Funeral', 'Lily Shore', 'Romance', ['Rebirth', 'Revenge'],
        'Reborn the morning of my husband\'s promotion party, I prepared a speech everyone would remember.',
        views: 4200, chapters: 9, completed: true, short: true, daysAgo: 3),
    _b(39, 'He Said He Was Single', 'Bea Turner', 'Romance', ['Workplace', 'CEO'],
        'Three years of a secret relationship. One company party. One very public correction.',
        views: 3700, chapters: 7, completed: true, short: true, daysAgo: 4),
    _b(40, 'Cursed Alpha\'s Last Regret', 'Faye Wilde', 'Werewolf', ['Curse', 'Second Chance'],
        'The healer he rejected is the only one who can lift his curse. She has one condition.',
        views: 21600, chapters: 16, completed: true, short: true, daysAgo: 4),
  ];

  static const List<String> _paragraphs = [
    'Rain hammered against the tall windows, and the city lights smeared into long gold streaks across the glass. She stood very still, the way you stand when one wrong move will shatter everything.',
    '"You knew," she said quietly. It was not a question.',
    'He didn\'t answer at once. The silence stretched until it had weight, until she could feel it pressing on her shoulders like a hand.',
    'Somewhere below, a car horn sounded, ordinary and far away. It seemed impossible that the rest of the world was carrying on as if nothing had changed.',
    '"I was going to tell you," he finally said. "I was waiting for the right moment."',
    '"There is no right moment for this." She laughed, but there was no humour in it. "There never was."',
    'She picked up her coat. Her hands were steady, which surprised her. She had always imagined that this moment, if it came, would leave her shaking.',
    'At the door she paused, not because she expected him to stop her, but because she wanted to remember exactly how it felt to walk away first.',
    'The hallway was cold and smelled faintly of lilies from the vase someone replaced every Monday. She had never noticed before how much she hated lilies.',
    'By the time the elevator doors closed, she had already decided. Whatever came next, she would not be the one left waiting again.',
  ];

  /// Builds placeholder chapter text that varies a little per chapter.
  static String chapterText(BookModel book, int number) {
    final start = number % _paragraphs.length;
    final ordered = [..._paragraphs.sublist(start), ..._paragraphs.sublist(0, start)];
    final body = [...ordered, ...ordered.take(6)].join('\n\n');
    return '${book.title} continues.\n\n$body';
  }

  // ── Authors ──────────────────────────────────────────────────────────────
  static List<BookModel> booksBy(String author) => books.where((b) => b.author == author).toList();

  /// Stable fake follower count per author.
  static int followersOf(String author) => 800 + author.codeUnits.fold(0, (a, b) => a * 31 + b) % 9000;

  static String bioOf(String author) =>
      '$author writes ${booksBy(author).map((b) => b.genre).toSet().join(' and ').toLowerCase()} stories '
      'with big feelings and bigger twists. New chapters every week.';

  // ── Comments ─────────────────────────────────────────────────────────────
  static const _names = ['Nui', 'Michael', 'Marise', 'Ada', 'Chioma', 'Grace', 'Tolu', 'Jess', 'Kemi', 'Liam'];
  static const _texts = [
    'Couldn\'t put it down. Stayed up till 3am!',
    'The male lead finally got what he deserved 😤',
    'Wow this is nice',
    'Pleasant and easy to read.',
    'Please update faster, I need the next chapter!!',
    'The plot twist in chapter 8 got me screaming',
    'Slow start but it gets so good.',
    'Her character growth is everything 💗',
  ];

  /// Deterministic sample reviews for a book.
  static List<CommentModel> commentsFor(BookModel book) {
    final seed = book.coverSeed;
    final count = 4 + seed % 5;
    return List.generate(count, (i) {
      final k = seed + i * 7;
      return CommentModel(
        id: '${book.id}-c$i',
        bookId: book.id,
        userName: _names[k % _names.length],
        stars: 4 + (k % 3 == 0 ? 0 : 1),
        text: _texts[k % _texts.length],
        date: _now.subtract(Duration(days: 1 + i * 4 + k % 3)),
        likes: k % 40,
      );
    });
  }

  static const List<String> searchSuggestions = [
    'Alpha',
    'CEO',
    'Rebirth',
    'Divorce',
    'Mafia',
    'Second chance',
    'Revenge',
  ];
}
