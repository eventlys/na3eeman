import '../../Models/cart_model.dart';

class MockData {
  static List<CartItem> getCartItems() {
    return [
      CartItem(
        id: '1',
        name: 'Wireless Headphones',
        price: 99.99,
        imageUrl: 'https://picsum.photos/200/300?random=1',
        quantity: 2,
      ),
      CartItem(
        id: '2',
        name: 'Smart Watch',
        price: 199.99,
        imageUrl: 'https://picsum.photos/200/300?random=2',
        quantity: 1,
      ),
      CartItem(
        id: '3',
        name: 'Phone Case',
        price: 24.99,
        imageUrl: 'https://picsum.photos/200/300?random=3',
        quantity: 3,
      ),
    ];
  }

  static List<Product> getSuggestedProducts() {
    return [
      Product(
        id: '4',
        name: 'Bluetooth Speaker',
        price: 79.99,
        imageUrl: 'https://picsum.photos/200/300?random=4',
        description: 'Portable wireless speaker',
      ),
      Product(
        id: '5',
        name: 'USB-C Cable',
        price: 19.99,
        imageUrl: 'https://picsum.photos/200/300?random=5',
        description: 'Fast charging cable',
      ),
      Product(
        id: '6',
        name: 'Laptop Stand',
        price: 49.99,
        imageUrl: 'https://picsum.photos/200/300?random=6',
        description: 'Adjustable laptop stand',
      ),
      Product(
        id: '7',
        name: 'Wireless Mouse',
        price: 39.99,
        imageUrl: 'https://picsum.photos/200/300?random=7',
        description: 'Ergonomic wireless mouse',
      ),
    ];
  }
}
