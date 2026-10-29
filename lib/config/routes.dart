import 'package:get/get.dart';

import 'auth_middleware.dart';

import '../screen/auth/auth_screen.dart';
import '../screen/auth/bindings/auth_binding.dart';
import '../screen/auth_email/auth_email_screen.dart';
import '../screen/auth_email/bindings/auth_email_binding.dart';
import '../screen/author_center/author_center_screen.dart';
import '../screen/author_center/bindings/author_center_binding.dart';
import '../screen/author_profile/author_profile_screen.dart';
import '../screen/author_profile/bindings/author_profile_binding.dart';
import '../screen/auto_subscription/auto_subscription_screen.dart';
import '../screen/auto_subscription/bindings/auto_subscription_binding.dart';
import '../screen/bonus_history/bindings/bonus_history_binding.dart';
import '../screen/bonus_history/bonus_history_screen.dart';
import '../screen/book_detail/bindings/book_detail_binding.dart';
import '../screen/book_detail/book_detail_screen.dart';
import '../screen/categories/bindings/categories_binding.dart';
import '../screen/categories/categories_screen.dart';
import '../screen/chapter_unlocked/bindings/chapter_unlocked_binding.dart';
import '../screen/chapter_unlocked/chapter_unlocked_screen.dart';
import '../screen/comments/bindings/comments_binding.dart';
import '../screen/comments/comments_screen.dart';
import '../screen/edit_profile/bindings/edit_profile_binding.dart';
import '../screen/edit_profile/edit_profile_screen.dart';
import '../screen/exchange/bindings/exchange_binding.dart';
import '../screen/exchange/exchange_screen.dart';
import '../screen/expense_record/bindings/expense_record_binding.dart';
import '../screen/expense_record/expense_record_screen.dart';
import '../screen/follow_list/bindings/follow_list_binding.dart';
import '../screen/follow_list/follow_list_screen.dart';
import '../screen/gems/bindings/gems_binding.dart';
import '../screen/gems/gems_screen.dart';
import '../screen/inbox/bindings/inbox_binding.dart';
import '../screen/inbox/inbox_screen.dart';
import '../screen/language/bindings/language_binding.dart';
import '../screen/language/language_screen.dart';
import '../screen/legal_doc/bindings/legal_doc_binding.dart';
import '../screen/legal_doc/legal_doc_screen.dart';
import '../screen/main/bindings/main_binding.dart';
import '../screen/main/main_screen.dart';
import '../screen/onboarding/bindings/onboarding_binding.dart';
import '../screen/onboarding/onboarding_screen.dart';
import '../screen/online_service/bindings/online_service_binding.dart';
import '../screen/online_service/online_service_screen.dart';
import '../screen/push_settings/bindings/push_settings_binding.dart';
import '../screen/push_settings/push_settings_screen.dart';
import '../screen/reader/bindings/reader_binding.dart';
import '../screen/reader/reader_screen.dart';
import '../screen/rewards/bindings/rewards_binding.dart';
import '../screen/rewards/rewards_screen.dart';
import '../screen/search/bindings/search_binding.dart';
import '../screen/search/search_screen.dart';
import '../screen/settings/bindings/settings_binding.dart';
import '../screen/settings/settings_screen.dart';
import '../screen/sign_in/bindings/sign_in_binding.dart';
import '../screen/sign_in/sign_in_screen.dart';
import '../screen/sign_up/bindings/sign_up_binding.dart';
import '../screen/sign_up/sign_up_screen.dart';
import '../screen/splash/bindings/splash_binding.dart';
import '../screen/splash/splash_screen.dart';
import '../screen/subscription/bindings/subscription_binding.dart';
import '../screen/subscription/subscription_screen.dart';
import '../screen/terms_policy/bindings/terms_policy_binding.dart';
import '../screen/terms_policy/terms_policy_screen.dart';
import '../screen/top_up/bindings/top_up_binding.dart';
import '../screen/top_up/top_up_screen.dart';
import '../screen/transaction_history/bindings/transaction_history_binding.dart';
import '../screen/transaction_history/transaction_history_screen.dart';
import '../screen/verify_email/bindings/verify_email_binding.dart';
import '../screen/verify_email/verify_email_screen.dart';
import '../screen/view_all/bindings/view_all_binding.dart';
import '../screen/view_all/view_all_screen.dart';
import '../screen/wallet/bindings/wallet_binding.dart';
import '../screen/wallet/wallet_screen.dart';

