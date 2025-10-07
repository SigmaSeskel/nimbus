import 'package:flutter/material.dart';
import 'book_detail_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All';

  // Sample book data
  final List<Map<String, dynamic>> _books = [
    {
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'price': 9.99,
      'rating': 4.5,
      'category': 'Fiction',
      'image': 'https://via.placeholder.com/150x200/6C63FF/FFFFFF?text=Book+1',
    },
    {
      'title': 'To Kill a Mockingbird',
      'author': 'Harper Lee',
      'price': 12.99,
      'rating': 4.8,
      'category': 'Fiction',
      'image': 'https://via.placeholder.com/150x200/4CAF50/FFFFFF?text=Book+2',
    },
    {
      'title': '1984',
      'author': 'George Orwell',
      'price': 10.99,
      'rating': 4.7,
      'category': 'Fiction',
      'image': 'https://via.placeholder.com/150x200/FF6B6B/FFFFFF?text=Book+3',
    },
    {
      'title': 'Sapiens',
      'author': 'Yuval Noah Harari',
      'price': 15.99,
      'rating': 4.9,
      'category': 'Non-Fiction',
      'image': 'https://via.placeholder.com/150x200/FFA726/FFFFFF?text=Book+4',
    },
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'price': 13.99,
      'rating': 4.8,
      'category': 'Self-Help',
      'image': 'https://via.placeholder.com/150x200/42A5F5/FFFFFF?text=Book+5',
    },
    {
      'title': 'The Lean Startup',
      'author': 'Eric Ries',
      'price': 14.99,
      'rating': 4.6,
      'category': 'Business',
      'image': 'https://via.placeholder.com/150x200/AB47BC/FFFFFF?text=Book+6',
    },
  ];

  List<String> _categories = [
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
          // App Bar
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
                ],
              ),
            ),
          ),

          // Categories Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: const Text(
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
    return GestureDetector(
      onTap: () {
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
            // Book Cover
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: NetworkImage(book['image']),
                    fit: BoxFit.cover,
                  ),
                ),
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
                        '\$${book['price'].toStringAsFixed(2)}',
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
}