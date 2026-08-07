import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../home/home_screen.dart';
import 'order_tracking_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;

  const OrderConfirmationScreen({Key? key, required this.orderId})
      : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.successGreen,
                          size: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Order Placed\nSuccessfully!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Column(
                              children: [
                                _buildDetailRow('Order ID:', widget.orderId),
                                const SizedBox(height: 16),
                                const Text('Error loading details:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                Text(snapshot.error.toString(), style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
                              ],
                            );
                          }
                          
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Column(
                              children: [
                                _buildDetailRow('Order ID:', widget.orderId),
                                const SizedBox(height: 16),
                                const Text('Order details not found on server yet. Please wait a moment.', style: TextStyle(color: Colors.orange, fontSize: 12), textAlign: TextAlign.center),
                              ],
                            );
                          }
                          var data = snapshot.data!.data() as Map<String, dynamic>;
                          String queueNumber = 'Q-${data['queueNumber']?.toString().padLeft(3, '0') ?? '000'}';
                          String slot = data['slot'] ?? 'N/A';
                          double total = (data['totalAmount'] ?? 0).toDouble();

                          return Column(
                            children: [
                              _buildDetailRow('Order ID:', widget.orderId),
                              _buildDetailRow('Queue Number:', queueNumber),
                              _buildDetailRow('Selected Slot:', slot),
                              _buildDetailRow('Payment Method:', data['paymentMethod'] ?? 'Online Payment'),
                              _buildDetailRow(
                                'Payment Status:', 
                                (data['paymentStatus'] == 'Paid') ? 'SUCCESS' : 'NOT PAID',
                              ),
                              const Divider(),
                              _buildDetailRow('Total:', '₹${total.toStringAsFixed(2)}'),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Track Order',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderTrackingScreen(orderId: widget.orderId),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
