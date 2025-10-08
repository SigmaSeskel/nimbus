import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nimbus/services/profile_service.dart';
import 'package:nimbus/services/auth_service.dart';
import 'package:nimbus/screens/settings_screen.dart';
import 'package:nimbus/screens/wishlist_screen.dart';
import 'package:nimbus/screens/notifications_screen.dart';
import 'package:nimbus/screens/order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  
  Map<String, dynamic>? _userProfile;
  Map<String, int> _stats = {'books': 0, 'read': 0, 'wishlist': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load profile first
      final profile = await _profileService.getUserProfile();
      
      setState(() {
        _userProfile = profile;
      });
      
      // Load stats separately (don't block on errors)
      try {
        final stats = await _profileService.getProfileStats();
        setState(() {
          _stats = stats;
        });
      } catch (statsError) {
        print('⚠️ Warning: Could not load stats: $statsError');
        // Keep default stats (0, 0, 0)
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ Error loading profile: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile. Please try again.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadProfileData,
            ),
          ),
        );
      }
    }
  }

  String get userName {
    final name = _userProfile?['name'] ?? 
                 _authService.currentUser?.displayName ?? 
                 _authService.currentUser?.email?.split('@')[0] ?? 
                 'User';
    return name.isNotEmpty ? name : 'User';
  }
  
  String get userEmail => _userProfile?['email'] ?? 
                          _authService.currentUser?.email ?? 
                          'No email';
  
  String get userPhone => _userProfile?['phone'] ?? 'Not set';
  String get userBio => _userProfile?['bio'] ?? 'Book lover 📚';
  
  String get userInitial {
    try {
      final name = userName;
      if (name.isEmpty) return 'U';
      return name[0].toUpperCase();
    } catch (e) {
      print('Error getting initial: $e');
      return 'U';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF64B5F6),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(),
                  _buildStatsCards(),
                  _buildAccountSection(),
                  _buildLibrarySection(),
                  _buildSettingsSection(),
                  _buildSupportSection(),
                  _buildLogoutButton(),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
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
                    backgroundImage: (_userProfile != null && _userProfile!['photoUrl'] != null)
                        ? NetworkImage(_userProfile!['photoUrl'])
                        : null,
                    child: (_userProfile == null || _userProfile!['photoUrl'] == null)
                        ? Text(
                            userInitial,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64B5F6),
                            ),
                          )
                        : null,
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
          onPressed: _showEditProfileDialog,
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Books Owned',
                _stats['books'].toString(),
                Icons.library_books,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Books Read',
                _stats['read'].toString(),
                Icons.menu_book,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Wishlist',
                _stats['wishlist'].toString(),
                Icons.favorite,
                Colors.red,
              ),
            ),
          ],
        ),
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

  Widget _buildAccountSection() {
    return SliverToBoxAdapter(
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
                _showEditProfileDialog,
              ),
              const Divider(height: 1),
              _buildMenuItem(
                Icons.phone_outlined,
                'Phone Number',
                userPhone,
                _showPhoneDialog,
              ),
              const Divider(height: 1),
              _buildMenuItem(
                Icons.email_outlined,
                'Email Address',
                userEmail,
                _showEmailDialog,
              ),
              const Divider(height: 1),
              _buildMenuItem(
                Icons.lock_outline,
                'Change Password',
                'Update your password',
                _showChangePasswordDialog,
              ),
              const Divider(height: 1),
              _buildMenuItem(
                Icons.notifications_outlined,
                'Notifications',
                'Manage your notifications',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildLibrarySection() {
    return SliverToBoxAdapter(
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
                '${_stats['books']} books in collection',
                () => _showComingSoon(context),
              ),
              const Divider(height: 1),
              _buildMenuItem(
                Icons.favorite_border,
                'Wishlist',
                '${_stats['wishlist']} books in wishlist',
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
                () => Navigator.pop(context),
              ),
              const Divider(height: 1),
              _buildMenuItem(
                Icons.history,
                'Order History',
                'View past purchases',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrderHistoryScreen(),
                    ),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return SliverToBoxAdapter(
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
                Icons.dark_mode_outlined,
                'Dark Mode',
                'Switch to dark theme',
                () => _toggleDarkMode(),
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
    );
  }

  Widget _buildSupportSection() {
    return SliverToBoxAdapter(
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
    );
  }

  Widget _buildLogoutButton() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: OutlinedButton.icon(
          onPressed: _showLogoutDialog,
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
    final nameController = TextEditingController(text: userName);
    final bioController = TextEditingController(text: userBio);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  prefixIcon: const Icon(Icons.person, color: Color(0xFF64B5F6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  hintText: 'Tell us about yourself',
                  prefixIcon: const Icon(Icons.edit, color: Color(0xFF64B5F6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _profileService.updateProfile(
                  name: nameController.text,
                  bio: bioController.text,
                );
                
                if (!mounted) return;
                Navigator.pop(context);
                _loadProfileData();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPhoneDialog() {
    final phoneController = TextEditingController(text: userPhone == 'Not set' ? '' : userPhone);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Phone Number'),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '+66 123 456 789',
            prefixIcon: const Icon(Icons.phone, color: Color(0xFF64B5F6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _profileService.updateProfile(
                  phone: phoneController.text,
                );
                
                if (!mounted) return;
                Navigator.pop(context);
                _loadProfileData();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Phone number updated!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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

  void _showEmailDialog() {
    final emailController = TextEditingController(text: userEmail);
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Email Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'New Email',
                hintText: 'your@email.com',
                prefixIcon: const Icon(Icons.email, color: Color(0xFF64B5F6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                hintText: 'Enter your password to confirm',
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF64B5F6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _profileService.updateEmail(
                  newEmail: emailController.text,
                  password: passwordController.text,
                );
                
                if (!mounted) return;
                Navigator.pop(context);
                _loadProfileData();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email updated! Please verify your new email.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64B5F6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF64B5F6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF64B5F6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              try {
                await _profileService.changePassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                );
                
                if (!mounted) return;
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleDarkMode() async {
    final isDark = await _profileService.isDarkMode();
    await _profileService.toggleDarkMode(!isDark);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dark mode ${!isDark ? 'enabled' : 'disabled'}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
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
            onPressed: () async {
              try {
                await _authService.signOut();
                
                if (!mounted) return;
                
                // Navigate to login screen
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
          children: const [
            Icon(
              Icons.menu_book_rounded,
              size: 64,
              color: Color(0xFF64B5F6),
            ),
            SizedBox(height: 16),
            Text(
              'Nimbus',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Your ultimate e-book reading companion',
              textAlign: TextAlign.center,
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