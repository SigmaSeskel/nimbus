import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'wishlist_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Sample user data
  final String userName = 'John Doe';
  final String userEmail = 'johndoe@example.com';
  final String userPhone = '+1 234 567 8900';
  final String userBio = 'Book lover and avid reader 📚';
  final int booksOwned = 24;
  final int booksRead = 18;
  final int wishlistCount = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF64B5F6),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF64B5F6),
                      Color(0xFF81C784),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Profile Picture
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: Text(
                            userName[0],
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64B5F6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // User Name
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // User Email
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  _showEditProfileDialog();
                },
              ),
            ],
          ),

          // Stats Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Books Owned',
                      booksOwned.toString(),
                      Icons.library_books,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Books Read',
                      booksRead.toString(),
                      Icons.menu_book,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Wishlist',
                      wishlistCount.toString(),
                      Icons.favorite,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Account Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      Icons.person_outline,
                      'Personal Information',
                      'Update your personal details',
                      () => _showComingSoon(context),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.phone_outlined,
                      'Phone Number',
                      userPhone,
                      () => _showComingSoon(context),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.location_on_outlined,
                      'Address',
                      'Manage your addresses',
                      () => _showComingSoon(context),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // Library Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Library',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      Icons.library_books_outlined,
                      'My Books',
                      'View your book collection',
                      () => _showComingSoon(context),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.favorite_border,
                      'Wishlist',
                      '$wishlistCount books in wishlist',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WishlistScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.shopping_cart_outlined,
                      'My Cart',
                      'View items in cart',
                      () => _showComingSoon(context),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.history,
                      'Order History',
                      'View past purchases',
                      () => _showComingSoon(context),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // Settings Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      Icons.settings_outlined,
                      'All Settings',
                      'View and manage all settings',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.notifications_outlined,
                      'Notifications',
                      'Manage notification preferences',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.language_outlined,
                      'Language',
                      'English',
                      () => _showComingSoon(context),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.dark_mode_outlined,
                      'Dark Mode',
                      'Switch to dark theme',
                      () => _showComingSoon(context),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.security_outlined,
                      'Privacy & Security',
                      'Manage your privacy settings',
                      () => _showComingSoon(context),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // Support Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      Icons.help_outline,
                      'Help Center',
                      'Get help and support',
                      () => _showComingSoon(context),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.info_outline,
                      'About',
                      'App version 1.0.0',
                      () => _showAboutDialog(context),
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      Icons.description_outlined,
                      'Terms & Conditions',
                      'Read our terms',
                      () => _showComingSoon(context),
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // Logout Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF64B5F6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF64B5F6), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: userName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: userBio,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('About Nimbus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 64,
              color: const Color(0xFF64B5F6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nimbus',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
            Text(
              'Your ultimate e-book reading companion',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
