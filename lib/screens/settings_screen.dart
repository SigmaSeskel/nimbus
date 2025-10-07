import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings States
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _darkModeEnabled = false;
  bool _autoDownload = false;
  bool _wifiOnly = true;
  String _selectedLanguage = 'English';
  String _downloadQuality = 'High';
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FA),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications Section
          _buildSectionTitle('Notifications'),
          _buildSettingsCard([
            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Enable Notifications',
              subtitle: 'Receive notifications from the app',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                  if (!value) {
                    _emailNotifications = false;
                    _pushNotifications = false;
                  }
                });
                _showSnackBar('Notifications ${value ? 'enabled' : 'disabled'}');
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.email_outlined,
              title: 'Email Notifications',
              subtitle: 'Get updates via email',
              value: _emailNotifications,
              enabled: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
                _showSnackBar('Email notifications ${value ? 'enabled' : 'disabled'}');
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.phone_android,
              title: 'Push Notifications',
              subtitle: 'Get push notifications',
              value: _pushNotifications,
              enabled: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _pushNotifications = value);
                _showSnackBar('Push notifications ${value ? 'enabled' : 'disabled'}');
              },
            ),
          ],),

          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionTitle('Appearance'),
          _buildSettingsCard([
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Switch to dark theme',
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() => _darkModeEnabled = value);
                _showSnackBar('Dark mode ${value ? 'enabled' : 'disabled'}');
              },
            ),
            const Divider(height: 1),
            _buildTappableTile(
              icon: Icons.text_fields,
              title: 'Font Size',
              subtitle: 'Adjust reading font size',
              trailing: Text(
                '${_fontSize.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64B5F6),
                ),
              ),
              onTap: () => _showFontSizeDialog(),
            ),
            const Divider(height: 1),
            _buildTappableTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'Change app language',
              trailing: Text(
                _selectedLanguage,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64B5F6),
                ),
              ),
              onTap: () => _showLanguageDialog(),
            ),
          ]),

          const SizedBox(height: 24),

          // Download Settings Section
          _buildSectionTitle('Download Settings'),
          _buildSettingsCard([
            _buildSwitchTile(
              icon: Icons.download_outlined,
              title: 'Auto Download',
              subtitle: 'Automatically download purchased books',
              value: _autoDownload,
              onChanged: (value) {
                setState(() => _autoDownload = value);
                _showSnackBar('Auto download ${value ? 'enabled' : 'disabled'}');
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.wifi,
              title: 'Download on Wi-Fi Only',
              subtitle: 'Save mobile data',
              value: _wifiOnly,
              onChanged: (value) {
                setState(() => _wifiOnly = value);
                _showSnackBar('Wi-Fi only mode ${value ? 'enabled' : 'disabled'}');
              },
            ),
            const Divider(height: 1),
            _buildTappableTile(
              icon: Icons.high_quality,
              title: 'Download Quality',
              subtitle: 'Set book download quality',
              trailing: Text(
                _downloadQuality,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64B5F6),
                ),
              ),
              onTap: () => _showQualityDialog(),
            ),
          ]),

          const SizedBox(height: 24),

          // Account Section
          _buildSectionTitle('Account'),
          _buildSettingsCard([
            _buildTappableTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              subtitle: 'Update your profile information',
              onTap: () => _showEditProfileDialog(),
            ),
            const Divider(height: 1),
            _buildTappableTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () => _showChangePasswordDialog(),
            ),
            const Divider(height: 1),
            _buildTappableTile(
              icon: Icons.security,
              title: 'Privacy & Security',
              subtitle: 'Manage your privacy settings',
              onTap: () => _showPrivacyDialog(),
            ),
          ]),

          const SizedBox(height: 24),

          // Storage Section
          _buildSectionTitle('Storage'),
          _buildSettingsCard([
            _buildTappableTile(
              icon: Icons.storage,
              title: 'Storage Usage',
              subtitle: '2.4 GB used',
              onTap: () => _showStorageDialog(),
            ),
            const Divider(height: 1),
            _buildTappableTile(
              icon: Icons.delete_outline,
              title: 'Clear Cache',
              subtitle: 'Free up space',
              onTap: () => _showClearCacheDialog(),
            ),
          ]),

          const SizedBox(height: 24),

          // About Section
          _buildSectionTitle('About'),
          _buildSettingsCard([
            _buildTappableTile(
              icon: Icons.info_outline,
              title: 'About Nimbus',
              subtitle: 'Version 1.0.0',
              onTap: () => _showAboutDialog(),
            ),
            const Divider(height: 1),
            _buildTappableTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () => _showPrivacyPolicy(),
            ),
            const Divider(height: 1),
            _buildTappableTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'Read our terms',
              onTap: () => _showTermsOfService(),
            ),
            const Divider(height: 1),
            _buildTappableTile(
              icon: Icons.star_outline,
              title: 'Rate App',
              subtitle: 'Rate us on the store',
              onTap: () {
                _showSnackBar('Opening app store...');
              },
            ),
          ]),

          const SizedBox(height: 32),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
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

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return ListTile(
      enabled: enabled,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF64B5F6).withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF64B5F6) : Colors.grey,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: enabled ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: const Color(0xFF64B5F6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildTappableTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
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
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Font Size',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Sample Text',
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Small',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF64B5F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_fontSize.toInt()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64B5F6),
                        ),
                      ),
                    ),
                    Text(
                      'Large',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF64B5F6),
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: const Color(0xFF64B5F6),
                    overlayColor: const Color(0xFF64B5F6).withOpacity(0.2),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: _fontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    onChanged: (value) {
                      setDialogState(() => _fontSize = value);
                      setState(() => _fontSize = value);
                    },
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Font size set to ${_fontSize.toInt()}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Apply',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Japanese', 'Chinese'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              activeColor: const Color(0xFF64B5F6),
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                Navigator.pop(context);
                _showSnackBar('Language changed to $value');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showQualityDialog() {
    final qualities = ['Low', 'Medium', 'High', 'Ultra'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Download Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: qualities.map((quality) {
            return RadioListTile<String>(
              title: Text(quality),
              subtitle: Text(_getQualitySub(quality)),
              value: quality,
              groupValue: _downloadQuality,
              activeColor: const Color(0xFF64B5F6),
              onChanged: (value) {
                setState(() => _downloadQuality = value!);
                Navigator.pop(context);
                _showSnackBar('Quality set to $value');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getQualitySub(String quality) {
    switch (quality) {
      case 'Low':
        return 'Smaller file size';
      case 'Medium':
        return 'Balanced';
      case 'High':
        return 'Best quality';
      case 'Ultra':
        return 'Maximum quality';
      default:
        return '';
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: 'John Doe');
    final bioController = TextEditingController(text: 'Book lover 📚');
    
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: 'Enter your name',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF64B5F6),
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF64B5F6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: 'Bio',
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                  hintText: 'Tell us about yourself',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF64B5F6),
                      width: 2,
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.edit,
                    color: Color(0xFF64B5F6),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
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
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Profile updated successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Change Password',
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
                  controller: currentPasswordController,
                  obscureText: !showCurrentPassword,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    hintText: 'Enter current password',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF64B5F6),
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64B5F6)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showCurrentPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() => showCurrentPassword = !showCurrentPassword);
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: !showNewPassword,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    hintText: 'Enter new password',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF64B5F6),
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF64B5F6)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showNewPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() => showNewPassword = !showNewPassword);
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                    hintText: 'Re-enter new password',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF64B5F6),
                        width: 2,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF64B5F6)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {
                        setState(() => showConfirmPassword = !showConfirmPassword);
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackBar('Password changed successfully!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64B5F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Change',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Privacy & Security'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPrivacyOption('Two-Factor Authentication', Icons.security),
            _buildPrivacyOption('Login History', Icons.history),
            _buildPrivacyOption('Connected Devices', Icons.devices),
            _buildPrivacyOption('Data & Privacy', Icons.privacy_tip),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF64B5F6)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        _showSnackBar('$title clicked');
      },
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Storage Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStorageItem('Books', '1.8 GB', 0.6),
            const SizedBox(height: 12),
            _buildStorageItem('Cache', '400 MB', 0.3),
            const SizedBox(height: 12),
            _buildStorageItem('Other', '200 MB', 0.1),
            const SizedBox(height: 20),
            const Text(
              'Total: 2.4 GB',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF64B5F6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageItem(String label, String size, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(size, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation(Color(0xFF64B5F6)),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Cache'),
        content: const Text(
          'This will free up 400 MB of space. Your downloaded books will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Cache cleared successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
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
              foregroundColor: Colors.white,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    _showSnackBar('Opening Privacy Policy...');
  }

  void _showTermsOfService() {
    _showSnackBar('Opening Terms of Service...');
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
              Navigator.pop(context); // Go back to previous screen
              _showSnackBar('Logged out successfully!');
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}