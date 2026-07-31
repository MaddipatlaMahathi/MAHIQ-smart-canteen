import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_order_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminOrderManagementScreen> createState() => _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState extends State<AdminOrderManagementScreen> {
  void _updateStatus(String orderId, String newStatus) async {
    final provider = Provider.of<AdminOrderProvider>(context, listen: false);
    bool success = await provider.updateOrderStatus(orderId, newStatus);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $newStatus'), backgroundColor: AppColors.successGreen),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status'), backgroundColor: AppColors.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminOrderProvider = Provider.of<AdminOrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: Builder(
        builder: (context) {
          if (adminOrderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (adminOrderProvider.errorMessage.isNotEmpty) {
            return Center(child: Text('Error: ${adminOrderProvider.errorMessage}'));
          }

          final orders = adminOrderProvider.allOrders;
          
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return AnimatedCard(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'ID: ${order.orderId}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              order.status,
                              style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(order.status)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Student: ${order.userName}', style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${order.orderedItems.length} items', style: const TextStyle(color: AppColors.textGrey)),
                          Text('₹${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Divider(height: 32),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => _updateStatus(order.orderId, 'Accepted'),
                              child: const Text('Accept'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _updateStatus(order.orderId, 'Preparing'),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.warningOrange),
                              child: const Text('Preparing'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _updateStatus(order.orderId, 'Ready'),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryBlue),
                              child: const Text('Ready'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _updateStatus(order.orderId, 'Delivered'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen, foregroundColor: Colors.white),
                              child: const Text('Delivered'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warningOrange;
      case 'Accepted':
      case 'Preparing':
        return AppColors.primaryBlue;
      case 'Ready':
      case 'Delivered':
        return AppColors.successGreen;
      default:
        return AppColors.textGrey;
    }
  }
}
