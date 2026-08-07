import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  String _previousStatus = '';

  Widget _buildTimelineStep(String title, String currentStatus) {
    List<String> statuses = ['Pending', 'Accepted', 'Preparing', 'Ready', 'Delivered'];
    
    int currentIndex = statuses.indexOf(currentStatus);
    if (currentIndex == -1) currentIndex = 0; // Default to Pending if unknown
    
    int stepIndex = statuses.indexOf(title);
    
    bool isCompleted = stepIndex < currentIndex;
    bool isCurrent = stepIndex == currentIndex;

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted || isCurrent ? AppColors.primaryBlue : Colors.white,
                border: Border.all(
                  color: isCompleted || isCurrent ? AppColors.primaryBlue : Colors.grey,
                  width: isCurrent ? 4 : 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            if (title != 'Delivered')
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.primaryBlue : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: title == 'Delivered' ? 0 : 40.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCompleted || isCurrent ? AppColors.textBlack : AppColors.textGrey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _checkStatusChange(String newStatus) {
    if (_previousStatus.isNotEmpty && _previousStatus != newStatus) {
      if (newStatus == 'Ready') {
        _showNotification('Your order is ready for pickup!', AppColors.successGreen);
      } else if (newStatus == 'Delivered') {
        _showNotification('Your order has been delivered! Enjoy your meal.', AppColors.primaryBlue);
      } else if (newStatus == 'Preparing') {
        _showNotification('Your order is now being prepared.', AppColors.warningOrange);
      }
    }
    _previousStatus = newStatus;
  }

  void _showNotification(String message, Color color) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text('Failed to load order details from server.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text(snapshot.error.toString(), style: const TextStyle(color: Colors.red, fontSize: 14), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    const Text('This is likely a Firebase Permissions error. Please update your Firestore Rules to "allow read, write: if true;".', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order details have not synced yet. Please wait...'));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final currentStatus = orderData['status'] ?? 'Pending';
          final paymentStatus = orderData['paymentStatus'] ?? 'Not Paid';
          final paymentMethod = orderData['paymentMethod'] ?? 'Unknown';
          final queueNumber = 'Q-${orderData['queueNumber']?.toString().padLeft(3, '0') ?? '000'}';
          final slot = orderData['slot'] ?? 'N/A';
          final totalAmount = (orderData['totalAmount'] ?? 0).toDouble();
          final orderedItems = orderData['orderedItems'] as List<dynamic>? ?? [];
          
          _checkStatusChange(currentStatus);

          bool isPaid = paymentStatus == 'Paid';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Status Badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: isPaid ? AppColors.successGreen.withOpacity(0.1) : AppColors.warningOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isPaid ? AppColors.successGreen : AppColors.warningOrange, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(isPaid ? Icons.check_circle : Icons.pending_actions, color: isPaid ? AppColors.successGreen : AppColors.warningOrange, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPaid ? 'Payment Successful' : 'Payment Pending',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isPaid ? AppColors.successGreen : AppColors.warningOrange),
                            ),
                            Text(
                              isPaid ? 'Paid via $paymentMethod' : 'Pay at Counter ($paymentMethod)',
                              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Order Status & ID Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order ID: ${widget.orderId.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textGrey)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(queueNumber, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Current Status', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          currentStatus,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Live Timeline
                const Text('Order Status Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTimelineStep('Pending', currentStatus),
                _buildTimelineStep('Accepted', currentStatus),
                _buildTimelineStep('Preparing', currentStatus),
                _buildTimelineStep('Ready', currentStatus),
                _buildTimelineStep('Delivered', currentStatus),
                const SizedBox(height: 24),

                // Order Details List
                const Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Pickup Slot', style: TextStyle(color: AppColors.textGrey)),
                          Text(slot, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 24),
                      ...orderedItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item['quantity']}x ${item['itemName']}'),
                              Text('₹${(item['price'] * item['quantity']).toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('₹${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
