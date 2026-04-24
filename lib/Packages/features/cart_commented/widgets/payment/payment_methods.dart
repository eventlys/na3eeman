// import 'package:na3eeman/l10n/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import '../../../Models/payment_method.dart';
// import 'cliq_payment_page.dart'; // Add this import
// import 'visa_payment_page.dart'; // Add this import
//
// class PaymentMethodService {
//   static Future<PaymentMethod?> showPaymentMethodDialog(BuildContext context) {
//     return showDialog<PaymentMethod>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Select Payment Method'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: PaymentMethod.values.map((method) {
//               return ListTile(
//                 leading: Icon(method.icon),
//                 title: Text(method.displayName),
//                 onTap: () => Navigator.of(context).pop(method),
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
//
//   static void handlePaymentSelection({
//     required BuildContext context,
//     required PaymentMethod method,
//     required String scheduleType,
//     required Function(String, String) onPaymentComplete,
//   }) {
//     switch (method) {
//       case PaymentMethod.cash:
//         _showCashConfirmation(context, scheduleType, onPaymentComplete);
//         break;
//       case PaymentMethod.cliq:
//         _navigateToCliqPayment(context, scheduleType, onPaymentComplete);
//         break;
//       case PaymentMethod.visa:
//         _navigateToVisaPayment(context, scheduleType, onPaymentComplete);
//         break;
//     }
//   }
//
//   static void _showCashConfirmation(
//     BuildContext context,
//     String scheduleType,
//     Function(String, String) onPaymentComplete,
//   ) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Cash Payment'),
//           content: const Text('Please bring cash at the time of your appointment.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text(AppLocalizations.of(context)!.cancel),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 onPaymentComplete(scheduleType, 'cash');
//               },
//               child: Text(AppLocalizations.of(context)!.confirm),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   static void _navigateToCliqPayment(
//     BuildContext context,
//     String scheduleType,
//     Function(String, String) onPaymentComplete,
//   ) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => CliqPaymentPage(
//           scheduleType: scheduleType,
//           onPaymentComplete: () => onPaymentComplete(scheduleType, 'cliq'),
//         ),
//       ),
//     );
//   }
//
//   static void _navigateToVisaPayment(
//     BuildContext context,
//     String scheduleType,
//     Function(String, String) onPaymentComplete,
//   ) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => VisaPaymentPage(
//           scheduleType: scheduleType,
//           onPaymentComplete: () => onPaymentComplete(scheduleType, 'visa'),
//         ),
//       ),
//     );
//   }
// }
//
