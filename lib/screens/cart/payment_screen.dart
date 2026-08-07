import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/canteen_provider.dart';
import '../../models/canteen_model.dart';
import '../../models/user_model.dart';
import '../orders/order_tracking_screen.dart';
import 'upi_payment_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({Key? key, required this.totalAmount}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'Online Payment';
  bool _isProcessingPayment = false;

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.errorRed));
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'Online Payment') {
      // Navigate to UPI Payment Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UpiPaymentScreen(
            totalAmount: widget.totalAmount + (widget.totalAmount * 0.05), // Pass final total with GST
          ),
        ),
      );
      return;
    }

    // Cash on Delivery Flow
    setState(() {
      _isProcessingPayment = true;
    });

    await _finalizeOrder(
      paymentMethod: 'Cash on Delivery',
      paymentStatus: 'Pending',
    );
  }

  Future<void> _finalizeOrder({
    required String paymentMethod,
    required String paymentStatus,
  }) async {
    if (!mounted) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final canteenProvider = Provider.of<CanteenProvider>(context, listen: false);

    UserModel user = auth.user ?? UserModel(
      userId: 'mock_user_123',
      name: 'Guest User',
      email: 'guest@example.com',
      isAdmin: false,
    );

    if (cart.selectedCanteen == null || cart.selectedSlot == null) {
      final dummyCanteen = CanteenModel(
        canteenId: 'canteen_1', canteenName: 'Main Block Canteen', imageUrl: '',
      );
      cart.setCanteenAndSlot(dummyCanteen, '1:00 PM');
    }

    String? orderId = await orderProvider.placeOrder(
      user, 
      cart, 
      canteenProvider,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
    );

    setState(() {
      _isProcessingPayment = false;
    });

    if (orderId != null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: orderId)),
        (route) => route.isFirst,
      );
    } else {
      _showError('Failed to place order. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final isPlacingOrder = Provider.of<OrderProvider>(context).isProcessing;
    final isLoading = _isProcessingPayment || isPlacingOrder;
    
    final subtotal = widget.totalAmount;
    final gst = subtotal * 0.05;
    final finalTotal = subtotal + gst;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Details
                const Text('Delivery Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.store, color: AppColors.primaryBlue, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cart.selectedCanteen?.canteenName ?? 'Canteen', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Pickup Slot: ${cart.selectedSlot ?? 'N/A'}', style: const TextStyle(color: AppColors.textGrey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bill Details
                const Text('Bill Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Item Total', style: TextStyle(color: AppColors.textGrey)),
                          Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Taxes & GST (5%)', style: TextStyle(color: AppColors.textGrey)),
                          Text('₹${gst.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('To Pay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('₹${finalTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Methods
                const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Row(
                          children: [
                            Icon(Icons.qr_code, color: AppColors.primaryBlue),
                            SizedBox(width: 12),
                            Text('Direct UPI Payment', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        value: 'Online Payment',
                        groupValue: _selectedPaymentMethod,
                        activeColor: AppColors.primaryBlue,
                        onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                      ),
                      const Divider(height: 1),
                      RadioListTile<String>(
                        title: const Row(
                          children: [
                            Icon(Icons.money, color: AppColors.successGreen),
                            SizedBox(width: 12),
                            Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        value: 'Cash on Delivery',
                        groupValue: _selectedPaymentMethod,
                        activeColor: AppColors.primaryBlue,
                        onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // padding for bottom button
              ],
            ),
          ),
          
          // Bottom Checkout Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _processPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          'Proceed to Pay  ₹${finalTotal.toStringAsFixed(2)}', 
                          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                  ),
                ),
              ),
            ),
          ),
          
          // Full Screen Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryBlue),
                        SizedBox(height: 16),
                        Text('Securely Processing...', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
