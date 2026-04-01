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
//       await driver.enterText('test_example_com'.tr());
//
//       await driver.tap(passwordField);
//       await driver.enterText('test123'.tr());
//
//       await driver.tap(loginButton);
//
//       // Wait for login to complete
//       await driver.waitFor(find.byValueKey('home_page'));
//
//       // Navigate to shops
//       final shopsTab = find.byValueKey('shops_tab');
//       await driver.tap(shopsTab);
//
//       // Verify shops list appears
//       await driver.waitFor(find.byValueKey('shops_list'));
//
//       // Tap on first shop
//       final firstShop = find.byValueKey('shop_0');
//       await driver.tap(firstShop);
//
//       // Verify shop details page
//       await driver.waitFor(find.byValueKey('shop_details_page'));
//     });
//   });
// }
