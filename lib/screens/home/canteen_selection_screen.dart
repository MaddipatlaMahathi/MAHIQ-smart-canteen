import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_card.dart';
import '../canteen/time_slot_screen.dart';
import '../../providers/canteen_provider.dart';
import '../../providers/cart_provider.dart';

class CanteenSelectionScreen extends StatelessWidget {
  const CanteenSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Canteen'),
      ),
      body: Consumer<CanteenProvider>(
        builder: (context, canteenProvider, child) {
          final canteens = canteenProvider.canteens;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: canteens.length,
            itemBuilder: (context, index) {
              final canteen = canteens[index];
              final isBusy = canteen.status == 'Busy';
              
              return AnimatedCard(
                margin: const EdgeInsets.only(bottom: 16),
                onTap: () {
                  // Set selected canteen in CartProvider
                  Provider.of<CartProvider>(context, listen: false).setCanteenAndSlot(canteen, '');
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TimeSlotScreen()));
                },
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(canteen.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              canteen.canteenName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isBusy ? AppColors.warningOrange.withOpacity(0.1) : AppColors.successGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Status: ${canteen.status}',
                                    style: TextStyle(
                                      color: isBusy ? AppColors.warningOrange : AppColors.successGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Queue: ${canteen.queueLength}',
                                  style: const TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
