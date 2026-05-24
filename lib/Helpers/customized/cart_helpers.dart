import '../../Models/commerce/cart_model.dart';

class CartHelpers {
  static double calculateTotalPrice(List<CartItem> cartItems) {
    return cartItems.fold(0, (total, item) => total + item.totalPrice);
  }

  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static void increaseQuantity(CartItem item) {
    item.quantity++;
  }

  static void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    }
  }

  static void removeItem(List<CartItem> cartItems, String itemId) {
    cartItems.removeWhere((item) => item.id == itemId);
  }

  static void addToCart(List<CartItem> cartItems, Product product) {
    final existingItem = cartItems.firstWhere(
      (item) => item.id == product.id.toString(),
      orElse: () => CartItem(
        id: '',
        name: '',
        price: 0,
        imageUrl: '',
        type: '', // Added required 'type' parameter
        quantity: 0,
      ),
    );

    if (existingItem.id.isNotEmpty) {
      existingItem.quantity++;
    } else {
      cartItems.add(
        CartItem(
          id: product.id.toString(), // Convert int to String
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          type: 'PRODUCT', // Added required 'type' parameter
          itemId: product.id, // Added itemId for PRODUCT type
          quantity: 1,
        ),
      );
    }
  }
}
