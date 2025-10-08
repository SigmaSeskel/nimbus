import 'package:flutter/material.dart';
import 'package:nimbus/services/firestore_service.dart';
import 'package:nimbus/services/notification_service.dart';
import 'book_detail_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  int _selectedIndex = 0;
  String _selectedCategory = 'All';

  // Sample book data with IDs for Firestore and real book covers
  final List<Map<String, dynamic>> _books = [
    {
      'id': 'book1',
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'price': 9.99,
      'rating': 4.5,
      'category': 'Fiction',
      'image': 'https://covers.openlibrary.org/b/id/7883328-L.jpg',
    },
    {
      'id': 'book2',
      'title': 'To Kill a Mockingbird',
      'author': 'Harper Lee',
      'price': 12.99,
      'rating': 4.8,
      'category': 'Fiction',
      'image': 'https://covers.openlibrary.org/b/id/8228691-L.jpg',
    },
    {
      'id': 'book3',
      'title': '1984',
      'author': 'George Orwell',
      'price': 10.99,
      'rating': 4.7,
      'category': 'Fiction',
      'image': 'https://covers.openlibrary.org/b/id/7222246-L.jpg',
    },
    {
      'id': 'book4',
      'title': 'Sapiens',
      'author': 'Yuval Noah Harari',
      'price': 15.99,
      'rating': 4.9,
      'category': 'Non-Fiction',
      'image': 'https://covers.openlibrary.org/b/id/8398678-L.jpg',
    },
    {
      'id': 'book5',
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'price': 13.99,
      'rating': 4.8,
      'category': 'Self-Help',
      'image': 'https://covers.openlibrary.org/b/id/10958382-L.jpg',
    },
    {
      'id': 'book6',
      'title': 'The Lean Startup',
      'author': 'Eric Ries',
      'price': 14.99,
      'rating': 4.6,
      'category': 'Business',
      'image': 'https://covers.openlibrary.org/b/id/7895270-L.jpg',
    },
    {
      'id': 'book7',
      'title': 'Educated',
      'author': 'Tara Westover',
      'price': 13.99,
      'rating': 4.7,
      'category': 'Non-Fiction',
      'image': 'https://covers.openlibrary.org/b/id/8904867-L.jpg',
    },
    {
      'id': 'book8',
      'title': 'Thinking, Fast and Slow',
      'author': 'Daniel Kahneman',
      'price': 16.99,
      'rating': 4.6,
      'category': 'Non-Fiction',
      'image': 'https://covers.openlibrary.org/b/id/8509955-L.jpg',
    },
    {
      'id': 'book9',
      'title': 'The Power of Now',
      'author': 'Eckhart Tolle',
      'price': 11.99,
      'rating': 4.5,
      'category': 'Self-Help',
      'image': 'https://covers.openlibrary.org/b/id/258021-L.jpg',
    },
    {
      'id': 'book10',
      'title': 'Steve Jobs',
      'author': 'Walter Isaacson',
      'price': 14.99,
      'rating': 4.7,
      'category': 'Non-Fiction',
      'image': 'https://covers.openlibrary.org/b/id/7899183-L.jpg',
    },
    {
      'id': 'book11',
      'title': 'The 7 Habits of Highly Effective People',
      'author': 'Stephen R. Covey',
      'price': 12.99,
      'rating': 4.6,
      'category': 'Self-Help',
      'image': 'https://covers.openlibrary.org/b/id/8665156-L.jpg',
    },
    {
      'id': 'book12',
      'title': 'Zero to One',
      'author': 'Peter Thiel',
      'price': 13.99,
      'rating': 4.5,
      'category': 'Business',
      'image': 'https://covers.openlibrary.org/b/id/8091206-L.jpg',
    },
    {
      'id': 'book13',
      'title': 'The Alchemist',
      'author': 'Paulo Coelho',
      'price': 10.99,
      'rating': 4.7,
      'category': 'Fiction',
      'image': 'https://covers.openlibrary.org/b/id/8739161-L.jpg',
    },
    {
      'id': 'book14',
      'title': 'Man\'s Search for Meaning',
      'author': 'Viktor E. Frankl',
      'price': 9.99,
      'rating': 4.8,
      'category': 'Non-Fiction',
      'image': 'https://covers.openlibrary.org/b/id/8452784-L.jpg',
    },
    {
      'id': 'book15',
      'title': 'Rich Dad Poor Dad',
      'author': 'Robert T. Kiyosaki',
      'price': 11.99,
      'rating': 4.6,
      'category': 'Business',
      'image': 'https://covers.openlibrary.org/b/id/8536457-L.jpg',
    },
    {
      'id': 'book16',
      'title': 'The Subtle Art of Not Giving a F*ck',
      'author': 'Mark Manson',
      'price': 12.99,
      'rating': 4.5,
      'category': 'Self-Help',
      'image': 'https://covers.openlibrary.org/b/id/8363698-L.jpg',
    },
    {
      'id': 'book17',
      'title': 'Shoe Dog',
      'author': 'Phil Knight',
      'price': 13.99,
      'rating': 4.7,
      'category': 'Non-Fiction',
      'image': 'https://covers.openlibrary.org/b/id/8286104-L.jpg',
    },
    {
      'id': 'book18',
      'title': 'The Four Agreements',
      'author': 'Don Miguel Ruiz',
      'price': 10.99,
      'rating': 4.6,
      'category': 'Self-Help',
      'image': 'https://covers.openlibrary.org/b/id/6979861-L.jpg',
    },
  ];

  final List<String> _categories = [
    'All',
    'Fiction',
    'Non-Fiction',
    'Business',
    'Self-Help',
    'Science',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _selectedIndex == 0 ? _buildHomeContent() : _buildLibraryContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      selectedItemColor: const Color(0xFF64B5F6),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_books_outlined),
          activeIcon: Icon(Icons.library_books),
          label: 'My Library',
        ),
      ],
    );
  }

  Widget _buildHomeContent() {
    final filteredBooks = _selectedCategory == 'All'
        ? _books
        : _books.where((book) => book['category'] == _selectedCategory).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar with Notifications
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Nimbus',
              style: TextStyle(
                fontFamily: 'Georgia',
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
                fontSize: 32,
                letterSpacing: 1.5,
              ),
            ),
            actions: [
              // Notifications with badge
              StreamBuilder<int>(
                stream: _notificationService.getUnreadCount(),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;
                  
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              // Cart with badge
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.streamCart(),
                builder: (context, snapshot) {
                  final itemCount = snapshot.data?.length ?? 0;
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                      ),
                      if (itemCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$itemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        'Search books...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Welcome Banner
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF64B5F6), Color(0xFF81C784)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover your next favorite book',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF64B5F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Explore Now'),
                      ),
                      const SizedBox(width: 12),
                      // Test notification button (for development)
                      OutlinedButton(
                        onPressed: () {
                          _notificationService.createSampleNotifications();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sample notifications created!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Test Notifications'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Continue Reading Section (NEW)
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firestoreService.streamContinueReading(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Continue Reading',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => _selectedIndex = 1);
                            },
                            child: const Text('See All'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final progress = snapshot.data![index];
                          return Container(
                            width: 250,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Book Title', // Fetch from Firestore in production
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: (progress['progress'] as int? ?? 0) / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: const AlwaysStoppedAnimation(Color(0xFF64B5F6)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${progress['progress'] ?? 0}% complete',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Categories Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Categories List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: const Color(0xFF64B5F6).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFF64B5F6) : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF64B5F6) : Colors.transparent,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Popular Books Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Books',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),

          // Books Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final book = filteredBooks[index];
                  return _buildBookCard(book);
                },
                childCount: filteredBooks.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

 Widget _buildBookCard(Map<String, dynamic> book) {
  final bookId = book['id'] as String;
  
  return GestureDetector(
    onTap: () async {
      // Add to recently viewed
      await _firestoreService.addToRecentlyViewed(bookId, book);
      
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailScreen(book: book),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover with Wishlist Heart
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage(
                      image: NetworkImage(book['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Wishlist Heart
                Positioned(
                  top: 8,
                  right: 8,
                  child: StreamBuilder<bool>(
                    stream: _firestoreService.streamWishlistStatus(bookId),
                    builder: (context, snapshot) {
                      final isWishlisted = snapshot.data ?? false;
                      
                      return GestureDetector(
                        onTap: () async {
                          if (isWishlisted) {
                            await _firestoreService.removeFromWishlist(bookId);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Removed from wishlist'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.grey[800],
                                ),
                              );
                            }
                          } else {
                            await _firestoreService.addToWishlist(bookId, book);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Added to wishlist ❤️'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.red[400],
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isWishlisted 
                                ? Colors.white 
                                : Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? Colors.red : Colors.white,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Book Info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book['author'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${(book['price'] as num).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64B5F6),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book['rating'].toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildLibraryContent() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.streamLibrary(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your library is empty',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                  child: const Text('Browse Books'),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, size: 48),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Book Title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}