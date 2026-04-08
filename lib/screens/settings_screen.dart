import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../app_colors.dart';
import '../app_strings.dart';
import '../models.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import '../services/storage_service.dart';
import '../widgets/privacy_policy_dialog.dart';

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
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  bool _isEditing = false;
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  final _authService = AuthService();
  final _securityService = SecurityService();
  
  DateTime? _lastLogin;

  bool get _isDarkTheme => Theme.of(context).brightness == Brightness.dark;
  Color get _successColor => _isDarkTheme ? Colors.greenAccent.shade200 : Colors.green.shade700;

  String _t(String key) => AppStrings.get(key, widget.language);

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Please check your internet connection';
      case 'wrong-password':
      case 'invalid-credential':
        return _t('currentPasswordIncorrect');
      case 'user-not-found':
        return 'Account not found';
      case 'timeout':
        return 'Something went wrong. Please try again.';
      case 'weak-password':
        return _t('weakPassword');
      case 'requires-recent-login':
        return _t('passwordChangeRequiresRecentLogin');
      case 'no-password-provider':
        return _t('passwordAccountOnly');
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _nameController = TextEditingController(text: _user.name);
    _emailController = TextEditingController(text: _user.email);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _loadSecurityInfo();
  }

  Future<void> _loadSecurityInfo() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      DateTime? resolvedLastLogin;

      if (uid != null && uid.isNotEmpty) {
        resolvedLastLogin = await _securityService.loadLastLogin(uid: uid);
      }

      if (resolvedLastLogin == null) {
        final lastLoginStr = await StorageService.getString('lastLogin');
        if (lastLoginStr != null) {
          resolvedLastLogin = DateTime.tryParse(lastLoginStr);
        }
      }

      if (!mounted) return;
      setState(() {
        _lastLogin = resolvedLastLogin;
      });
    } catch (e) {
      debugPrint('Error loading security info: $e');
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final bytes = await image.readAsBytes();
      if (!mounted) return;

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
    } catch (e) {
      debugPrint('Failed to pick avatar image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load selected image. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getCardBackgroundColor(dialogContext),
        title: Text(_t('confirmSignOutTitle')),
        content: Text(_t('confirmSignOutMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(_t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text(
              _t('confirmSignOutAction'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: AppColors.getCardBackgroundColor(dialogContext),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              _t('changePassword'),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.getTextColor(dialogContext),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('changePasswordHint'),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.getTextColor(dialogContext),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _t('currentPassword'),
                    hintText: _t('enterCurrentPassword'),
                    filled: true,
                    fillColor: AppColors.getInputBackgroundColor(dialogContext),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _t('newPassword'),
                    hintText: _t('enterNewPassword'),
                    filled: true,
                    fillColor: AppColors.getInputBackgroundColor(dialogContext),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: _t('confirmNewPassword'),
                    hintText: _t('confirmYourNewPassword'),
                    filled: true,
                    fillColor: AppColors.getInputBackgroundColor(dialogContext),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSending ? null : () => Navigator.pop(dialogContext),
                child: Text(
                  _t('cancel'),
                  style: TextStyle(
                    color: AppColors.getSecondaryTextColor(dialogContext),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isSending
                    ? null
                    : () async {
                        final currentPassword = _currentPasswordController.text.trim();
                        final newPassword = _newPasswordController.text.trim();
                        final confirmPassword = _confirmPasswordController.text.trim();

                        String? validationError;
                        if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                          validationError = _t('pleaseEnterPassword');
                        } else if (newPassword.length < 8) {
                          validationError = _t('passwordMinLength');
                        } else if (newPassword != confirmPassword) {
                          validationError = _t('passwordsDoNotMatch');
                        } else if (currentPassword == newPassword) {
                          validationError = _t('cannotUseSamePassword');
                        }

                        if (validationError != null) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(validationError),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isSending = true);
                        try {
                          await _authService.changePassword(
                            currentPassword: currentPassword,
                            newPassword: newPassword,
                          );
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          if (!dialogContext.mounted) return;

                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _t('passwordChangedSuccess'),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          if (!dialogContext.mounted) return;
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(_authErrorMessage(e)),
                              backgroundColor: Colors.redAccent,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        } finally {
                          if (dialogContext.mounted) {
                            setDialogState(() => isSending = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _t('changePasswordAction'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getCardBackgroundColor(dialogContext),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          _t('deleteAccountConfirmTitle'),
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('deleteAccountConfirmMessage'),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextColor(dialogContext),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(dialogContext).brightness == Brightness.dark
                    ? Colors.red.withValues(alpha: 0.25)
                    : Colors.redAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(dialogContext).brightness == Brightness.dark
                        ? Colors.red.shade300
                        : Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _t('deleteAccountWarning'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(dialogContext).brightness == Brightness.dark
                            ? Colors.red.shade300
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              _t('cancel'),
              style: TextStyle(
                color: AppColors.getSecondaryTextColor(dialogContext),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              _performDeleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              _t('deleteAccount'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteAccount() async {
    try {
      await _authService.deleteAccount();
      if (mounted) {
        widget.onLogout();
      }
    } catch (e) {
      debugPrint('Delete account failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete account. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showPrivacyPolicy() {
    showAppPrivacyPolicyDialog(
      context: context,
      language: widget.language,
    );
  }

  Widget _buildLastLoginInfo() {
    final lastLoginText = _lastLogin != null
        ? DateFormat('MMM d, yyyy h:mm a').format(_lastLogin!)
        : _t('lastLoginNever');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.getInputBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _t('lastLogin'),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lastLoginText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextColor(context),
                ),
              ),
            ],
          ),
          Icon(Icons.check_circle, color: AppColors.primary, size: 24),
        ],
      ),
    );
  }

  Widget _buildSecurityAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('securityAlerts'),
          style: _subsectionLabelStyle(),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.getInputBackgroundColor(context),
            border: Border.all(
              color: AppColors.getSecondaryTextColor(context).withValues(alpha: 0.35),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: _successColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _t('noActiveAlerts'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _successColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No suspicious activity detected',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ],
          ),
        ),
      ],
    );
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
                  color: Colors.black.withValues(alpha: 0.1),
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
                    color: Colors.black.withValues(alpha: 0.15),
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
          _t('settings'),
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
              _buildSectionTitle(_t('accountSecurity'), icon: Icons.person),
              _buildInfoField(_t('name'), _nameController, isEditable: true),
              _buildInfoField(_t('email'), _emailController, isEditable: true),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _showChangePasswordDialog,
                  child: Text(
                    _t('changePassword'),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(_t('preferences'), icon: Icons.tune_rounded),
              _buildLanguageSelector(),
              _buildDarkModeToggle(),
              const SizedBox(height: 40),
              _buildSectionTitle(_t('security'), icon: Icons.shield_outlined),
              _buildSubsectionTitle(_t('securityAlerts')),
              _buildLastLoginInfo(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showPrivacyPolicy,
                      icon: const Icon(Icons.privacy_tip_outlined, size: 16),
                      label: Text(_t('viewPrivacyPolicy')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.getTextColor(context),
                        backgroundColor: AppColors.getInputBackgroundColor(context),
                        side: BorderSide(
                          color: AppColors.getSecondaryTextColor(context),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showDeleteAccountDialog,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: Text(_t('deleteAccountButton')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDarkTheme
                            ? Colors.redAccent.withValues(alpha: 0.22)
                            : Colors.redAccent.withValues(alpha: 0.12),
                        foregroundColor: Colors.redAccent,
                        elevation: 0,
                        side: const BorderSide(color: Colors.redAccent, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showLogoutConfirmDialog,
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

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                icon,
                size: 18,
                color: AppColors.getSecondaryTextColor(context),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.getSecondaryTextColor(context),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _subsectionLabelStyle() {
    return TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: AppColors.getSecondaryTextColor(context),
      letterSpacing: 0.3,
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: _subsectionLabelStyle(),
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
              style: _subsectionLabelStyle(),
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
                  fontSize: 14,
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
                    fontSize: 14,
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
              style: _subsectionLabelStyle(),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.getTextColor(context),
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            _t('english'),
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
                            _t('thai'),
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
            Text(
              _t('darkTheme'),
              style: _subsectionLabelStyle(),
            ),
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
                  Expanded(
                    child: Text(
                      _t('darkMode'),
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.getTextColor(context)),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: widget.darkMode,
                      onChanged: (value) => widget.onDarkModeChange(value),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
