import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_strings.dart';
import '../models.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfile user;
  final String language;
  final bool darkMode;
  final Function(String) onLanguageChange;
  final Function(bool) onDarkModeChange;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.language,
    required this.darkMode,
    required this.onLanguageChange,
    required this.onDarkModeChange,
    required this.onLogout,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserProfile _user;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isEditing = false;

  String _t(String key) => AppStrings.get(key, widget.language);

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _nameController = TextEditingController(text: _user.name);
    _emailController = TextEditingController(text: _user.email);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    if (_isEditing) {
      setState(() {
        _user = UserProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          avatarUrl: _user.avatarUrl,
        );
        _isEditing = false;
      });
    } else {
      setState(() => _isEditing = true);
    }
  }

  Widget _buildAvatar() {
    return Container(
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
      child: const Center(
        child: Text(
          "🧑",
          style: TextStyle(fontSize: 60),
        ),
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
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black),
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
                    Text(_user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    Text(_user.email.split('@')[0], style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildSectionTitle(_t('accountSecurity')),
              _buildInfoField(_t('name'), _nameController, isEditable: true),
              _buildInfoField(_t('email'), _emailController, isEditable: true),
              _buildInfoField(_t('password'), _passwordController, isEditable: _isEditing, isPassword: true),
              const SizedBox(height: 32),
              _buildSectionTitle(_t('preferences')),
              _buildLanguageSelector(),
              _buildDarkModeToggle(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: widget.onLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
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
              child: Icon(Icons.person, size: 16, color: Colors.grey),
            ),
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller, {
    bool isEditable = false,
    bool isPassword = false,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
            const SizedBox(height: 8),
            if (_isEditing && isEditable)
              TextField(
                controller: controller,
                obscureText: isPassword,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.bgInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  hintText: isPassword ? "••••••••" : null,
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isPassword ? "•••" : controller.text,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
            Text(_t('language'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(_t('selectLanguage'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        ),
                        ListTile(
                          title: const Text("English"),
                          onTap: () {
                            widget.onLanguageChange('en');
                            Navigator.pop(context);
                          },
                          trailing: widget.language == 'en' ? const Icon(Icons.check, color: Colors.purple) : null,
                        ),
                        ListTile(
                          title: const Text("ไทย"),
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
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.language, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.language == 'en' ? _t('english') : _t('thai'),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
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
            Text(_t('darkTheme'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.darkMode ? Icons.nights_stay : Icons.wb_sunny,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_t('darkMode'), style: const TextStyle(fontWeight: FontWeight.w600))),
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
