import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Provider.of<AuthProvider>(context, listen: false)
            .setErrorMessage("Passwords do not match");
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (success && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Join MAHIQ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
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
                    labelText: 'Full Name',
                    controller: _nameController,
                    prefixIcon: Icons.person,
                    validator: (val) => val!.isEmpty ? 'Enter full name' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: 'Email',
                    controller: _emailController,
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val!.isEmpty ? 'Enter email' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: 'Password',
                    controller: _passwordController,
                    prefixIcon: Icons.lock,
                    isPassword: true,
                    validator: (val) => val!.length < 6 ? 'Min 6 chars' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    labelText: 'Confirm Password',
                    controller: _confirmPasswordController,
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (val) => val!.isEmpty ? 'Confirm password' : null,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Register',
                    onPressed: _signUp,
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
