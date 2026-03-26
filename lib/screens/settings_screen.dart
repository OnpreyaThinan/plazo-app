import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

import '../app_colors.dart';
import '../app_strings.dart';
import '../models.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfile user;
  final String language;
  final bool darkMode;
  final Function(String) onLanguageChange;
  final Function(bool) onDarkModeChange;
  final VoidCallback onLogout;
  final Function(UserProfile) onUserChanged;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.language,
    required this.darkMode,
    required this.onLanguageChange,
    required this.onDarkModeChange,
    required this.onLogout,
    required this.onUserChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProfile _user;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  final _authService = AuthService();

  String _t(String key) => AppStrings.get(key, widget.language);

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _nameController = TextEditingController(text: _user.name);
    _emailController = TextEditingController(text: _user.email);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImagePath = image.path;
        _selectedImageBytes = bytes;
        _user = UserProfile(
          name: _user.name,
          email: _user.email,
          avatarUrl: image.path,
          avatarBytes: bytes,
        );
      });
      widget.onUserChanged(_user);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Change Password",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "We'll send a password reset link to your email address.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _user.email,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _authService.sendPasswordResetEmail(
                  email: _user.email,
                );
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Password reset link has been sent to ${_user.email}",
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );

                // Auto-logout after showing message
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) {
                  widget.onLogout();
                }
              } on FirebaseAuthException catch (e) {
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message ?? "Failed to send reset email"),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Send Link",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleEditMode() {
    if (_isEditing) {
      setState(() {
        _user = UserProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          avatarUrl: _selectedImagePath ?? _user.avatarUrl,
          avatarBytes: _selectedImageBytes ?? _user.avatarBytes,
        );
        widget.onUserChanged(_user);
        _isEditing = false;
      });
    } else {
      setState(() => _isEditing = true);
    }
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.avatarOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(child: _buildAvatarImage()),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (_selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }

    if (_user.avatarBytes != null) {
      return Image.memory(
        _user.avatarBytes!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }

    if (_user.avatarUrl.startsWith('http')) {
      return Image.network(
        _user.avatarUrl,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        errorBuilder: (context, error, stackTrace) => _defaultAvatarIcon(60),
      );
    }

    return _defaultAvatarIcon(60);
  }

  Widget _defaultAvatarIcon(double size) {
    return Center(
      child: Text(
        "🧑",
        style: TextStyle(fontSize: size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _t('profile'),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.getTextColor(context),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8),
            child: InkWell(
              onTap: _toggleEditMode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _isEditing ? _t('save') : _t('edit'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 16),
                    Text(
                      _user.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                    Text(
                      _user.email,
                      style: TextStyle(
                        color: AppColors.getSecondaryTextColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildSectionTitle(_t('accountSecurity')),
              _buildInfoField(_t('name'), _nameController, isEditable: true),
              _buildInfoField(_t('email'), _emailController, isEditable: true),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _showChangePasswordDialog,
                  child: Text(
                    "Change Password?",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(_t('preferences')),
              _buildLanguageSelector(),
              _buildDarkModeToggle(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: widget.onLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getCardBackgroundColor(context),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _t('signOut'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isAccountSecurity = title.contains('ACCOUNT');
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          if (isAccountSecurity)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.person,
                size: 16,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller, {
    bool isEditable = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            if (_isEditing && isEditable)
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.getInputBackgroundColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintStyle: TextStyle(
                    color: AppColors.getSecondaryTextColor(context),
                    fontSize: 13,
                  ),
                ),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextColor(context),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.getInputBackgroundColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  controller.text,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.getTextColor(context),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _buildLanguageSelector() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('language'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: AppColors.getCardBackgroundColor(context),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _t('selectLanguage'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "English",
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            widget.onLanguageChange('en');
                            Navigator.pop(context);
                          },
                          trailing: widget.language == 'en' ? const Icon(Icons.check, color: Colors.purple) : null,
                        ),
                        ListTile(
                          title: Text(
                            "ไทย",
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            widget.onLanguageChange('th');
                            Navigator.pop(context);
                          },
                          trailing: widget.language == 'th' ? const Icon(Icons.check, color: Colors.purple) : null,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.getInputBackgroundColor(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.language, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.language == 'en' ? _t('english') : _t('thai'),
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.getTextColor(context)),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: AppColors.getSecondaryTextColor(context)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildDarkModeToggle() => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t('darkTheme'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.getSecondaryTextColor(context))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.getInputBackgroundColor(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.darkMode ? Icons.nights_stay : Icons.wb_sunny,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_t('darkMode'), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.getTextColor(context)))),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: widget.darkMode,
                      onChanged: (value) => widget.onDarkModeChange(value),
                      activeColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
