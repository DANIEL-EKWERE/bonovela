/// A gift a reader can send to a book. Each gift also sends [votes] to the
/// book (the "+N" badge).
class GiftItem {
  final String id;
  final String name;
  final String emoji;
  final int price; // coins
  final int votes;

  const GiftItem(this.id, this.name, this.emoji, this.price, this.votes);

  static const all = [
    GiftItem('donut', 'Donut', '🍩', 100, 1),
    GiftItem('burger', 'Hamburger', '🍔', 200, 2),
    GiftItem('cake', 'Cake', '🎂', 500, 6),
    GiftItem('bouquet', 'Bouquet', '💐', 1000, 15),
    GiftItem('ring', 'Diamond Ring', '💍', 1888, 26),
    GiftItem('crown', 'Crown', '👑', 5000, 68),
  ];
}
