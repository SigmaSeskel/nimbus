import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ==================== WISHLIST ====================
  
  // Add book to wishlist
  Future<void> addToWishlist(String bookId, Map<String, dynamic> bookData) async {
    if (_userId == null) throw 'User not logged in';
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist')
        .doc(bookId)
        .set({
      ...bookData,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove book from wishlist
  Future<void> removeFromWishlist(String bookId) async {
    if (_userId == null) throw 'User not logged in';
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist')
        .doc(bookId)
        .delete();
  }

  // Check if book is in wishlist
  Future<bool> isInWishlist(String bookId) async {
    if (_userId == null) return false;
    
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist')
        .doc(bookId)
        .get();
    
    return doc.exists;
  }

  // Stream wishlist items
  Stream<List<Map<String, dynamic>>> streamWishlist() {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // Real-time stream for wishlist status
  Stream<bool> streamWishlistStatus(String bookId) {
    if (_userId == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('wishlist')
        .doc(bookId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ==================== RECENTLY VIEWED ====================
  
  // Add book to recently viewed (limit to 10)
  Future<void> addToRecentlyViewed(String bookId, Map<String, dynamic> bookData) async {
    if (_userId == null) return;
    
    final recentRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('recentlyViewed');
    
    // Add/update the book
    await recentRef.doc(bookId).set({
      ...bookData,
      'viewedAt': FieldValue.serverTimestamp(),
    });
    
    // Keep only last 10 items
    final snapshot = await recentRef
        .orderBy('viewedAt', descending: true)
        .get();
    
    if (snapshot.docs.length > 10) {
      // Delete oldest items
      for (int i = 10; i < snapshot.docs.length; i++) {
        await snapshot.docs[i].reference.delete();
      }
    }
  }

  // Stream recently viewed books
  Stream<List<Map<String, dynamic>>> streamRecentlyViewed() {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('recentlyViewed')
        .orderBy('viewedAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ==================== READING PROGRESS ====================
  
  // Update reading progress
  Future<void> updateProgress({
    required String bookId,
    required int currentPage,
    required int totalPages,
  }) async {
    if (_userId == null) return;
    
    final progress = (currentPage / totalPages * 100).round();
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('progress')
        .doc(bookId)
        .set({
      'currentPage': currentPage,
      'totalPages': totalPages,
      'progress': progress,
      'lastReadAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get reading progress for a book
  Future<Map<String, dynamic>?> getProgress(String bookId) async {
    if (_userId == null) return null;
    
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('progress')
        .doc(bookId)
        .get();
    
    return doc.exists ? doc.data() : null;
  }

  // Stream continue reading books (books with progress > 0 and < 100)
  Stream<List<Map<String, dynamic>>> streamContinueReading() {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('progress')
        .where('progress', isGreaterThan: 0)
        .where('progress', isLessThan: 100)
        .orderBy('progress')
        .orderBy('lastReadAt', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'bookId': doc.id, ...doc.data()})
            .toList());
  }

  // ==================== BOOKMARKS, HIGHLIGHTS & NOTES ====================
  
  // Add bookmark
  Future<void> addBookmark({
    required String bookId,
    required int pageNumber,
    String? chapterTitle,
  }) async {
    if (_userId == null) throw 'User not logged in';
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .add({
      'bookId': bookId,
      'type': 'bookmark',
      'pageNumber': pageNumber,
      'chapterTitle': chapterTitle,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove bookmark
  Future<void> removeBookmark(String noteId) async {
    if (_userId == null) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  // Add highlight with optional note
  Future<void> addHighlight({
    required String bookId,
    required int pageNumber,
    required String selectedText,
    String? note,
    String color = 'yellow',
  }) async {
    if (_userId == null) throw 'User not logged in';
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .add({
      'bookId': bookId,
      'type': 'highlight',
      'pageNumber': pageNumber,
      'selectedText': selectedText,
      'note': note,
      'color': color,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream bookmarks for a book
  Stream<List<Map<String, dynamic>>> streamBookmarks(String bookId) {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .where('bookId', isEqualTo: bookId)
        .where('type', isEqualTo: 'bookmark')
        .orderBy('pageNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // Stream highlights for a book
  Stream<List<Map<String, dynamic>>> streamHighlights(String bookId) {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notes')
        .where('bookId', isEqualTo: bookId)
        .where('type', isEqualTo: 'highlight')
        .orderBy('pageNumber')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ==================== REVIEWS ====================
  
  // Add or update review
  Future<void> addReview({
    required String bookId,
    required double rating,
    required String reviewText,
  }) async {
    if (_userId == null) throw 'User not logged in';
    
    final user = _auth.currentUser!;
    
    // Add review
    await _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .doc(_userId)
        .set({
      'userId': _userId,
      'userName': user.displayName ?? 'Anonymous',
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Update book's average rating (trigger Cloud Function in production)
    await _updateBookRating(bookId);
  }

  // Update book rating (simplified - use Cloud Function in production)
  Future<void> _updateBookRating(String bookId) async {
    final reviews = await _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .get();
    
    if (reviews.docs.isEmpty) return;
    
    double totalRating = 0;
    for (var doc in reviews.docs) {
      totalRating += (doc.data()['rating'] as num).toDouble();
    }
    
    final averageRating = totalRating / reviews.docs.length;
    
    await _firestore.collection('books').doc(bookId).set({
      'averageRating': averageRating,
      'reviewCount': reviews.docs.length,
    }, SetOptions(merge: true));
  }

  // Stream reviews for a book
  Stream<List<Map<String, dynamic>>> streamReviews(String bookId) {
    return _firestore
        .collection('books')
        .doc(bookId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ==================== CART ====================
  
  // Add book to cart
  Future<void> addToCart(String bookId, Map<String, dynamic> bookData) async {
    if (_userId == null) throw 'User not logged in';
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .doc(bookId)
        .set({
      ...bookData,
      'quantity': 1,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove from cart
  Future<void> removeFromCart(String bookId) async {
    if (_userId == null) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .doc(bookId)
        .delete();
  }

  // Update cart item quantity
  Future<void> updateCartQuantity(String bookId, int quantity) async {
    if (_userId == null) return;
    
    if (quantity <= 0) {
      await removeFromCart(bookId);
    } else {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc(bookId)
          .update({'quantity': quantity});
    }
  }

  // Stream cart items
  Stream<List<Map<String, dynamic>>> streamCart() {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // Clear cart
  Future<void> clearCart() async {
    if (_userId == null) return;
    
    final cartRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart');
    
    final snapshot = await cartRef.get();
    
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ==================== SEARCH & FILTERS ====================
  
  // Search books (basic - use Algolia or ElasticSearch for production)
  Future<List<Map<String, dynamic>>> searchBooks({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> booksQuery = _firestore.collection('books');
    
    // Apply filters
    if (category != null && category != 'All') {
      booksQuery = booksQuery.where('category', isEqualTo: category);
    }
    
    if (minPrice != null) {
      booksQuery = booksQuery.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    
    if (maxPrice != null) {
      booksQuery = booksQuery.where('price', isLessThanOrEqualTo: maxPrice);
    }
    
    if (minRating != null) {
      booksQuery = booksQuery.where('averageRating', isGreaterThanOrEqualTo: minRating);
    }
    
    booksQuery = booksQuery.limit(limit);
    
    final snapshot = await booksQuery.get();
    
    List<Map<String, dynamic>> results = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
    
    // Simple text search (filter results in memory)
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results.where((book) {
        final title = (book['title'] as String? ?? '').toLowerCase();
        final author = (book['author'] as String? ?? '').toLowerCase();
        return title.contains(lowerQuery) || author.contains(lowerQuery);
      }).toList();
    }
    
    return results;
  }

  // Get books by category
  Stream<List<Map<String, dynamic>>> streamBooksByCategory(String category) {
    Query<Map<String, dynamic>> query = _firestore.collection('books');
    
    if (category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    
    return query
        .orderBy('averageRating', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // ==================== PURCHASES ====================
  
  // Record purchase (simplified - use Cloud Functions + payment provider)
  Future<void> recordPurchase(List<String> bookIds, double totalAmount) async {
    if (_userId == null) throw 'User not logged in';
    
    final orderId = _firestore.collection('orders').doc().id;
    
    // Create order
    await _firestore.collection('orders').doc(orderId).set({
      'userId': _userId,
      'bookIds': bookIds,
      'totalAmount': totalAmount,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Add books to user's library
    for (String bookId in bookIds) {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('library')
          .doc(bookId)
          .set({
        'purchasedAt': FieldValue.serverTimestamp(),
        'orderId': orderId,
      });
    }
    
    // Clear cart after purchase
    await clearCart();
  }

  // Check if user owns a book
  Future<bool> ownsBook(String bookId) async {
    if (_userId == null) return false;
    
    final doc = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('library')
        .doc(bookId)
        .get();
    
    return doc.exists;
  }

  // Stream user's library
  Stream<List<Map<String, dynamic>>> streamLibrary() {
    if (_userId == null) return Stream.value([]);
    
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('library')
        .orderBy('purchasedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'bookId': doc.id, ...doc.data()})
            .toList());
  }
}