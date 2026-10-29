import 'package:get/get.dart';

/// Placeholder legal copy. Replace with the reviewed documents before launch.
class LegalDocController extends GetxController {
  late final String title;

  @override
  void onInit() {
    super.onInit();
    title = Get.arguments as String;
  }

  List<(String, String)> get sections => switch (title) {
        'Privacy Policy' => const [
            ('What we collect', 'Your email, reading history, library and purchase records, so we can keep your place and sync your account.'),
            ('How we use it', 'To personalise recommendations, process purchases and improve the app. We never sell your personal data.'),
            ('Your choices', 'You can edit your profile, clear your history and delete your account at any time from Settings.'),
            ('Contact', 'privacy@bonovela.app'),
          ],
        'DMCA' => const [
            ('Reporting infringement', 'If you believe a story on Bonovela infringes your copyright, send a notice to dmca@bonovela.app with the work, the infringing link and your contact details.'),
            ('What happens next', 'We review every notice and remove infringing content promptly. Repeat infringers lose their author access.'),
          ],
        'Content Guidelines' => const [
            ('Be original', 'Only publish work you wrote or have the rights to.'),
            ('Age ratings', 'Mark mature themes accurately. Stories rated 18+ are hidden from younger readers.'),
            ('No hate or harassment', 'Stories and comments that target people for who they are will be removed.'),
          ],
        _ => const [
            ('Agreement', 'By using Bonovela you agree to these terms. If you don\'t agree, please don\'t use the app.'),
            ('Accounts', 'You\'re responsible for your account and for keeping your password safe.'),
            ('Coins and bonus', 'Coins are a licence to unlock content, not money, and can\'t be exchanged for cash. Bonus expires as shown in your wallet.'),
            ('Content', 'Stories belong to their authors. You may read them in the app but not copy or redistribute them.'),
            ('Changes', 'We may update these terms and will tell you in the app when we do.'),
          ],
      };
}
