import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'config/local_storage.dart';
import 'config/routes.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'core/api/api_client.dart';
import 'core/api/storage_tokens.dart';
import 'core/repository/api_book_repository.dart';
import 'core/repository/book_repository.dart';
import 'core/repository/mock_book_repository.dart';
import 'core/services/account_service.dart';
import 'core/services/ads_service.dart';
import 'core/services/author_service.dart';
import 'core/services/drama_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await Get.putAsync<LocalStorage>(() => LocalStorage().init(), permanent: true);
  // The backend client exists only when there is a backend; services fall
  // back to sample data without it.
  final api = AppConstants.apiUrl.isEmpty ? null : Get.put(ApiClient(tokens: StorageTokens(storage)), permanent: true);
  await Get.putAsync<AccountService>(() => AccountService().init(), permanent: true);
  Get.find<AccountService>().refreshUser();
  Get.put<AuthorService>(AuthorService().init(), permanent: true);
  Get.put<DramaService>(DramaService().init(), permanent: true);
  Get.put<AdsService>(AdsService(), permanent: true);
  Get.put<BookRepository>(api == null ? MockBookRepository() : ApiBookRepository(api), permanent: true);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const BonovelaApp());
}

class BonovelaApp extends StatelessWidget {
  const BonovelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
