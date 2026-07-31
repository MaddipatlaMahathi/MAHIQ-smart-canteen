import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../models/canteen_model.dart';

class CartItem {
  final MenuItemModel menuItem;
  int quantity;

  CartItem({required this.menuItem, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  CanteenModel? _selectedCanteen;
  String? _selectedSlot;

  Map<String, CartItem> get items => _items;
  CanteenModel? get selectedCanteen => _selectedCanteen;
  String? get selectedSlot => _selectedSlot;

  void setCanteenAndSlot(CanteenModel canteen, String slot) {
    // If canteen changes, clear cart
    if (_selectedCanteen?.canteenId != canteen.canteenId) {
      _items.clear();
    }
    _selectedCanteen = canteen;
    _selectedSlot = slot;
    notifyListeners();
  }

  void addItem(MenuItemModel item) {
    if (_items.containsKey(item.itemId)) {
      _items.update(
          item.itemId,
          (existingItem) => CartItem(
                menuItem: existingItem.menuItem,
                quantity: existingItem.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
        item.itemId,
        () => CartItem(menuItem: item, quantity: 1),
      );
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    if (!_items.containsKey(itemId)) return;

    if (_items[itemId]!.quantity > 1) {
      _items.update(
          itemId,
          (existingItem) => CartItem(
                menuItem: existingItem.menuItem,
                quantity: existingItem.quantity - 1,
              ));
    } else {
      _items.remove(itemId);
    }
    notifyListeners();
  }
  
  void deleteItemCompletely(String itemId) {
    _items.remove(itemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(
        0.0, (sum, item) => sum + (item.menuItem.price * item.quantity));
  }
}
