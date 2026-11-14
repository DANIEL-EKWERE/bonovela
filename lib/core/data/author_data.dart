/// Fixed option lists for the author tools (mock until the backend serves them).
class AuthorData {
  static const languages = ['English'];

  static const novelTypes = ['Original', 'Fan-fiction', 'Translation'];

  static const ratings = ['4+', '12+', '16+', '18+'];

  /// Shown under the rating chips.
  static const ratingInfo = {
    '4+': ('All', 'Content for readers of all ages.'),
    '12+': (
      'Youth and above',
      'Inappropriate content for readers under 13 with light violence, kissing, light cursing, but not too explicit.',
    ),
    '16+': (
      'Mature',
      'Content involving violence, sex, alcohol or gambling but not too explicitly. May occur in limited chapters.',
    ),
    '18+': ('Explicit', 'Content involving sex or violence, taking up to 20% of the book would be considered 18+.'),
  };

  static const genres = [
    'Romance',
    'Werewolf',
    'Mafia',
    'System',
    'Fantasy',
    'LGBTQ+',
    'Erotic',
    'YA/TEEN',
    'Paranormal',
    'Mystery/Thriller',
    'Games',
    'MM Romance',
    'Sci-Fi',
    'War',
    'Other',
  ];

  static const tagGroups = <String, (String, List<String>)>{
    'Style': (
      '"Style" refers to the tags that match the style of the work.',
      [
        'Action',
        'Adventurous',
        'Comedy',
        'Contemporary',
        'Dark Romance',
        'Drama',
        'Eastern',
        'Fast-Paced Plot',
        'First-Person POV',
        'Girl Power',
        'Mystery',
        'Sweet Love',
        'Third-Person POV',
        'Tragedy',
        'Werewolf',
        'Xianxia',
        'Familial Bond',
        'Exclusive Love',
        'Survival Game',
        'Finance',
        'Fake and Real Heir',
        'Winning Back the Wife',
        'Prison Break',
        'Mecha',
        'Witch',
      ],
    ),
    'Character': (
      '"Character" refers to the identity or characteristics of the protagonists of the work.',
      [
        'Actor / Actress',
        'Agent',
        'Alpha',
        'Angel',
        'Arrogant',
        'Artist',
        'Badboy',
        'Badgirl',
        'Beast',
        'Beta',
        'Bully',
        'CEO',
        'Demon',
        'Detective',
        'Doctor',
        'Dominant',
        'Dragon',
        'Gamer',
        'Genius Baby',
        'Golden Boy',
        'Goodgirl',
        'Heir/Heiress',
        'Hero/Heroin',
        'Hidden Identity',
        'Hunter',
        'Hybrid',
        'Independent',
        'Intelligent',
        'Lawyer',
        'Luna',
        'Lycan',
        'Mafia',
        'Medical Genius',
        'Nanny',
        'Omega',
        'Playboy',
        'Police',
        'Professor',
        'Rebel',
        'Rogue',
        'Ruthless',
        'Secretary',
        'Slave',
        'Star',
        'Teenager',
        'Triplets',
        'Twins',
        'Vampire',
        'Warrior',
        'Witch / Wizard',
        'God of War',
        'Beastman',
        'Widow',
        'Possessive',
        'Protective',
        'Optimism',
        'Victim',
        'Paranoid',
        'Decisive',
        'Brave',
        'Sister-in-law',
      ],
    ),
    'Setting': (
      '"Setting" refers to the tags that match the main plot setting of the work.',
      [
        'Affair',
        'Age Gap',
        'Alternate Universe',
        'Apocalypse',
        'Betrayal',
        'Blind Date',
        'Campus',
        'Contract Marriage',
        'Cultivation',
        'Divorce',
        'Face-Slapping',
        'First Love',
        'Flash Marriage',
        'Forbidden Love',
        'Forgiveness',
        'Gay for you',
        'Golden Finger',
        'Harem',
        'Hate to Love',
        'Immortal Hero',
        'Incredible Son-in-Law',
        'Instant Billionaire',
        'Kingdom Building',
        'Level up',
        'Lit-RPG',
        'Love after Marriage',
        'Love at First Sight',
        'Love-Triangle',
        'Lovers Reunion',
        'Misunderstanding',
        'Office Relationship',
        'Pregnant',
        'Reborn',
        'Regret',
        'Reject',
        'Revenge',
        'Reverse Harem',
        'Royal',
        'Runaway Bride/Groom',
        'Runaway with a Baby',
        'Second Chance',
        'Secret Love',
        'Sports',
        'Substitute Bride',
        'Superpower',
        'Twist',
        'Twisted',
        'Weak to Strong',
        'System',
        'Pampered by All',
        'Post-apocalyptic',
        'Succubus',
        'Terminal Illness Countdown',
        'Death Countdown',
      ],
    ),
  };

  /// Writing contests authors can enter from Novel Information.
  static const contests = [
    Contest(
      id: 'c55',
      title: '#55 They Regret Losing Me, Too Late!',
      prize: '\$1,200',
      deadline: '2026-12-15',
      brief: 'Stories where the one who walked away realises too late what they lost.',
    ),
    Contest(
      id: 'c54',
      title: '#54 The Queen Stands Unconquered',
      prize: '\$1,200',
      deadline: '2026-11-30',
      brief: 'A heroine who rises after everyone counted her out.',
    ),
    Contest(
      id: 'c53',
      title: '#53 Moonlit Bonds',
      prize: '\$800',
      deadline: '2026-11-20',
      brief: 'Werewolf and paranormal romance with fated mates and pack politics.',
    ),
  ];

  /// Senior Editors an author can choose when applying for a contract:
  /// (id, name, on the Short Stories desk). Matches the demo backend accounts.
  static const editors = [
    ('se', 'Seun (SE)', false),
    ('se2', 'Bisi (SE)', false),
    ('se3', 'Amara (SE)', false),
    ('se4', 'Tomi (SE)', false),
    ('se5', 'Kemi (SE)', true),
  ];

  /// Income categories on the Income tab, with their card colours (all one orange).
  static const incomeTypes = [
    ('Profit Share', 0xFFFFC23D, 0xFFFF8A1F),
    ('Available to withdraw', 0xFFFFC23D, 0xFFFF8A1F),
    ('One-time Payment', 0xFFFFC23D, 0xFFFF8A1F),
    ('Others', 0xFFFFC23D, 0xFFFF8A1F),
    ('Carry over', 0xFFFFC23D, 0xFFFF8A1F),
    ('Reward Share', 0xFFFFC23D, 0xFFFF8A1F),
    ('Short Story Subscription', 0xFFFFC23D, 0xFFFF8A1F),
  ];
}

class Contest {
  final String id;
  final String title;
  final String prize;
  final String deadline;
  final String brief;

  const Contest({
    required this.id,
    required this.title,
    required this.prize,
    required this.deadline,
    required this.brief,
  });
}
