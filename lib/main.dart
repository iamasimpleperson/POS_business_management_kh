import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:business_management_kh/routes/appRoute.dart';
import 'package:business_management_kh/core/localizations/app_translations.dart';
import 'package:business_management_kh/core/localizations/language_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageController = Get.put(LanguageController(), permanent: true);
  await languageController.initLanguage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = LanguageController.to;

    return GetMaterialApp.router(
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: languageController.currentLocale.value,
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: const [Locale('km', 'KH'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routeInformationProvider: AppRoute.router.routeInformationProvider,
      routeInformationParser: AppRoute.router.routeInformationParser,
      routerDelegate: AppRoute.router.routerDelegate,
      backButtonDispatcher: AppRoute.router.backButtonDispatcher,
    );
  }
}
