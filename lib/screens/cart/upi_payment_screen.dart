import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/canteen_provider.dart';
import '../../models/user_model.dart';
import '../../models/canteen_model.dart';
import '../orders/order_tracking_screen.dart';
import '../../utils/app_colors.dart';

class UpiPaymentScreen extends StatefulWidget {
  final double totalAmount;

  const UpiPaymentScreen({Key? key, required this.totalAmount}) : super(key: key);

  @override
  State<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends State<UpiPaymentScreen> {
  final String _upiId = '7013884017@axl';
  final String _payeeName = 'MAHIQ Admin';
  bool _isProcessing = false;
  final TextEditingController _utrController = TextEditingController();
  bool _isUtrValid = false;

  @override
  void initState() {
    super.initState();
    _utrController.addListener(() {
      setState(() {
        _isUtrValid = _utrController.text.trim().length >= 12;
      });
    });
  }

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  Uri get _upiUri {
    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': _upiId,
        'pn': _payeeName,
        'am': widget.totalAmount.toStringAsFixed(2),
        'cu': 'INR',
      },
    );
  }

  void _copyUpiId() {
    Clipboard.setData(ClipboardData(text: _upiId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('UPI ID copied to clipboard'), backgroundColor: AppColors.successGreen),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.errorRed),
      );
    }
  }



  Future<void> _finalizeOrder(String? transactionId, {bool isManualQr = false}) async {
    setState(() {
      _isProcessing = true;
    });

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

    String actualStatus = isManualQr ? 'Verification Pending' : 'Paid';
    String actualMethod = isManualQr ? 'UPI (QR Scan)' : 'UPI';

    String? orderId = await orderProvider.placeOrder(
      user, 
      cart, 
      canteenProvider,
      paymentMethod: actualMethod,
      paymentStatus: actualStatus,
      paymentId: transactionId,
    );

    setState(() {
      _isProcessing = false;
    });

    if (orderId != null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: orderId)),
        (route) => route.isFirst,
      );
    } else {
      _showError('Failed to place order in database. Please contact admin.');
    }
  }

  Widget _buildUpiApps() {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              if (await canLaunchUrl(_upiUri)) {
                await launchUrl(_upiUri, mode: LaunchMode.externalApplication);
              } else {
                _showError('Could not open any UPI app automatically.');
              }
            },
            icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
            label: const Text('Open UPI App on this device', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '1. Pay Using Installed Apps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Amount: ₹${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 24),
                
                // UPI Apps List
                _buildUpiApps(),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 32),
                
                const Text(
                  '2. Or Scan to Pay via another device',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // QR Code
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: _upiUri.toString(),
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // UPI ID Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('UPI ID', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(_upiId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: AppColors.primaryBlue),
                        onPressed: _copyUpiId,
                        tooltip: 'Copy UPI ID',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // UTR Input Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('3. Enter 12-Digit UTR / Transaction ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    const Text('After paying via the blue button or QR code, type your UTR number below to verify your payment.', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _utrController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      decoration: InputDecoration(
                        hintText: 'e.g. 312345678901',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Manual Verification Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isUtrValid 
                      ? () => _finalizeOrder(_utrController.text.trim(), isManualQr: true)
                      : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isUtrValid ? AppColors.successGreen : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Verify Payment', 
                      style: TextStyle(
                        fontSize: 18, 
                        color: _isUtrValid ? Colors.white : Colors.grey.shade600, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
          
          if (_isProcessing)
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
                        Text('Verifying Payment...', style: TextStyle(fontWeight: FontWeight.bold)),
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
