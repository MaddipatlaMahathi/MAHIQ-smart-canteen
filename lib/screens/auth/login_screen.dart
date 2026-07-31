import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../home/home_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
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
      bool success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        if (authProvider.user!.isAdmin) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
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
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(Icons.restaurant_menu, size: 64, color: AppColors.primaryBlue),
                              const SizedBox(height: 16),
                              Text(
                                'Welcome to MAHIQ',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Smart Crowd & Queue Management',
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
                                labelText: 'Email',
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
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () async {
                                    final email = _emailController.text.trim();
                                    if (email.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter your email to reset password')),
                                      );
                                      return;
                                    }
                                    
                                    bool success = await authProvider.resetPassword(email);
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Password reset link sent to your email!')),
                                      );
                                    }
                                  },
                                  child: const Text('Forgot Password?'),
                                ),
                              ),
                              const SizedBox(height: 24),
                              CustomButton(
                                text: 'Login',
                                onPressed: _login,
                                isLoading: authProvider.isLoading,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Text('OR', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade300)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                icon: Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png', 
                                  height: 24,
                                  width: 24,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.account_circle, size: 24),
                                ),
                                label: const Text('Continue with Google', style: TextStyle(color: Colors.black87)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () async {
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  bool success = await authProvider.signInWithGoogle();
                                  if (success && mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account? ", style: TextStyle(color: AppColors.textGrey)),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                      );
                                    },
                                    child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
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
