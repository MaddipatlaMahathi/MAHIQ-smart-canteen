import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final String userName;
  final String canteenId;
  final String canteenName;
  final String slot;
  final int queueNumber;
  final double totalAmount;
  final String status;
  final DateTime timestamp;
  final List<dynamic> orderedItems; // To keep it simple, list of maps
  final String paymentMethod;
  final String paymentStatus;
  final String? paymentId;
  final String? razorpayOrderId;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.canteenId,
    required this.canteenName,
    required this.slot,
    required this.queueNumber,
    required this.totalAmount,
    required this.status,
    required this.timestamp,
    required this.orderedItems,
    this.paymentMethod = 'Online Payment',
    this.paymentStatus = 'Pending',
    this.paymentId,
    this.razorpayOrderId,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String documentId) {
    return OrderModel(
      orderId: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      canteenId: map['canteenId'] ?? '',
      canteenName: map['canteenName'] ?? '',
      slot: map['slot'] ?? '',
      queueNumber: map['queueNumber'] ?? 0,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pending',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      orderedItems: map['orderedItems'] ?? [],
      paymentMethod: map['paymentMethod'] ?? 'Online Payment',
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      paymentId: map['paymentId'],
      razorpayOrderId: map['razorpayOrderId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'canteenId': canteenId,
      'canteenName': canteenName,
      'slot': slot,
      'queueNumber': queueNumber,
      'totalAmount': totalAmount,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'orderedItems': orderedItems,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'razorpayOrderId': razorpayOrderId,
    };
  }
}
