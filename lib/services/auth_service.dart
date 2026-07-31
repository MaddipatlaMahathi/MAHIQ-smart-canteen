import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up
  Future<UserModel?> signUp(String name, String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        UserModel newUser = UserModel(
          userId: credential.user!.uid,
          name: name,
          email: email,
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(newUser.toMap());

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw 'This email is already registered. Please login instead.';
      } else if (e.code == 'weak-password') {
        throw 'The password provided is too weak.';
      } else {
        throw e.message ?? 'An unknown authentication error occurred.';
      }
    } catch (e) {
      throw 'An error occurred during sign up. Please try again.';
    }
    return null;
  }

  // Log in
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw 'Invalid email or password. Please try again or sign up.';
      } else if (e.code == 'invalid-email') {
        throw 'The email address is badly formatted.';
      } else {
        throw e.message ?? 'An unknown authentication error occurred.';
      }
    } catch (e) {
      throw 'An error occurred during login. Please try again.';
    }
    return null;
  }

  // Google Sign In
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          // Existing user
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        } else {
          // New user
          UserModel newUser = UserModel(
            userId: user.uid,
            name: user.displayName ?? 'Student',
            email: user.email ?? '',
          );
          await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
          return newUser;
        }
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown authentication error occurred with Google Sign-In.';
    } catch (e) {
      throw 'Google Sign-In Error: $e';
    }
    return null;
  }

  // Admin Log in
  Future<UserModel?> adminLogin(String email, String password) async {
    try {
      UserCredential credential;
      try {
        credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (e) {
        // AUTO-SETUP FOR ADMIN
        if ((e.code == 'invalid-credential' || e.code == 'user-not-found') && email == 'admin@mahiq.com') {
          try {
            // Attempt to create the account if it doesn't exist
            credential = await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );
          } catch (createError) {
            throw 'Invalid admin credentials.'; // Password was just wrong
          }
        } else {
          rethrow;
        }
      }

      if (credential.user != null) {
        // SUPER ADMIN BYPASS: If they successfully logged into Firebase Auth with this email, 
        // grant them admin access immediately without querying Firestore.
        // This bypasses any Firestore Security Rule (permission-denied) errors.
        if (email == 'admin@mahiq.com') {
          return UserModel(
            userId: credential.user!.uid,
            name: 'Super Admin',
            email: email,
            isAdmin: true,
            canteenId: 'all',
          );
        }

        DocumentSnapshot doc = await _firestore
            .collection('admins')
            .doc(credential.user!.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          return UserModel(
            userId: doc.id,
            name: data != null && data.containsKey('name') ? data['name'] : 'Admin',
            email: email,
            isAdmin: true,
            canteenId: data != null ? data['canteenId'] : null,
          );
        } else {
          await _auth.signOut();
          throw 'You do not have administrative privileges.';
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw 'Invalid admin credentials.';
      } else if (e.code == 'invalid-email') {
        throw 'The email address is badly formatted.';
      } else {
        throw e.message ?? 'An unknown authentication error occurred.';
      }
    } catch (e) {
      if (e.toString().contains('administrative privileges')) {
        rethrow;
      }
      throw 'An error occurred during admin login. Please try again.';
    }
    return null;
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email. Please sign up first.';
      } else if (e.code == 'invalid-email') {
        throw 'The email address is badly formatted.';
      } else {
        throw e.message ?? 'An unknown error occurred.';
      }
    } catch (e) {
      throw 'An error occurred during password reset. Please try again.';
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
