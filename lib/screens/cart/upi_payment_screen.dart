import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:upi_india/upi_india.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  @override
  void initState() {
    super.initState();
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
      setState(() {
        apps = value;
      });
    }).catchError((e) {
      setState(() {
        apps = [];
      });
    });
  }

  String get _upiUrl {
    return 'upi://pay?pa=$_upiId&pn=$_payeeName&am=${widget.totalAmount.toStringAsFixed(2)}&cu=INR';
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

  Future<void> _startTransaction(UpiApp app) async {
    final transactionRef = const Uuid().v4().substring(0, 12);
    
    try {
      UpiResponse response = await _upiIndia.startTransaction(
        app: app,
        receiverUpiId: _upiId,
        receiverName: _payeeName,
        transactionRefId: transactionRef,
        transactionNote: 'Payment for MAHIQ Order',
        amount: widget.totalAmount,
      );

      _handleUpiResponse(response);
    } catch (e) {
      _showError(_handleUpiError(e));
    }
  }

  String _handleUpiError(dynamic e) {
    if (e is UpiIndiaAppNotInstalledException) return 'Requested app not installed on device';
    if (e is UpiIndiaUserCancelledException) return 'You cancelled the transaction';
    if (e is UpiIndiaNullResponseException) return "Requested app didn't return any response";
    if (e is UpiIndiaInvalidParametersException) return 'Requested app cannot handle the transaction';
    return 'An unknown error occurred';
  }

  void _handleUpiResponse(UpiResponse response) {
    String status = response.status ?? UpiPaymentStatus.FAILURE;

    if (status == UpiPaymentStatus.SUCCESS) {
      // Payment Successful! Verify on our end
      _finalizeOrder(response.transactionId);
    } else if (status == UpiPaymentStatus.SUBMITTED) {
      _showError('Payment is pending. Order not placed. Please check your bank app.');
    } else if (status == UpiPaymentStatus.FAILURE) {
      _showError('Payment Failed. Please try again.');
    } else {
      _showError('Payment was Cancelled or Failed.');
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

    String? orderId = await orderProvider.placeOrder(
      user, 
      cart, 
      canteenProvider,
      paymentMethod: isManualQr ? 'UPI (Simulated)' : 'UPI',
      paymentStatus: 'Paid',
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
    Widget appsGrid;
    if (apps == null) {
      appsGrid = const Center(child: CircularProgressIndicator());
    } else if (apps!.isEmpty) {
      appsGrid = const Center(
        child: Text(
          "No UPI Apps found by plugin. Try the universal launcher below.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.warningOrange, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      appsGrid = Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 16,
        children: apps!.map<Widget>((UpiApp app) {
          return GestureDetector(
            onTap: () => _startTransaction(app),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(app.icon, height: 60, width: 60),
                  ),
                ),
                const SizedBox(height: 8),
                Text(app.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Column(
      children: [
        appsGrid,
        const SizedBox(height: 32),
        const Text('Universal UPI Launcher (Fallback)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              final Uri uri = Uri.parse(_upiUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                _showError('Could not open any UPI app automatically.');
              }
            },
            icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
            label: const Text('Open UPI App directly', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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
                  'Pay Using Installed Apps',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  'Or Scan to Pay via another device',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textGrey),
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
                      data: _upiUrl,
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
                
                // Manual Verification Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _finalizeOrder('simulated_txn_123', isManualQr: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Simulate Payment (Test Mode)', 
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)
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
