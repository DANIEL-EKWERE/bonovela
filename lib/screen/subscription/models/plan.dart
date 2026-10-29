class SubscriptionPlan {
  final String id;
  final String name;
  final String price;
  final String? oldPrice;
  final String period; // shown under the price
  final String billing;
  final int days;
  final String? badge;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    this.oldPrice,
    required this.period,
    required this.billing,
    required this.days,
    this.badge,
  });

  static const all = [
    SubscriptionPlan(id: 'month', name: 'Monthly', price: '₦3,500', period: '/month', billing: 'Billed monthly', days: 30),
    SubscriptionPlan(
      id: 'week',
      name: 'Limited-Time Offer',
      price: '₦480',
      oldPrice: '₦1,600',
      period: '/week',
      billing: '₦480 for 7 days, then ₦1,600/week',
      days: 7,
      badge: '70% OFF',
    ),
    SubscriptionPlan(id: 'year', name: 'Yearly', price: '₦35,200', period: '/year', billing: 'Billed yearly', days: 365),
  ];
}
