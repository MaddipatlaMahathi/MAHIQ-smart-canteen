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
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found.'));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final currentStatus = orderData['status'] ?? 'Pending';
          
          _checkStatusChange(currentStatus);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        Text('Order ID: \${widget.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Status',
                                  style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentStatus,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Order Status Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildTimelineStep('Pending', currentStatus),
                _buildTimelineStep('Accepted', currentStatus),
                _buildTimelineStep('Preparing', currentStatus),
                _buildTimelineStep('Ready', currentStatus),
                _buildTimelineStep('Delivered', currentStatus),
              ],
            ),
          );
        },
      ),
    );
  }
}
