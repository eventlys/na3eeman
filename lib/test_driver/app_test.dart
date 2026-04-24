import 'package:na3eeman/l10n/app_localizations.dart';
// import 'package:flutter_driver/flutter_driver.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:test/test.dart';
//
// void main() {
//   group('Na3eeman App', () {
//     late FlutterDriver driver;
//
//     setUpAll(() async {
//       driver = await FlutterDriver.connect();
//     });
//
//     tearDownAll(() async {
//       if (driver != null) {
//         driver.close();
//       }
//     });
//
//     test('Complete user journey', () async {
//       // Login
//       final emailField = find.byValueKey('email_field');
//       final passwordField = find.byValueKey('password_field');
//       final loginButton = find.byValueKey('login_button');
//
//       await driver.tap(emailField);
//       await driver.enterText(AppLocalizations.of(context)!.testExampleCom);
//
//       await driver.tap(passwordField);
//       await driver.enterText(AppLocalizations.of(context)!.test123);
//
//       await driver.tap(loginButton);
//
//       // Wait for login to complete
//       await driver.waitFor(find.byValueKey('home_page'));
//
//       // Navigate to salons
//       final salonsTab = find.byValueKey('salons_tab');
//       await driver.tap(salonsTab);
//
//       // Verify salons list appears
//       await driver.waitFor(find.byValueKey('salons_list'));
//
//       // Tap on first salon
//       final firstSalon = find.byValueKey('salon_0');
//       await driver.tap(firstSalon);
//
//       // Verify salon details page
//       await driver.waitFor(find.byValueKey('salon_details_page'));
//     });
//   });
// }
