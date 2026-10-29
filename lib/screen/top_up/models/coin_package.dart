class CoinPackage {
  final String id;
  final int coins;
  final int bonus;
  final int priceNaira;
  final String? tag; // "Popular", "Best value"

  const CoinPackage({
    required this.id,
    required this.coins,
    required this.bonus,
    required this.priceNaira,
    this.tag,
  });

  String get price => '₦${_thousands(priceNaira)}';

  static String _thousands(int n) => n.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => ',',
      );

  static const all = [
    CoinPackage(id: 'c100', coins: 100, bonus: 0, priceNaira: 800),
    CoinPackage(id: 'c300', coins: 300, bonus: 30, priceNaira: 2300),
    CoinPackage(id: 'c500', coins: 500, bonus: 75, priceNaira: 3800, tag: 'Popular'),
    CoinPackage(id: 'c1000', coins: 1000, bonus: 200, priceNaira: 7500),
    CoinPackage(id: 'c2000', coins: 2000, bonus: 500, priceNaira: 14500, tag: 'Best value'),
    CoinPackage(id: 'c5000', coins: 5000, bonus: 1500, priceNaira: 35000),
  ];
}
