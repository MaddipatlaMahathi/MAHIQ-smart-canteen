import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/canteen_provider.dart';
import 'providers/admin_order_provider.dart';
import 'utils/app_theme.dart';
import 'screens/auth/splash_screen.dart';

import 'firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Google Sign-In (required for v7.2.0+)
  // We wrap this in a try-catch because on Web, if the clientId is missing,
  // it will throw an exception and prevent the app from loading (white screen).
  try {
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    debugPrint('Google Sign-In initialization failed (check clientId): $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CanteenProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrderProvider()),
      ],
      child: const MahiqApp(),
    ),
  );
}

class MahiqApp extends StatelessWidget {
  const MahiqApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAHIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
