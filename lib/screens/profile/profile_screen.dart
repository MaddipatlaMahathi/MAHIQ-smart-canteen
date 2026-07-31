import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/role_selection_screen.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Widget _buildStatCard(String title, String value, IconData icon) {
    return AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textGrey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                final userName = auth.user?.name ?? 'Guest User';
                final userEmail = auth.user?.email ?? 'Not Logged In';
                
                return Column(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                );
              }
            ),
            const SizedBox(height: 32),
            _buildStatCard('Department', 'Computer Science', Icons.school),
            const SizedBox(height: 12),
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                final userId = auth.user?.userId;
                if (userId == null) {
                  return Column(
                    children: [
                      _buildStatCard('Orders', '0', Icons.receipt_long),
                      const SizedBox(height: 12),
                      _buildStatCard('Favourite Canteen', '-', Icons.favorite),
                      const SizedBox(height: 12),
                      _buildStatCard('Total Spent', '₹0', Icons.account_balance_wallet),
                    ],
                  );
                }

                return StreamBuilder<List<OrderModel>>(
                  stream: FirestoreService().getUserAllOrders(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final orders = snapshot.data ?? [];
                    int totalOrders = orders.length;
                    double totalSpent = 0;
                    
                    // To find favourite canteen
                    Map<String, int> canteenFreq = {};
                    String favouriteCanteen = 'None Yet';
                    int maxFreq = 0;
                    
                    for (var order in orders) {
                      if (order.status != 'Rejected' && order.paymentStatus != 'Failed') {
                        totalSpent += order.totalAmount;
                      }
                      
                      canteenFreq[order.canteenName] = (canteenFreq[order.canteenName] ?? 0) + 1;
                      if (canteenFreq[order.canteenName]! > maxFreq) {
                        maxFreq = canteenFreq[order.canteenName]!;
                        favouriteCanteen = order.canteenName;
                      }
                    }

                    return Column(
                      children: [
                        _buildStatCard('Orders', '$totalOrders', Icons.receipt_long),
                        const SizedBox(height: 12),
                        _buildStatCard('Favourite Canteen', favouriteCanteen, Icons.favorite),
                        const SizedBox(height: 12),
                        _buildStatCard('Total Spent', '₹${totalSpent.toStringAsFixed(0)}', Icons.account_balance_wallet),
                      ],
                    );
                  }
                );
              }
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                  side: const BorderSide(color: AppColors.errorRed),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      (route) => false,
                    );
                  }
                },
                child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
