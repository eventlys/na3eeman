// import 'package:flutter/material.dart';
// import '../../Models/cart_model.dart';
// import '../../Helpers/old/cart_helpers.dart';
//
//
// class CartItemWidget extends StatelessWidget {
//   final CartItem item;
//   final VoidCallback onIncrease;
//   final VoidCallback onDecrease;
//   final VoidCallback onRemove;
//
//   const CartItemWidget({
//     super.key,
//     required this.item,
//     required this.onIncrease,
//     required this.onDecrease,
//     required this.onRemove,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             // Product Image
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 item.imageUrl,
//                 width: 80,
//                 height: 80,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             const SizedBox(width: 16),
//
//             // Product Details and Quantity Controls
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     item.name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     CartHelpers.formatPrice(item.price),
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.green,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//
//                   // Quantity Controls
//                   Row(
//                     children: [
//                       // Decrease Button
//                       IconButton(
//                         onPressed: onDecrease,
//                         icon: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: const Icon(Icons.remove, size: 16),
//                         ),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       ),
//
//                       // Quantity Display
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           item.quantity.toString(),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//
//                       // Increase Button
//                       IconButton(
//                         onPressed: onIncrease,
//                         icon: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: const Icon(Icons.add, size: 16),
//                         ),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       ),
//
//                       const Spacer(),
//
//                       // Total Price
//                       Text(
//                         CartHelpers.formatPrice(item.totalPrice),
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             // Remove Button
//             IconButton(
//               onPressed: onRemove,
//               icon: const Icon(Icons.delete_outline, color: Colors.red),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
