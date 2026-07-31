import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import 'cart_provider.dart';
import 'canteen_provider.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;
  
  bool get isProcessing => _isProcessing;

  Future<String?> placeOrder(
    UserModel user, 
    CartProvider cart, 
    CanteenProvider canteenProvider, {
    String paymentMethod = 'Online Payment',
    String paymentStatus = 'Pending',
    String? paymentId,
    String? razorpayOrderId,
  }) async {
    if (cart.selectedCanteen == null || cart.selectedSlot == null || cart.items.isEmpty) {
      return null;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      List<Map<String, dynamic>> orderItemsList = cart.items.values.map((item) {
        return {
          'itemId': item.menuItem.itemId,
          'itemName': item.menuItem.itemName,
          'price': item.menuItem.price,
          'quantity': item.quantity,
        };
      }).toList();

      OrderModel newOrder = OrderModel(
        orderId: '', // generated in service
        userId: user.userId,
        userName: user.name,
        canteenId: cart.selectedCanteen!.canteenId,
        canteenName: cart.selectedCanteen!.canteenName,
        slot: cart.selectedSlot!,
        queueNumber: 0, // generated in service
        totalAmount: cart.totalAmount,
        status: 'Pending',
        timestamp: DateTime.now(),
        orderedItems: orderItemsList,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        paymentId: paymentId,
        razorpayOrderId: razorpayOrderId,
      );

      String orderId = await _firestoreService.placeOrder(newOrder);

      cart.clearCart();
      _isProcessing = false;
      notifyListeners();
      return orderId;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }
}
