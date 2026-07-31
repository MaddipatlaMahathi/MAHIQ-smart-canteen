import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/super_admin_dashboard.dart';
import '../../providers/admin_order_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.adminLogin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        final user = authProvider.user!;
        final adminOrderProvider = Provider.of<AdminOrderProvider>(context, listen: false);
        adminOrderProvider.setCanteenId(user.canteenId ?? 'all');

        if (user.canteenId == 'all') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SuperAdminDashboardScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppColors.primaryBlue, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(Icons.admin_panel_settings, size: 64, color: AppColors.primaryBlue),
                              const SizedBox(height: 16),
                              Text(
                                'Admin Portal',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Authorized Personnel Only',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textGrey),
                              ),
                              const SizedBox(height: 32),
                              if (authProvider.errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    authProvider.errorMessage,
                                    style: const TextStyle(color: AppColors.errorRed),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              CustomTextField(
                                labelText: 'Admin Email',
                                controller: _emailController,
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (val) => val!.isEmpty ? 'Enter email' : null,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                labelText: 'Password',
                                controller: _passwordController,
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                validator: (val) => val!.isEmpty ? 'Enter password' : null,
                              ),
                              const SizedBox(height: 32),
                              CustomButton(
                                text: 'Admin Login',
                                onPressed: _login,
                                isLoading: authProvider.isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ),
          ),
        ),
      ),
    );
  }
}
