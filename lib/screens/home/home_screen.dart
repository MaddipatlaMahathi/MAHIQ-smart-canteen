import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import 'canteen_selection_screen.dart';
import '../orders/my_orders_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/animated_card.dart';
import '../../providers/canteen_provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  Widget _buildCrowdCard(String time, String crowd, String orders) {
    Color crowdColor;
    if (crowd == 'High') {
      crowdColor = AppColors.errorRed;
    } else if (crowd == 'Medium') crowdColor = AppColors.warningOrange;
    else crowdColor = AppColors.successGreen;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: crowdColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: crowdColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Crowd: $crowd', style: TextStyle(color: crowdColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Orders: $orders', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAHIQ Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: AppColors.primaryBlue),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                final userName = auth.user?.name ?? 'Guest';
                return Text(
                  'Welcome, $userName 👋',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                );
              }
            ),
            const SizedBox(height: 24),
            const Text('Canteen Crowd Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Consumer<CanteenProvider>(
              builder: (context, canteenProvider, child) {
                final canteens = canteenProvider.canteens;
                
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: canteens.map((canteen) {
                      final activeOrders = canteen.queueLength;
                      String crowdStatus = 'Low';
                      if (activeOrders >= 15) crowdStatus = 'High';
                      else if (activeOrders >= 8) crowdStatus = 'Medium';
                      
                      return _buildCrowdCard(canteen.canteenName, crowdStatus, '$activeOrders active orders');
                    }).toList(),
                  ),
                );
              }
            ),
            const SizedBox(height: 32),
            const Text('Quick Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Consumer<CanteenProvider>(
              builder: (context, canteenProvider, child) {
                final todayOrders = canteenProvider.getTotalOrdersToday();
                final activeQueues = canteenProvider.getActiveQueues();
                final avgWait = todayOrders > 0 ? '${(todayOrders / (activeQueues > 0 ? activeQueues : 1) * 3).clamp(5, 45).toInt()} mins' : '0 mins';

                return Row(
                  children: [
                    _buildQuickStat('Today\'s Orders', '$todayOrders', Icons.receipt_long, AppColors.primaryBlue),
                    const SizedBox(width: 12),
                    _buildQuickStat('Avg Wait', avgWait, Icons.timer, AppColors.warningOrange),
                    const SizedBox(width: 12),
                    _buildQuickStat('Active Queues', '$activeQueues', Icons.people_outline, AppColors.successGreen),
                  ],
                );
              }
            ),
            const SizedBox(height: 32),
            AnimatedCard(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CanteenSelectionScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hungry?', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Select Canteen', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View Orders'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
