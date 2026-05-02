// import 'package:flutter/material.dart';
import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/salon/cart_item_model.dart';
import '../../Models/salon/salon_service_model.dart';

class CartProvider extends BaseProvider {
  final List<CartItem> _items = [];
  AuthProvider? _authProvider;

  // Getters
  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  double get totalPrice =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isCartEmpty => _items.isEmpty;

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true) {
      clearCart();
    }
  }

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void addService(SalonService service) {
    final cartItem = CartItem(
      id: '${service.type}_${service.id}',
      name: service.name,
      price: double.parse(service.price.replaceAll('\$', '')),
      type: service.type,
      itemId: service.id?.toString() ?? '',
      duration: service.duration,
      description: service.description ?? '',
    );

    addItem(cartItem);
  }
}
