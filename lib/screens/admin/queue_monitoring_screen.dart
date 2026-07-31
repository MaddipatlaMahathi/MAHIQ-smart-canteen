import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

import 'package:provider/provider.dart';
import '../../providers/admin_order_provider.dart';

class QueueMonitoringScreen extends StatelessWidget {
  final String canteenName;

  const QueueMonitoringScreen({Key? key, this.canteenName = 'Canteen'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Management'),
      ),
      body: Consumer<AdminOrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final queueOrders = provider.allOrders
              .where((o) => o.status == 'Pending' || o.status == 'Preparing')
              .toList();

          if (queueOrders.isEmpty) {
            return const Center(
              child: Text(
                'No active orders in queue.',
                style: TextStyle(fontSize: 18, color: AppColors.textGrey),
              ),
            );
          }

          // Sort by timestamp (oldest first) so they represent the queue
          queueOrders.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: queueOrders.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = queueOrders[index];
              final waitDuration = DateTime.now().difference(item.timestamp);
              final waitString = '${waitDuration.inMinutes} mins';
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  'Q-${item.queueNumber} - ${item.userName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Order ID: ${item.orderId.substring(0, 8)}...'),
                    Text('Wait Time: $waitString', style: const TextStyle(color: AppColors.warningOrange, fontWeight: FontWeight.bold)),
                    Text('Status: ${item.status}', style: TextStyle(color: item.status == 'Preparing' ? AppColors.primaryBlue : AppColors.textGrey)),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              );
            },
          );
        },
      ),
    );
  }
}
