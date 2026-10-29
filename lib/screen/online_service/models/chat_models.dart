class ChatMessage {
  final String text;
  final bool fromUser;
  final DateTime? time; // null for the typing indicator

  const ChatMessage(this.text, {required this.fromUser, required this.time});
}

class Faq {
  final String question;
  final String answer;

  const Faq(this.question, this.answer);

  static const Map<String, List<Faq>> byTopic = {
    'Payment issue': [
      Faq('I didn\'t receive coins after paying',
          'Coins usually arrive within a minute. Pull down on your wallet to refresh. If they still haven\'t arrived after 30 minutes, send us your receipt and we\'ll add them manually.'),
      Faq('How do I cancel my subscription?',
          'Open your device\'s store account settings → Subscriptions → Bonovela Plus → Cancel. You keep access until the end of the paid period.'),
      Faq('I paid for Plus but stories are still locked',
          'Plus covers short stories. Novel chapters are still unlocked with coins. If a short story is locked, go to Profile → Subscription and tap Restore purchases.'),
      Faq('Can I get a refund?',
          'Refunds are handled by the store you paid through. Contact them with your order number and we\'ll support the request.'),
    ],
    'Rewards issue': [
      Faq('My bonus disappeared',
          'Bonus expires. Check Wallet → Bonus Receipt & Expiry History to see when each batch expired or was used.'),
      Faq('Check-in streak reset',
          'The streak resets if you miss a day. It also starts again after you collect all seven days.'),
      Faq('Reading time isn\'t counting',
          'Reading time counts while the reader is open on a chapter. Leaving the app pauses it.'),
    ],
    'Product issue': [
      Faq('How do I change the text size?',
          'In the reader, tap the middle of the page, then Settings. You can change size, spacing, font and page colour.'),
      Faq('Where are my saved books?',
          'Tap Library at the bottom left. Long-press a book to remove it.'),
      Faq('Login failed using Facebook',
          'Make sure the Facebook app is up to date, or sign in with email instead. Your library stays on this device either way.'),
    ],
  };
}
