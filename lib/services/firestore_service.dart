import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/canteen_model.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all canteens
  Stream<List<CanteenModel>> getCanteens() {
    return _db.collection('canteens').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CanteenModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get menu items
  Stream<List<MenuItemModel>> getMenuItems() {
    return _db.collection('menu_items').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItemModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Add menu item
  Future<void> addMenuItem(MenuItemModel item) async {
    await _db.collection('menu_items').doc(item.itemId).set(item.toMap());
  }

  // Update menu item
  Future<void> updateMenuItem(String itemId, Map<String, dynamic> data) async {
    await _db.collection('menu_items').doc(itemId).update(data);
  }

  // Delete menu item
  Future<void> deleteMenuItem(String itemId) async {
    await _db.collection('menu_items').doc(itemId).delete();
  }

  // Get active orders for a user
  Stream<List<OrderModel>> getUserActiveOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['Pending', 'Preparing', 'Ready'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get all orders for a user
  Stream<List<OrderModel>> getUserAllOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get completed orders for a user
  Stream<List<OrderModel>> getUserCompletedOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['Completed', 'Delivered', 'Rejected'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Place an order (FIFO logic included)
  Future<String> placeOrder(OrderModel order) async {
    // Generate new doc ref to get ID
    DocumentReference docRef = _db.collection('orders').doc();
    
    // Get current queue count for this slot (simplify query to avoid composite index error)
    QuerySnapshot slotOrders = await _db
        .collection('orders')
        .where('canteenId', isEqualTo: order.canteenId)
        .where('slot', isEqualTo: order.slot)
        .get();
        
    int queueNumber = slotOrders.docs.length + 1;

    OrderModel finalOrder = OrderModel(
      orderId: docRef.id,
      userId: order.userId,
      userName: order.userName,
      canteenId: order.canteenId,
      canteenName: order.canteenName,
      slot: order.slot,
      queueNumber: queueNumber,
      totalAmount: order.totalAmount,
      status: 'Pending',
      timestamp: DateTime.now(),
      orderedItems: order.orderedItems,
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      paymentId: order.paymentId,
      razorpayOrderId: order.razorpayOrderId,
    );

    await docRef.set(finalOrder.toMap());
    
    // Increment the canteen's queue status immediately after order placement
    await incrementCanteenSlot(order.canteenId, order.slot);
    
    return docRef.id;
  }
  
  // Get all orders (Admin)
  Stream<List<OrderModel>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Update order status (Admin)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _db.collection('orders').doc(orderId).update({'status': newStatus});
  }

  // Increment specific slot crowd for a canteen
  Future<void> incrementCanteenSlot(String canteenId, String slotTime) async {
    DocumentReference canteenRef = _db.collection('canteens').doc(canteenId);
    
    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(canteenRef);
      if (!snapshot.exists) return;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> slotOrders = data['slotOrders'] != null 
          ? Map<String, dynamic>.from(data['slotOrders']) 
          : {};
      
      int currentSlotCount = slotOrders[slotTime] ?? 0;
      slotOrders[slotTime] = currentSlotCount + 1;

      int newQueueLength = (data['queueLength'] ?? 0) + 1;
      
      String newStatus = 'Open';
      if (newQueueLength >= 20) {
        newStatus = 'Busy';
      }

      transaction.update(canteenRef, {
        'slotOrders': slotOrders,
        'queueLength': newQueueLength,
        'status': newStatus,
      });
    });
  }

  // Decrement specific slot crowd for a canteen
  Future<void> decrementCanteenSlot(String canteenId, String slotTime) async {
    DocumentReference canteenRef = _db.collection('canteens').doc(canteenId);
    
    await _db.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(canteenRef);
      if (!snapshot.exists) return;

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> slotOrders = data['slotOrders'] != null 
          ? Map<String, dynamic>.from(data['slotOrders']) 
          : {};
      
      int currentSlotCount = slotOrders[slotTime] ?? 0;
      if (currentSlotCount > 0) {
        slotOrders[slotTime] = currentSlotCount - 1;
      }

      int newQueueLength = (data['queueLength'] ?? 0) - 1;
      if (newQueueLength < 0) newQueueLength = 0;
      
      String newStatus = 'Open';
      if (newQueueLength >= 20) {
        newStatus = 'Busy';
      }

      transaction.update(canteenRef, {
        'slotOrders': slotOrders,
        'queueLength': newQueueLength,
        'status': newStatus,
      });
    });
  }

  // Seed default canteens if database is empty
  Future<void> seedCanteens(List<CanteenModel> canteens) async {
    for (var canteen in canteens) {
      await _db.collection('canteens').doc(canteen.canteenId).set(canteen.toMap());
    }
  }
}
