import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/canteen_provider.dart';
import '../../providers/admin_order_provider.dart';
import '../../utils/app_colors.dart';
import '../auth/role_selection_screen.dart';
import 'admin_dashboard_screen.dart';

class SuperAdminDashboardScreen extends StatelessWidget {
  const SuperAdminDashboardScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canteenProvider = Provider.of<CanteenProvider>(context);
    final canteens = canteenProvider.canteens;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Portal', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Canteen Overview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: canteens.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: canteens.length,
                        itemBuilder: (context, index) {
                          final canteen = canteens[index];
                          return GestureDetector(
                            onTap: () {
                              // Set the scoped canteen for the standard admin dashboard
                              Provider.of<AdminOrderProvider>(context, listen: false).setCanteenId(canteen.canteenId);
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminDashboardScreen(),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Image.network(
                                        canteen.imageUrl.isNotEmpty
                                            ? canteen.imageUrl
                                            : 'https://via.placeholder.com/150',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.store, size: 50, color: Colors.grey)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          canteen.canteenName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Status: ${canteen.status}',
                                          style: TextStyle(
                                            color: canteen.status == 'Open' ? AppColors.successGreen : AppColors.errorRed,
                                            fontWeight: FontWeight.w600,
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
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
