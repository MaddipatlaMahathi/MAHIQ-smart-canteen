import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/status_badge.dart';
import '../menu/menu_screen.dart';
import '../../providers/cart_provider.dart';
import '../../providers/canteen_provider.dart';

class TimeSlotScreen extends StatelessWidget {
  const TimeSlotScreen({Key? key}) : super(key: key);

  Color _getCrowdColor(String crowd) {
    if (crowd.contains('High')) return AppColors.errorRed;
    if (crowd.contains('Medium')) return AppColors.warningOrange;
    return AppColors.successGreen;
  }
  
  String _getCrowdStatus(int orders) {
    if (orders >= 15) return 'High Crowd';
    if (orders >= 8) return 'Medium Crowd';
    return 'Low Crowd';
  }

  int _getWaitTime(int orders) {
    if (orders == 0) return 0;
    if (orders >= 15) return 15;
    if (orders >= 8) return 10;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Time Slot'),
      ),
      body: Consumer2<CanteenProvider, CartProvider>(
        builder: (context, canteenProvider, cartProvider, child) {
          final selectedCanteen = cartProvider.selectedCanteen;
          
          if (selectedCanteen == null) {
            return const Center(child: Text('No canteen selected'));
          }

          // Get the live canteen data from the provider
          final liveCanteen = canteenProvider.canteens.firstWhere(
            (c) => c.canteenId == selectedCanteen.canteenId,
            orElse: () => selectedCanteen,
          );

          final slots = liveCanteen.slotOrders.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slotTime = slots[index];
              final orders = liveCanteen.slotOrders[slotTime] ?? 0;
              final maxOrders = 20; // Fixed capacity per slot
              final crowdStatus = _getCrowdStatus(orders);
              final waitTime = _getWaitTime(orders);
              final color = _getCrowdColor(crowdStatus);
              final fillPercent = (orders / maxOrders).clamp(0.0, 1.0);
              
              return AnimatedCard(
                margin: const EdgeInsets.only(bottom: 16),
                onTap: () {
                  // Set selected slot in CartProvider
                  cartProvider.setCanteenAndSlot(liveCanteen, slotTime);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
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
                            slotTime,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          StatusBadge(
                            text: crowdStatus,
                            color: color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Orders: $orders/$maxOrders', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Est. Wait: $waitTime mins', style: const TextStyle(color: AppColors.textGrey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: fillPercent,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
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
