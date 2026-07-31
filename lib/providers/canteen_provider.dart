import 'dart:async';
import 'package:flutter/material.dart';
import '../models/canteen_model.dart';
import '../services/firestore_service.dart';

class CanteenProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Map<String, int> _defaultSlots = {
    '12:00 PM': 0,
    '12:30 PM': 0,
    '1:00 PM': 0,
    '1:30 PM': 0,
  };

  List<CanteenModel> _canteens = [];
  StreamSubscription<List<CanteenModel>>? _canteenSubscription;

  CanteenProvider() {
    _initCanteens();
  }

  void _initCanteens() {
    _canteenSubscription = _firestoreService.getCanteens().listen((canteensData) async {
      if (canteensData.isEmpty) {
        // Seed database if empty
        await _seedDatabase();
      } else {
        _canteens = canteensData;
        notifyListeners();
      }
    });
  }

  Future<void> _seedDatabase() async {
    List<CanteenModel> initialCanteens = [
      CanteenModel(
        canteenId: 'c1',
        canteenName: 'Main Block Canteen',
        imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500&q=80',
        location: 'Main Block, Ground Floor',
        contactNumber: '1234567890',
        queueLength: 0,
        status: 'Open',
        slotOrders: Map.from(_defaultSlots),
      ),
      CanteenModel(
        canteenId: 'c2',
        canteenName: 'Engineering Café',
        imageUrl: 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=500&q=80',
        location: 'Engineering Block',
        contactNumber: '1234567891',
        queueLength: 0,
        status: 'Open',
        slotOrders: Map.from(_defaultSlots),
      ),
      CanteenModel(
        canteenId: 'c3',
        canteenName: 'Central Food Court',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500&q=80',
        location: 'Central Plaza',
        contactNumber: '1234567892',
        queueLength: 0,
        status: 'Open',
        slotOrders: Map.from(_defaultSlots),
      ),
      CanteenModel(
        canteenId: 'c4',
        canteenName: 'Library Café',
        imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=500&q=80',
        location: 'Library Building',
        contactNumber: '1234567893',
        queueLength: 0,
        status: 'Open',
        slotOrders: Map.from(_defaultSlots),
      ),
      CanteenModel(
        canteenId: 'c5',
        canteenName: 'Science Block Canteen',
        imageUrl: 'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=500&q=80',
        location: 'Science Block',
        contactNumber: '1234567894',
        queueLength: 0,
        status: 'Open',
        slotOrders: Map.from(_defaultSlots),
      ),
      CanteenModel(
        canteenId: 'c6',
        canteenName: 'Sports Complex Canteen',
        imageUrl: 'https://images.unsplash.com/photo-1544148103-0773bf10d330?w=500&q=80',
        location: 'Sports Complex',
        contactNumber: '1234567895',
        queueLength: 0,
        status: 'Open',
        slotOrders: Map.from(_defaultSlots),
      ),
      CanteenModel(
        canteenId: 'c7',
        canteenName: 'Hostel Mess',
        imageUrl: 'https://images.unsplash.com/photo-1543353071-873f17a7a088?w=500&q=80',
        location: 'Hostel Area',
        contactNumber: '1234567896',
        queueLength: 0,
        status: 'Open',
        slotOrders: Map.from(_defaultSlots),
      ),
    ];

    await _firestoreService.seedCanteens(initialCanteens);
    // The listener will automatically pick up the new documents
  }

  @override
  void dispose() {
    _canteenSubscription?.cancel();
    super.dispose();
  }

  List<CanteenModel> get canteens => _canteens;

  // Aggregate stats for HomeScreen
  Map<String, int> getGlobalSlotOrders() {
    Map<String, int> globalSlots = Map.from(_defaultSlots);
    for (var canteen in _canteens) {
      canteen.slotOrders.forEach((slot, orders) {
        globalSlots[slot] = (globalSlots[slot] ?? 0) + orders;
      });
    }
    return globalSlots;
  }

  int getTotalOrdersToday() {
    int total = 0;
    for (var canteen in _canteens) {
      total += canteen.queueLength;
    }
    return total;
  }

  int getActiveQueues() {
    int active = 0;
    for (var canteen in _canteens) {
      if (canteen.queueLength > 0) active++;
    }
    return active;
  }
}
