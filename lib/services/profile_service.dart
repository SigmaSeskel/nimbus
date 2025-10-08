import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;
  User? get currentUser => _auth.currentUser;

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_userId == null) return null;

    try {
      print('🔵 Fetching user profile...');
      final doc = await _firestore.collection('users').doc(_userId).get();
      
      if (doc.exists) {
        print('✅ User profile loaded');
        return doc.data();
      } else {
        print('⚠️ User profile not found, creating default profile');
        await _createDefaultProfile();
        return await getUserProfile();
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
      return null;
    }
  }

  // Create default profile
  Future<void> _createDefaultProfile() async {
    if (_userId == null) return;

    try {
      final currentUserEmail = currentUser?.email ?? '';
      final currentUserName = currentUser?.displayName ?? currentUser?.email?.split('@')[0] ?? 'User';
      
      await _firestore.collection('users').doc(_userId).set({
        'uid': _userId,
        'name': currentUserName,
        'email': currentUserEmail,
        'bio': 'Book lover 📚',
        'photoUrl': currentUser?.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'cart': [],
        'wishlist': [],
        'purchasedBooks': [],
        'preferences': {
          'notifications': true,
          'emailNotifications': true,
          'pushNotifications': true,
          'darkMode': false,
        },
      }, SetOptions(merge: true)); // Use merge to avoid overwriting existing data
      
      print('✅ Default profile created');
    } catch (e) {
      print('❌ Error creating default profile: $e');
    }
  }

  // Update profile information
  Future<void> updateProfile({
    String? name,
    String? bio,
    String? phone,
    String? photoUrl,
  }) async {
    if (_userId == null) throw 'User not authenticated';

    try {
      print('🔵 Updating profile...');
      Map<String, dynamic> updates = {};
      
      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(_userId).update(updates);

      // Also update Firebase Auth display name
      if (name != null) {
        await currentUser?.updateDisplayName(name);
      }
      
      print('✅ Profile updated successfully');
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw 'Failed to update profile: ${e.toString()}';
    }
  }

  // Get profile statistics
  Future<Map<String, int>> getProfileStats() async {
    if (_userId == null) return {'books': 0, 'read': 0, 'wishlist': 0};

    try {
      print('🔵 Fetching profile stats...');
      
      // Get purchased books count
      final purchasedBooks = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('purchasedBooks')
          .get();

      // Get wishlist count
      final wishlist = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('wishlist')
          .get();

      // Get read books count (books purchased more than 7 days ago)
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final readBooks = purchasedBooks.docs.where((doc) {
        final data = doc.data();
        if (data.containsKey('purchasedAt')) {
          final purchasedAt = (data['purchasedAt'] as Timestamp).toDate();
          return purchasedAt.isBefore(sevenDaysAgo);
        }
        return false;
      }).length;

      print('✅ Stats loaded: ${purchasedBooks.size} books, $readBooks read, ${wishlist.size} wishlist');

      return {
        'books': purchasedBooks.size,
        'read': readBooks,
        'wishlist': wishlist.size,
      };
    } catch (e) {
      print('❌ Error loading stats: $e');
      return {'books': 0, 'read': 0, 'wishlist': 0};
    }
  }

  // Get user preferences
  Future<Map<String, dynamic>> getPreferences() async {
    if (_userId == null) {
      return {
        'notifications': true,
        'emailNotifications': true,
        'pushNotifications': true,
        'darkMode': false,
      };
    }

    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('preferences')) {
          return data['preferences'] as Map<String, dynamic>;
        }
      }
      
      // Return defaults if not found
      return {
        'notifications': true,
        'emailNotifications': true,
        'pushNotifications': true,
        'darkMode': false,
      };
    } catch (e) {
      print('❌ Error loading preferences: $e');
      return {
        'notifications': true,
        'emailNotifications': true,
        'pushNotifications': true,
        'darkMode': false,
      };
    }
  }

  // Update preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    if (_userId == null) return;

    try {
      print('🔵 Updating preferences...');
      await _firestore.collection('users').doc(_userId).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Save dark mode to local storage for quick access
      if (preferences.containsKey('darkMode')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('darkMode', preferences['darkMode']);
      }

      print('✅ Preferences updated');
    } catch (e) {
      print('❌ Error updating preferences: $e');
    }
  }

  // Get dark mode preference
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkMode') ?? false;
  }

  // Toggle dark mode
  Future<void> toggleDarkMode(bool value) async {
    final currentPrefs = await getPreferences();
    currentPrefs['darkMode'] = value;
    await updatePreferences(currentPrefs);
  }

  // Get orders count
  Future<int> getOrdersCount() async {
    if (_userId == null) return 0;

    try {
      final orders = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .get();
      
      return orders.size;
    } catch (e) {
      print('❌ Error loading orders count: $e');
      return 0;
    }
  }

  // Get recent orders
  Future<List<Map<String, dynamic>>> getRecentOrders({int limit = 5}) async {
    if (_userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error loading recent orders: $e');
      return [];
    }
  }

  // Get wishlist items
  Future<List<Map<String, dynamic>>> getWishlistItems() async {
    if (_userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('wishlist')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Error loading wishlist: $e');
      return [];
    }
  }

  // Stream of user profile
  Stream<Map<String, dynamic>?> getUserProfileStream() {
    if (_userId == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  // Delete account
  Future<void> deleteAccount() async {
    if (_userId == null) throw 'User not authenticated';

    try {
      print('🔵 Deleting user account...');
      
      // Delete user data from Firestore
      await _firestore.collection('users').doc(_userId).delete();
      
      // Delete user from Firebase Auth
      await currentUser?.delete();
      
      print('✅ Account deleted');
    } catch (e) {
      print('❌ Error deleting account: $e');
      throw 'Failed to delete account: ${e.toString()}';
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentUser == null) throw 'User not authenticated';

    try {
      print('🔵 Changing password...');
      
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: currentPassword,
      );
      
      await currentUser!.reauthenticateWithCredential(credential);
      
      // Update password
      await currentUser!.updatePassword(newPassword);
      
      print('✅ Password changed successfully');
    } catch (e) {
      print('❌ Error changing password: $e');
      if (e.toString().contains('wrong-password')) {
        throw 'Current password is incorrect';
      }
      throw 'Failed to change password: ${e.toString()}';
    }
  }

  // Update email
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    if (currentUser == null) throw 'User not authenticated';

    try {
      print('🔵 Updating email...');
      
      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      
      await currentUser!.reauthenticateWithCredential(credential);
      
      // Update email
      await currentUser!.updateEmail(newEmail);
      
      // Update email in Firestore
      await _firestore.collection('users').doc(_userId).update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Send verification email
      await currentUser!.sendEmailVerification();
      
      print('✅ Email updated successfully');
    } catch (e) {
      print('❌ Error updating email: $e');
      if (e.toString().contains('wrong-password')) {
        throw 'Password is incorrect';
      } else if (e.toString().contains('email-already-in-use')) {
        throw 'Email is already in use';
      }
      throw 'Failed to update email: ${e.toString()}';
    }
  }
}