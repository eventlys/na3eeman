// import 'package:flutter/material.dart';
// import '../../../Helpers/customized/cart_helpers.dart';
// import '../../../Models/commerce/cart_model.dart';
// import '../../Core/backgrounds/bd_faded.dart';
//
// class CartPage extends StatefulWidget {
//   const CartPage({super.key});
//
//   @override
//   State<CartPage> createState() => _CartPageState();
// }
//
// class _CartPageState extends State<CartPage> {
//   List<CartItem> cartItems = MockData.getCartItems();
//   List<Product> suggestedProducts = MockData.getSuggestedProducts();
//
//   bool _homeActive = false;
//   bool _settingsActive = true;
//   bool _profileActive = false;
//   bool _infoActive = false;
//   bool _searchActive = false;
//
//   void _increaseQuantity(int index) {
//     setState(() {
//       CartHelpers.increaseQuantity(cartItems[index]);
//     });
//   }
//
//   void _decreaseQuantity(int index) {
//     setState(() {
//       CartHelpers.decreaseQuantity(cartItems[index]);
//     });
//   }
//
//   void _removeItem(int index) {
//     setState(() {
//       cartItems.removeAt(index);
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Item removed from cart')),
//     );
//   }
//
//   void _addSuggestedToCart(Product product) {
//     setState(() {
//       CartHelpers.addToCart(cartItems, product);
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('${product.name} added to cart')),
//     );
//   }
//
//   void _checkout() {
//     if (cartItems.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Your cart is empty')),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Checkout'),
//         content: Text(
//             'Total: ${CartHelpers.formatPrice(CartHelpers.calculateTotalPrice(cartItems))}'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               setState(() {
//                 cartItems.clear();
//               });
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Order placed successfully!')),
//               );
//             },
//             child: const Text('Confirm'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final totalPrice = CartHelpers.calculateTotalPrice(cartItems);
//     final mediaQuery = MediaQuery.of(context);
//
//     return FadedBackground(
//       startColor: const Color(0xffffffff),
//       endColor: const Color(0xFFDFA8A4),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: CustomScrollView(
//           slivers: [
//             GlassSliverAppBar(
//               title: 'Shopping Cart',
//               backgroundColor: Colors.transparent,
//             ),
//             SliverToBoxAdapter(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: mediaQuery.size.height -
//                             mediaQuery.padding.top -
//                             kToolbarHeight,
//                 ),
//                 child: Column(
//                   children: [
//                     // Cart Items Section
//                     if (cartItems.isEmpty)
//                       SizedBox(
//                         height: mediaQuery.size.height * 0.4,
//                         child: const Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.shopping_cart_outlined,
//                                   size: 64, color: Colors.grey),
//                               SizedBox(height: 16),
//                               Text(
//                                 'Your cart is empty',
//                                 style: TextStyle(fontSize: 18, color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                     else
//                       Column(
//                         children: [
//                           ...cartItems.asMap().entries.map((entry) {
//                             final index = entry.key;
//                             final item = entry.value;
//                             return CartItemWidget(
//                               item: item,
//                               onIncrease: () => _increaseQuantity(index),
//                               onDecrease: () => _decreaseQuantity(index),
//                               onRemove: () => _removeItem(index),
//                             );
//                           }),
//
//                           // Checkout Section
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             margin: const EdgeInsets.only(top: 16),
//                             decoration: BoxDecoration(
//                               color: Color(0x80ffffff),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withValues(alpha: 0.2), // Fixed: withOpacity instead of withValues
//                                   blurRadius: 4,
//                                   offset: const Offset(0, -2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     const Text(
//                                       'Total:',
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       CartHelpers.formatPrice(totalPrice),
//                                       style: const TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xffc25858),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton(
//                                     onPressed: _checkout,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Color(0x802ffda2),
//                                       padding: const EdgeInsets.symmetric(vertical: 16),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                     ),
//                                     child: const Text(
//                                       'Checkout',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//
//                     // Suggested Products Section
//                     const Padding(
//                       padding: EdgeInsets.all(10),
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Suggested Items',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 250,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: suggestedProducts.length,
//                         itemBuilder: (context, index) {
//                           final product = suggestedProducts[index];
//                           return SuggestedProductWidget(
//                             product: product,
//                             onAddToCart: () => _addSuggestedToCart(product),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 16), // Bottom padding
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: Padding(
//           padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
//           child: Container(
//             height: 90,
//             decoration: BoxDecoration(
//               color: const Color(0xFFC25858),
//               borderRadius: BorderRadius.circular(30),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.7),
//                   blurRadius: 10,
//                   offset: const Offset(5, 5),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 NeomorphicSphere(
//                   activeIconPath: 'assets/icons/home_view.png',
//                   inactiveIconPath: 'assets/icons/home_front.png',
//                   size: 80,
//                   navigationRoute: '/home',
//                   isActive: _homeActive,
//                   onTap: () {
//                     print('Home sphere tapped');
//                     setState(() {
//                       _homeActive = true;
//                       _settingsActive = false;
//                       _profileActive = false;
//                       _infoActive = false;
//                       _searchActive = false;
//                     });
//                   },
//                   onActiveChanged: (active) {
//                     if (active) {
//                       setState(() {
//                         _homeActive = true;
//                         _settingsActive = false;
//                         _profileActive = false;
//                         _infoActive = false;
//                         _searchActive = false;
//                       });
//                     }
//                   },
//                 ),
//                 NeomorphicSphere(
//                   activeIconPath: 'assets/icons/flash_view.png',
//                   inactiveIconPath: 'assets/icons/flash.png',
//                   size: 80,
//                   navigationRoute: '/settings',
//                   isActive: _settingsActive,
//                   onTap: () {
//                     print('Settings sphere tapped');
//                     setState(() {
//                       _homeActive = false;
//                       _settingsActive = true;
//                       _profileActive = false;
//                       _infoActive = false;
//                       _searchActive = false;
//                     });
//                   },
//                   onActiveChanged: (active) {
//                     if (active) {
//                       setState(() {
//                         _homeActive = false;
//                         _settingsActive = true;
//                         _profileActive = false;
//                         _infoActive = false;
//                         _searchActive = false;
//                       });
//                     }
//                   },
//                 ),
//                 NeomorphicSphere(
//                   activeIconPath: 'assets/icons/fire_view.png',
//                   inactiveIconPath: 'assets/icons/fire.png',
//                   size: 80,
//                   navigationRoute: '/profile',
//                   isActive: _profileActive,
//                   onTap: () {
//                     print('Profile sphere tapped');
//                     setState(() {
//                       _homeActive = false;
//                       _settingsActive = false;
//                       _profileActive = true;
//                       _infoActive = false;
//                       _searchActive = false;
//                     });
//                   },
//                   onActiveChanged: (active) {
//                     if (active) {
//                       setState(() {
//                         _homeActive = false;
//                         _settingsActive = false;
//                         _profileActive = true;
//                         _infoActive = false;
//                         _searchActive = false;
//                       });
//                     }
//                   },
//                 ),
//                 NeomorphicSphere(
//                   activeIconPath: 'assets/icons/clock_view.png',
//                   inactiveIconPath: 'assets/icons/clock.png',
//                   size: 80,
//                   isActive: _infoActive,
//                   onTap: () {
//                     Navigator.pushNamed(context, '/appointments');
//                     setState(() {
//                       _homeActive = false;
//                       _settingsActive = false;
//                       _profileActive = false;
//                       _infoActive = true;
//                       _searchActive = false;
//                     });
//                   },
//                   onActiveChanged: (active) {
//                     if (active) {
//                       setState(() {
//                         _homeActive = false;
//                         _settingsActive = false;
//                         _profileActive = false;
//                         _infoActive = true;
//                         _searchActive = false;
//                       });
//                     }
//                   },
//                 ),
//                 NeomorphicSphere(
//                   activeIconPath: 'assets/icons/avatar_male_view.png',
//                   inactiveIconPath: 'assets/icons/avatar_male.png',
//                   size: 80,
//                   isActive: _searchActive,
//                   onTap: () {
//                     Navigator.pushNamed(context, '/profile');
//                     setState(() {
//                       _homeActive = false;
//                       _settingsActive = false;
//                       _profileActive = false;
//                       _infoActive = false;
//                       _searchActive = true;
//                     });
//                   },
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