class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const main = '/main'; // arguments: {'tab': int} (optional)

  // Auth flow
  static const login = '/login'; // sign-in landing
  static const authEmail = '/auth_email';
  static const signUp = '/sign_up'; // arguments: email
  static const verifyEmail = '/verify_email'; // arguments: email
  static const signIn = '/sign_in'; // arguments: email

  static const _authFlow = {login, authEmail, signUp, verifyEmail, signIn};

  /// Pops every auth screen and returns to where sign-in was started.
  static void closeAuth() => Get.until((r) => !_authFlow.contains(r.settings.name));

  // Books
  static const bookDetail = '/book_detail'; // arguments: book id
  static const reader = '/reader'; // arguments: {'bookId': String, 'chapter': int}
  static const comments = '/comments'; // arguments: book id
  static const search = '/search';
  static const categories = '/categories';
  static const viewAll = '/view_all'; // arguments: {'title': String, 'books': List<BookModel>}
  static const authorProfile = '/author_profile'; // arguments: author name

  // Profile
  static const editProfile = '/edit_profile';
  static const followList = '/follow_list'; // arguments: initial tab index
  static const inbox = '/inbox';
  static const authorCenter = '/author_center';
  static const exchange = '/exchange';
  static const gems = '/gems';

  // Wallet
  static const wallet = '/wallet';
  static const topUp = '/top_up';
  static const transactionHistory = '/transaction_history';
  static const bonusHistory = '/bonus_history';
  static const chapterUnlocked = '/chapter_unlocked';
  static const expenseRecord = '/expense_record';
  static const autoSubscription = '/auto_subscription';
  static const rewards = '/rewards';
  static const subscription = '/subscription';

  // Support & settings
  static const onlineService = '/online_service';
  static const settings = '/settings';
  static const language = '/language';
  static const pushSettings = '/push_settings';
  static const termsPolicy = '/terms_policy';
  static const legalDoc = '/legal_doc'; // arguments: document title

  static final List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashScreen(), binding: SplashBinding()),
    // Library, Discover, Short, Rank and Profile live inside main; their
    // controllers are registered by MainBinding.
    GetPage(name: main, page: () => const MainScreen(), binding: MainBinding()),
    GetPage(name: onboarding, page: () => const OnboardingScreen(), binding: OnboardingBinding()),
    GetPage(name: login, page: () => const AuthScreen(), binding: AuthBinding(), fullscreenDialog: true),
    GetPage(name: authEmail, page: () => const AuthEmailScreen(), binding: AuthEmailBinding()),
    GetPage(name: signUp, page: () => const SignUpScreen(), binding: SignUpBinding()),
    GetPage(name: verifyEmail, page: () => const VerifyEmailScreen(), binding: VerifyEmailBinding()),
    GetPage(name: signIn, page: () => const SignInScreen(), binding: SignInBinding()),

    GetPage(
      name: bookDetail,
      page: () => BookDetailScreen(bookId: Get.arguments as String),
      binding: BookDetailBinding(),
    ),
    GetPage(name: reader, page: () => const ReaderScreen(), binding: ReaderBinding()),
    GetPage(name: comments, page: () => const CommentsScreen(), binding: CommentsBinding()),
    GetPage(
      name: search,
      page: () => const SearchScreen(),
      binding: SearchBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(name: categories, page: () => const CategoriesScreen(), binding: CategoriesBinding()),
    GetPage(name: viewAll, page: () => const ViewAllScreen(), binding: ViewAllBinding()),
    GetPage(
      name: authorProfile,
      page: () => AuthorProfileScreen(author: Get.arguments as String),
      binding: AuthorProfileBinding(),
    ),

    GetPage(
      name: editProfile,
      page: () => const EditProfileScreen(),
      binding: EditProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: followList, page: () => const FollowListScreen(), binding: FollowListBinding()),
    GetPage(name: inbox, page: () => const InboxScreen(), binding: InboxBinding()),
    GetPage(
      name: authorCenter,
      page: () => const AuthorCenterScreen(),
      binding: AuthorCenterBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: exchange,
      page: () => const ExchangeScreen(),
      binding: ExchangeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(name: gems, page: () => const GemsScreen(), binding: GemsBinding()),

    GetPage(name: wallet, page: () => const WalletScreen(), binding: WalletBinding()),
    GetPage(name: topUp, page: () => const TopUpScreen(), binding: TopUpBinding()),
    GetPage(
      name: transactionHistory,
      page: () => const TransactionHistoryScreen(),
      binding: TransactionHistoryBinding(),
    ),
    GetPage(name: bonusHistory, page: () => const BonusHistoryScreen(), binding: BonusHistoryBinding()),
    GetPage(name: chapterUnlocked, page: () => const ChapterUnlockedScreen(), binding: ChapterUnlockedBinding()),
    GetPage(name: expenseRecord, page: () => const ExpenseRecordScreen(), binding: ExpenseRecordBinding()),
    GetPage(
      name: autoSubscription,
      page: () => const AutoSubscriptionScreen(),
      binding: AutoSubscriptionBinding(),
    ),
    GetPage(name: rewards, page: () => const RewardsScreen(), binding: RewardsBinding()),
    GetPage(name: subscription, page: () => const SubscriptionScreen(), binding: SubscriptionBinding()),

    GetPage(name: onlineService, page: () => const OnlineServiceScreen(), binding: OnlineServiceBinding()),
    GetPage(name: settings, page: () => const SettingsScreen(), binding: SettingsBinding()),
    GetPage(name: language, page: () => const LanguageScreen(), binding: LanguageBinding()),
    GetPage(name: pushSettings, page: () => const PushSettingsScreen(), binding: PushSettingsBinding()),
    GetPage(name: termsPolicy, page: () => const TermsPolicyScreen(), binding: TermsPolicyBinding()),
    GetPage(name: legalDoc, page: () => const LegalDocScreen(), binding: LegalDocBinding()),
  ];
}
