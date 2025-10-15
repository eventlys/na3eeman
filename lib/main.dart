import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:na3eeman/Language/config/config_lang.dart' show ConfigLanguage;
import 'package:na3eeman/Packages/view/Splash/Splash.dart';
import 'package:na3eeman/Routes/routes.dart';
import 'package:na3eeman/Theme/custom_them.dart' show CustomTheme;
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      child: EasyDynamicThemeWidget(
        child: const MyApp(),
      ),
      //* language
      supportedLocales: const [
        ConfigLanguage.EN_LOCALE,
        ConfigLanguage.AR_LOCALE,
      ],
      path: ConfigLanguage.LANG_PATH,
      fallbackLocale: ConfigLanguage.EN_LOCALE,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          //* name App
          title: "na3eeman",
          debugShowCheckedModeBanner: false,
          //* language
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          //* dark mode
          theme: CustomTheme.lightTheme,
          darkTheme: CustomTheme.darkTheme,
          themeMode: EasyDynamicTheme.of(context).themeMode,
          //* start page
          initialRoute: Splash.id,
          //* routes page
          routes: Routes.routes,
        );
      },
    );
  }
}
