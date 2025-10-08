import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔵 ===== STARTING SIGNUP PROCESS =====');
      print('📧 Email: $email');
      print('👤 Name: $name');

      // Create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ User account created successfully');
      print('🆔 UID: ${userCredential.user!.uid}');

      // Update display name - wrapped in try-catch to handle the error gracefully
      try {
        await userCredential.user?.updateDisplayName(name);
        print('✅ Display name updated successfully');
      } catch (e) {
        print('⚠️ Warning: Could not update display name: $e');
        // Continue anyway - we'll save the name in Firestore
      }

      // Reload user to get updated info
      await userCredential.user?.reload();
      
      print('📝 Creating Firestore user document...');
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'cart': [],
        'wishlist': [],
        'purchasedBooks': [],
      });

      print('✅ Firestore user document created successfully');
      print('🎉 SIGNUP COMPLETE!');

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ General Exception: $e');
      throw 'Signup failed: ${e.toString()}';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 ===== STARTING SIGNIN PROCESS =====');
      print('📧 Email: $email');
      
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('✅ Sign in successful');
      print('🆔 UID: ${userCredential.user!.uid}');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ General Exception: $e');
      throw 'Sign in failed: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('🔵 Signing out...');
      await _auth.signOut();
      print('✅ Sign out successful');
    } catch (e) {
      print('❌ Sign out failed: $e');
      throw 'Sign out failed: ${e.toString()}';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      print('🔵 Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      print('❌ Password reset failed: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ General Exception: $e');
      throw 'Password reset failed: ${e.toString()}';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      default:
        return 'An error occurred: ${e.message ?? "Please try again."}';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) {
      print('⚠️ No current user');
      return null;
    }
    
    try {
      print('🔵 Fetching user data for UID: ${currentUser!.uid}');
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (doc.exists) {
        print('✅ User data found');
        return doc.data() as Map<String, dynamic>?;
      } else {
        print('⚠️ User document does not exist');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user data: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? photoUrl,
  }) async {
    if (currentUser == null) {
      throw 'No user logged in';
    }

    try {
      print('🔵 Updating user profile...');
      
      // Update Firestore first (more reliable)
      Map<String, dynamic> updates = {};
      
      if (name != null) {
        updates['name'] = name;
      }
      if (photoUrl != null) {
        updates['photoUrl'] = photoUrl;
      }
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser!.uid).update(updates);
        print('✅ Firestore profile updated');
      }

      // Try to update Firebase Auth profile (optional)
      try {
        if (name != null) {
          await currentUser!.updateDisplayName(name);
        }
        if (photoUrl != null) {
          await currentUser!.updatePhotoURL(photoUrl);
        }
        await currentUser!.reload();
        print('✅ Firebase Auth profile updated');
      } catch (e) {
        print('⚠️ Could not update Firebase Auth profile: $e');
        // Continue anyway - Firestore is updated
      }
      
    } catch (e) {
      print('❌ Failed to update profile: $e');
      throw 'Failed to update profile: ${e.toString()}';
    }
  }
}