import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../auth/role_selection_screen.dart';
import 'admin_menu_management_screen.dart';
import 'admin_canteen_management_screen.dart';
import 'admin_order_management_screen.dart';
import 'queue_monitoring_screen.dart';
import '../../providers/admin_order_provider.dart';
import '../../providers/canteen_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminOrderProvider>(context, listen: false).fetchActiveStudentsCount();
    });
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminOrderProvider = Provider.of<AdminOrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isSuperAdmin = authProvider.user?.canteenId == 'all';

    String dashboardTitle = 'Admin Dashboard';
    if (!isSuperAdmin) {
      final canteenProvider = Provider.of<CanteenProvider>(context, listen: false);
      try {
        final canteen = canteenProvider.canteens.firstWhere(
          (c) => c.canteenId == authProvider.user?.canteenId
        );
        dashboardTitle = canteen.canteenName;
      } catch (e) {
        dashboardTitle = 'Canteen Dashboard';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(dashboardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Canteen Queues',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing canteen queues...')),
              );
              await Provider.of<AdminOrderProvider>(context, listen: false).syncCanteenQueues();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Canteen queues synced successfully!')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
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
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primaryBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.admin_panel_settings, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text('MAHIQ Admin', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Order Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminOrderManagementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Menu Management'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMenuManagementScreen()));
              },
            ),
            if (isSuperAdmin)
              ListTile(
                leading: const Icon(Icons.storefront),
                title: const Text('Canteen Management'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCanteenManagementScreen()));
                },
              ),
            ListTile(
              leading: const Icon(Icons.tv),
              title: const Text('Queue Monitor (TV)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => QueueMonitoringScreen(canteenName: dashboardTitle)));
              },
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (context) {
          if (adminOrderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (adminOrderProvider.errorMessage.isNotEmpty) {
            return Center(child: Text('Error: ${adminOrderProvider.errorMessage}'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStatCard('Total Orders', '${adminOrderProvider.totalOrders}', AppColors.primaryBlue),
                _buildStatCard('Pending', '${adminOrderProvider.pendingOrders}', AppColors.warningOrange),
                _buildStatCard('Preparing', '${adminOrderProvider.preparingOrders}', AppColors.primaryBlue),
                _buildStatCard('Ready', '${adminOrderProvider.readyOrders}', AppColors.successGreen),
                _buildStatCard('Delivered', '${adminOrderProvider.deliveredOrders}', AppColors.textGrey),
              ],
            ),
          ],
        ),
      );
        },
      ),
    );
  }
}
