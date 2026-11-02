class CoinPackage {
  final String id;
  final int coins;
  final int bonus;

  /// Price in US cents, to avoid floating-point money.
  final int priceCents;
  final String? tag; // e.g. "Limited-Time Offer"

  const CoinPackage({required this.id, required this.coins, required this.bonus, required this.priceCents, this.tag});

  String get price => '\$${(priceCents ~/ 100)}.${(priceCents % 100).toString().padLeft(2, '0')}';

  static const all = [
    CoinPackage(id: 'c50', coins: 50, bonus: 200, priceCents: 55, tag: 'Limited-Time Offer'),
    CoinPackage(id: 'c100', coins: 100, bonus: 0, priceCents: 105),
    CoinPackage(id: 'c500', coins: 500, bonus: 50, priceCents: 525),
    CoinPackage(id: 'c1000', coins: 1000, bonus: 200, priceCents: 1050),
    CoinPackage(id: 'c2000', coins: 2000, bonus: 600, priceCents: 2100),
    CoinPackage(id: 'c5000', coins: 5000, bonus: 2000, priceCents: 5250),
  ];
}
