  import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class AdminOrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _ordersSubscription;
  String _canteenId = 'all';

  List<OrderModel> _allOrders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  // Real-time Dashboard metrics
  int _activeStudentsCount = 0;

  List<OrderModel> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get activeStudentsCount => _activeStudentsCount;
  String get canteenId => _canteenId;

  AdminOrderProvider() {
    _initOrdersStream();
  }

  void setCanteenId(String newCanteenId) {
    if (_canteenId != newCanteenId) {
      _canteenId = newCanteenId;
      _ordersSubscription?.cancel();
      _isLoading = true;
      notifyListeners();
      _initOrdersStream();
    }
  }

  void _initOrdersStream() {
    Query<Map<String, dynamic>> query = _firestore
        .collection('orders')
        .orderBy('timestamp', descending: true);

    if (_canteenId != 'all') {
      // NOTE: We do not use .where('canteenId', isEqualTo: canteenId) combined with .orderBy('timestamp') 
      // because that requires creating a composite index in Firestore. Since the app is small, we filter locally 
      // instead, or we just rely on local filtering to avoid index errors. Wait, local filtering is better here.
      // But we CAN just do query = query.where('canteenId', isEqualTo: canteenId) if we create the index.
      // We'll just fetch all orders sorted by time, and filter them locally.
    }

    _ordersSubscription = query.snapshots().listen((snapshot) {
      List<OrderModel> allFetched = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
          
      if (_canteenId != 'all') {
        _allOrders = allFetched.where((o) => o.canteenId == _canteenId).toList();
      } else {
        _allOrders = allFetched;
      }

      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = 'Failed to load orders: $error';
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchActiveStudentsCount() async {
    try {
      final snapshot = await _firestore.collection('users').count().get();
      _activeStudentsCount = snapshot.count ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching students count: $e");
    }
  }

  // Dashboard Aggregates (calculated from _allOrders)
  int get totalOrders => _allOrders.length;
  int get pendingOrders => _allOrders.where((o) => o.status == 'Pending').length;
  int get preparingOrders => _allOrders.where((o) => o.status == 'Preparing' || o.status == 'Accepted').length;
  int get readyOrders => _allOrders.where((o) => o.status == 'Ready').length;
  int get deliveredOrders => _allOrders.where((o) => o.status == 'Delivered').length;
  
  double get totalRevenue {
    double total = 0;
    // Only count delivered/completed orders, or all paid orders? We will count all orders not rejected
    for (var order in _allOrders) {
      if (order.status != 'Rejected' && order.paymentStatus != 'Failed') {
        total += order.totalAmount;
      }
    }
    return total;
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final order = _allOrders.firstWhere((o) => o.orderId == orderId);
      final oldStatus = order.status;

      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });

      // If the order moved from an active queue state to a completed/rejected state,
      // we need to decrement the live queue counter in the Canteen document
      bool wasActive = ['Pending', 'Preparing', 'Accepted', 'Ready'].contains(oldStatus);
      bool isInactive = ['Delivered', 'Rejected', 'Completed'].contains(newStatus);
      
      if (wasActive && isInactive) {
        await FirestoreService().decrementCanteenSlot(order.canteenId, order.slot);
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update order status: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> syncCanteenQueues() async {
    try {
      // 1. Group active orders by canteen and slot
      Map<String, int> canteenActiveCount = {};
      Map<String, Map<String, int>> canteenSlotCount = {};

      for (var order in _allOrders) {
        if (['Pending', 'Preparing', 'Accepted', 'Ready'].contains(order.status)) {
          canteenActiveCount[order.canteenId] = (canteenActiveCount[order.canteenId] ?? 0) + 1;
          
          canteenSlotCount[order.canteenId] ??= {};
          canteenSlotCount[order.canteenId]![order.slot] = (canteenSlotCount[order.canteenId]![order.slot] ?? 0) + 1;
        }
      }

      // 2. Fetch all canteens
      final canteensSnapshot = await _firestore.collection('canteens').get();
      
      // 3. Update each canteen with the correct count
      for (var doc in canteensSnapshot.docs) {
        final canteenId = doc.id;
        final actualCount = canteenActiveCount[canteenId] ?? 0;
        final actualSlots = canteenSlotCount[canteenId] ?? {};

        final defaultSlots = ['12:00 PM', '12:30 PM', '1:00 PM', '1:30 PM'];
        Map<String, int> finalSlots = {};
        for (var slot in defaultSlots) {
          finalSlots[slot] = actualSlots[slot] ?? 0;
        }

        await _firestore.collection('canteens').doc(canteenId).update({
          'queueLength': actualCount,
          'slotOrders': finalSlots,
          'status': actualCount >= 20 ? 'Busy' : 'Open',
        });
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error syncing canteen queues: $e");
    }
  }
}
