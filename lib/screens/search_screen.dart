import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Relevance';
  double _minPrice = 0;
  double _maxPrice = 50;
  double _minRating = 0;

  // Sample books data
  final List<Map<String, dynamic>> _allBooks = [
    {
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'price': 9.99,
      'rating': 4.5,
      'category': 'Fiction',
      'image': 'https://via.placeholder.com/150x200/64B5F6/FFFFFF?text=Book+1',
    },
    {
      'title': 'To Kill a Mockingbird',
      'author': 'Harper Lee',
      'price': 12.99,
      'rating': 4.8,
      'category': 'Fiction',
      'image': 'https://via.placeholder.com/150x200/81C784/FFFFFF?text=Book+2',
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
    {
      'title': 'Thinking, Fast and Slow',
      'author': 'Daniel Kahneman',
      'price': 16.99,
      'rating': 4.8,
      'category': 'Psychology',
      'image': 'https://via.placeholder.com/150x200/FF8A65/FFFFFF?text=Book+7',
    },
    {
      'title': 'The Power of Now',
      'author': 'Eckhart Tolle',
      'price': 11.99,
      'rating': 4.7,
      'category': 'Self-Help',
      'image': 'https://via.placeholder.com/150x200/26C6DA/FFFFFF?text=Book+8',
    },
  ];

  List<Map<String, dynamic>> get _filteredBooks {
    var filtered = _allBooks.where((book) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final title = book['title'].toString().toLowerCase();
        final author = book['author'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!title.contains(query) && !author.contains(query)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != 'All' && book['category'] != _selectedCategory) {
        return false;
      }

      // Price filter
      final price = (book['price'] as num).toDouble();
      if (price < _minPrice || price > _maxPrice) {
        return false;
      }

      // Rating filter
      final rating = (book['rating'] as num).toDouble();
      if (rating < _minRating) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    if (_sortBy == 'Price: Low to High') {
      filtered.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
    } else if (_sortBy == 'Price: High to Low') {
      filtered.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
    } else if (_sortBy == 'Rating') {
      filtered.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
    } else if (_sortBy == 'Title') {
      filtered.sort((a, b) => a['title'].toString().compareTo(b['title'].toString()));
    }

    return filtered;
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _minPrice = 0;
      _maxPrice = 50;
      _minRating = 0;
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                _resetFilters();
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['All', 'Fiction', 'Non-Fiction', 'Business', 'Self-Help', 'Psychology']
                    .map((cat) => FilterChip(
                          label: Text(cat),
                          selected: _selectedCategory == cat,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = cat);
                            Navigator.pop(context);
                          },
                          selectedColor: const Color(0xFF64B5F6).withOpacity(0.2),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 24),

              // Price Range
              const Text(
                'Price Range',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setDialogState) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${_minPrice.toInt()}'),
                        Text('\$${_maxPrice.toInt()}'),
                      ],
                    ),
                    RangeSlider(
                      values: RangeValues(_minPrice, _maxPrice),
                      min: 0,
                      max: 50,
                      divisions: 50,
                      activeColor: const Color(0xFF64B5F6),
                      onChanged: (values) {
                        setDialogState(() {
                          _minPrice = values.start;
                          _maxPrice = values.end;
                        });
                        setState(() {
                          _minPrice = values.start;
                          _maxPrice = values.end;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Rating
              const Text(
                'Minimum Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  _buildRatingChip('All', 0),
                  _buildRatingChip('3+', 3),
                  _buildRatingChip('4+', 4),
                  _buildRatingChip('4.5+', 4.5),
                ],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(String label, double rating) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: _minRating == rating,
      onSelected: (selected) {
        setState(() => _minRating = rating);
        Navigator.pop(context);
      },
      selectedColor: const Color(0xFF64B5F6).withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = _filteredBooks;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text(
          'Search Books',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by title or author...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64B5F6)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFE3F2FD),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showFilterDialog,
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Filters'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64B5F6),
                          side: const BorderSide(color: Color(0xFF64B5F6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PopupMenuButton<String>(
                        onSelected: (value) => setState(() => _sortBy = value),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF64B5F6)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sort, color: Color(0xFF64B5F6)),
                              SizedBox(width: 8),
                              Text('Sort', style: TextStyle(color: Color(0xFF64B5F6))),
                            ],
                          ),
                        ),
                        itemBuilder: (context) => [
                          'Relevance',
                          'Price: Low to High',
                          'Price: High to Low',
                          'Rating',
                          'Title',
                        ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          if (books.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${books.length} ${books.length == 1 ? 'result' : 'results'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          Expanded(
            child: books.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No books found', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) => _buildBookCard(books[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${book['title']} clicked')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage(book['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book['author'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${book['price']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64B5F6),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${book['rating']}', style: const TextStyle(fontSize: 12)),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}