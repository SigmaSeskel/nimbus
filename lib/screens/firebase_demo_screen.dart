// lib/screens/firebase_demo_screen.dart
import 'package:flutter/material.dart';
import 'package:nimbus/services/auth_service.dart';
import 'package:nimbus/services/firestore_service.dart';

class FirebaseDemoScreen extends StatefulWidget {
  const FirebaseDemoScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseDemoScreen> createState() => _FirebaseDemoScreenState();
}

class _FirebaseDemoScreenState extends State<FirebaseDemoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  // Sample book data
  final Map<String, dynamic> sampleBook1 = {
    'id': 'book1',
    'title': 'The Great Gatsby',
    'author': 'F. Scott Fitzgerald',
    'price': 9.99,
    'coverUrl': 'https://covers.openlibrary.org/b/id/7222246-L.jpg',
    'rating': 4.5,
    'category': 'Classic',
  };

  final Map<String, dynamic> sampleBook2 = {
    'id': 'book2',
    'title': '1984',
    'author': 'George Orwell',
    'price': 12.99,
    'coverUrl': 'https://covers.openlibrary.org/b/id/7222246-L.jpg',
    'rating': 4.8,
    'category': 'Classic',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Firebase Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👤 Current User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Name: ${_authService.currentUser?.displayName ?? "No name"}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      'Email: ${_authService.currentUser?.email ?? "No email"}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Cart Section
            const Text(
              '🛒 Shopping Cart (Real-time)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getCartStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final cart = snapshot.data ?? [];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Cart Items: ${cart.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (cart.isEmpty)
                        const Text('Your cart is empty')
                      else
                        ...cart.map((book) => ListTile(
                              title: Text(book['title'] ?? 'Unknown'),
                              subtitle: Text('\$${book['price']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await _firestoreService.removeFromCart(book['id']);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Removed from cart'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            )),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Add to Cart Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _firestoreService.addToCart(sampleBook1);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to cart!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add Book 1'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64B5F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _firestoreService.addToCart(sampleBook2);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to cart!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add Book 2'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF81C784),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Wishlist Section
            const Text(
              '❤️ Wishlist (Real-time)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.getWishlistStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final wishlist = snapshot.data ?? [];

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0B2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Wishlist Items: ${wishlist.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (wishlist.isEmpty)
                        const Text('Your wishlist is empty')
                      else
                        ...wishlist.map((book) => ListTile(
                              title: Text(book['title'] ?? 'Unknown'),
                              subtitle: Text(book['author'] ?? 'Unknown Author'),
                              trailing: IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await _firestoreService.removeFromWishlist(book['id']);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Removed from wishlist'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                              ),
                            )),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Add to Wishlist Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _firestoreService.addToWishlist(sampleBook1);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to wishlist!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Wishlist Book 1'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A65),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _firestoreService.addToWishlist(sampleBook2);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to wishlist!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Wishlist Book 2'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8A65),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Clear Cart Button
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  await _firestoreService.clearCart();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cart cleared!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Cart'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFF64B5F6)),
              ),
            ),

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF81C784)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF81C784)),
                      SizedBox(width: 8),
                      Text(
                        'Firebase Features Working:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem('✅ Real-time sync - Changes appear instantly'),
                  _buildFeatureItem('✅ Cloud storage - Data saved to Firestore'),
                  _buildFeatureItem('✅ Authentication - User logged in'),
                  _buildFeatureItem('✅ Cart & Wishlist - Persistent storage'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 14,
        ),
      ),
    );
  }
}