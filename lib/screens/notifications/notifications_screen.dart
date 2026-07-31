import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  IconData _getIconForType(String type) {
    switch (type) {
      case 'alert':
        return Icons.notifications_active;
      case 'system':
        return Icons.info_outline;
      case 'success':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'alert':
        return AppColors.warningOrange;
      case 'system':
        return AppColors.primaryBlue;
      case 'success':
        return AppColors.successGreen;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: userId == null 
        ? const Center(child: Text('Please log in to view notifications'))
        : StreamBuilder<List<OrderModel>>(
            stream: FirestoreService().getUserAllOrders(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final orders = snapshot.data ?? [];
              if (orders.isEmpty) {
                return const Center(child: Text('No new notifications'));
              }

              // Transform orders into notifications
              List<Map<String, dynamic>> notifications = [];
              
              for (var order in orders) {
                if (order.status == 'Ready') {
                  notifications.add({
                    'message': 'Your order ${order.orderId.substring(0,8)} is ready for pickup!',
                    'type': 'success',
                    'isRead': false,
                    'time': order.timestamp,
                  });
                } else if (order.status == 'Preparing') {
                  notifications.add({
                    'message': 'Your order ${order.orderId.substring(0,8)} is now being prepared.',
                    'type': 'alert',
                    'isRead': false,
                    'time': order.timestamp,
                  });
                } else if (order.status == 'Accepted') {
                  notifications.add({
                    'message': 'Your order ${order.orderId.substring(0,8)} has been accepted.',
                    'type': 'alert',
                    'isRead': true,
                    'time': order.timestamp,
                  });
                } else if (order.status == 'Delivered') {
                  notifications.add({
                    'message': 'Order ${order.orderId.substring(0,8)} was delivered.',
                    'type': 'system',
                    'isRead': true,
                    'time': order.timestamp,
                  });
                }
              }

              // Add a generic welcome notification at the end
              notifications.add({
                'message': 'Welcome to MAHIQ! Start ordering now.',
                'type': 'system',
                'isRead': true,
                'time': DateTime.now().subtract(const Duration(days: 7)),
              });

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return AnimatedCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notif['isRead'] ? Colors.white : Colors.blue.shade50.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getColorForType(notif['type']).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIconForType(notif['type']),
                              color: _getColorForType(notif['type']),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  notif['message'],
                                  style: TextStyle(
                                    color: AppColors.textBlack.withOpacity(0.8),
                                    fontSize: 16,
                                    fontWeight: notif['isRead'] ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}
