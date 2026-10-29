import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'config/local_storage.dart';
import 'config/routes.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/app_theme.dart';
import 'core/repository/book_repository.dart';
import 'core/repository/mock_book_repository.dart';
import 'core/services/account_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Get.putAsync<LocalStorage>(() => LocalStorage().init(), permanent: true);
  await Get.putAsync<AccountService>(() => AccountService().init(), permanent: true);
  Get.put<BookRepository>(MockBookRepository(), permanent: true);

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
