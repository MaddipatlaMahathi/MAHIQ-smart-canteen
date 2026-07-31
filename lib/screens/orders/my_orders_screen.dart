import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/status_badge.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';
import 'order_tracking_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    if (status == 'Preparing') return AppColors.warningOrange;
    if (status == 'Completed') return AppColors.successGreen;
    return AppColors.primaryBlue;
  }

  Widget _buildOrderList(bool isActive) {
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.userId;
    if (userId == null) {
      return const Center(child: Text('Please log in to view your orders.'));
    }

    final stream = isActive 
        ? _firestoreService.getUserActiveOrders(userId)
        : _firestoreService.getUserCompletedOrders(userId);

    return StreamBuilder<List<OrderModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return Center(child: Text(isActive ? 'No active orders' : 'No completed orders'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return AnimatedCard(
              margin: const EdgeInsets.only(bottom: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.orderId)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.orderId.length > 8 ? order.orderId.substring(0, 8) : order.orderId,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        StatusBadge(
                          text: order.status,
                          color: _getStatusColor(order.status),
                          icon: Icons.info_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Queue #${order.queueNumber}', style: const TextStyle(color: AppColors.textGrey, fontSize: 16)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Active Orders'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(true),
          _buildOrderList(false),
        ],
      ),
    );
  }
}
