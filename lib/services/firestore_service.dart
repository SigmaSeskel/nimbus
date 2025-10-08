// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ==================== CART OPERATIONS ====================

  // Add book to cart
  Future<void> addToCart(Map<String, dynamic> book) async {
    if (_userId == null) throw 'User not logged in';

    try {
      await _firestore.collection('users').doc(_userId).update({
        'cart': FieldValue.arrayUnion([book])
      });
    } catch (e) {
      throw 'Failed to add to cart';
    }
  }

  // Remove book from cart
  Future<void> removeFromCart(String bookId) async {
    if (_userId == null) throw 'User not logged in';

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_userId).get();
      List cart = (doc.data() as Map<String, dynamic>)['cart'] ?? [];
      
      cart.removeWhere((item) => item['id'] == bookId);
      
      await _firestore.collection('users').doc(_userId).update({
        'cart': cart,
      });
    } catch (e) {
      throw 'Failed to remove from cart';
    }
  }

  // Get cart items (real-time stream)
  Stream<List<Map<String, dynamic>>> getCartStream() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return [];
      
      final data = snapshot.data() as Map<String, dynamic>?;
      final cart = data?['cart'] as List<dynamic>?;
      
      return cart?.map((item) => item as Map<String, dynamic>).toList() ?? [];
    });
  }

  // Get cart items (one-time)
  Future<List<Map<String, dynamic>>> getCart() async {
    if (_userId == null) return [];

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_userId).get();
      
      if (!doc.exists) return [];
      
      final data = doc.data() as Map<String, dynamic>?;
      final cart = data?['cart'] as List<dynamic>?;
      
      return cart?.map((item) => item as Map<String, dynamic>).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    if (_userId == null) throw 'User not logged in';

    try {
      await _firestore.collection('users').doc(_userId).update({
        'cart': [],
      });
    } catch (e) {
      throw 'Failed to clear cart';
    }
  }

  // ==================== WISHLIST OPERATIONS ====================

  // Add book to wishlist
  Future<void> addToWishlist(Map<String, dynamic> book) async {
    if (_userId == null) throw 'User not logged in';

    try {
      await _firestore.collection('users').doc(_userId).update({
        'wishlist': FieldValue.arrayUnion([book])
      });
    } catch (e) {
      throw 'Failed to add to wishlist';
    }
  }

  // Remove book from wishlist
  Future<void> removeFromWishlist(String bookId) async {
    if (_userId == null) throw 'User not logged in';

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_userId).get();
      List wishlist = (doc.data() as Map<String, dynamic>)['wishlist'] ?? [];
      
      wishlist.removeWhere((item) => item['id'] == bookId);
      
      await _firestore.collection('users').doc(_userId).update({
        'wishlist': wishlist,
      });
    } catch (e) {
      throw 'Failed to remove from wishlist';
    }
  }

  // Get wishlist items (real-time stream)
  Stream<List<Map<String, dynamic>>> getWishlistStream() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return [];
      
      final data = snapshot.data() as Map<String, dynamic>?;
      final wishlist = data?['wishlist'] as List<dynamic>?;
      
      return wishlist?.map((item) => item as Map<String, dynamic>).toList() ?? [];
    });
  }

  // Get wishlist items (one-time)
  Future<List<Map<String, dynamic>>> getWishlist() async {
    if (_userId == null) return [];

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_userId).get();
      
      if (!doc.exists) return [];
      
      final data = doc.data() as Map<String, dynamic>?;
      final wishlist = data?['wishlist'] as List<dynamic>?;
      
      return wishlist?.map((item) => item as Map<String, dynamic>).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  // Check if book is in wishlist
  Future<bool> isInWishlist(String bookId) async {
    if (_userId == null) return false;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_userId).get();
      List wishlist = (doc.data() as Map<String, dynamic>)['wishlist'] ?? [];
      
      return wishlist.any((item) => item['id'] == bookId);
    } catch (e) {
      return false;
    }
  }

  // ==================== PURCHASED BOOKS ====================

  // Add purchased book
  Future<void> addPurchasedBook(Map<String, dynamic> book) async {
    if (_userId == null) throw 'User not logged in';

    try {
      await _firestore.collection('users').doc(_userId).update({
        'purchasedBooks': FieldValue.arrayUnion([{
          ...book,
          'purchaseDate': FieldValue.serverTimestamp(),
        }])
      });
    } catch (e) {
      throw 'Failed to record purchase';
    }
  }

  // Get purchased books
  Future<List<Map<String, dynamic>>> getPurchasedBooks() async {
    if (_userId == null) return [];

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_userId).get();
      
      if (!doc.exists) return [];
      
      final data = doc.data() as Map<String, dynamic>?;
      final books = data?['purchasedBooks'] as List<dynamic>?;
      
      return books?.map((item) => item as Map<String, dynamic>).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  // ==================== BOOKS COLLECTION ====================

  // Get all books from Firestore
  Stream<List<Map<String, dynamic>>> getBooksStream() {
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  // Get single book by ID
  Future<Map<String, dynamic>?> getBook(String bookId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('books').doc(bookId).get();
      
      if (!doc.exists) return null;
      
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    } catch (e) {
      return null;
    }
  }

  // Search books
  Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('books')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get books by category
  Stream<List<Map<String, dynamic>>> getBooksByCategory(String category) {
    return _firestore
        .collection('books')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    });
  }

  // Add a book (admin function - for demo purposes)
  Future<void> addBook(Map<String, dynamic> bookData) async {
    try {
      await _firestore.collection('books').add({
        ...bookData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to add book';
    }
  }
}