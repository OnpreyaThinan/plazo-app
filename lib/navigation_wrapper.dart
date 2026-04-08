import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'models.dart';
import 'services/storage_service.dart';
import 'screens/add_screen.dart';
import 'screens/completed_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  final UserProfile user;
  final String language;
  final Function(String) onLanguageChange;
  final bool darkMode;
  final Function(bool) onDarkModeChange;
  final int initialIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onLogout;

  const MainNavigation({
    super.key,
    required this.user,
    required this.language,
    required this.onLanguageChange,
    required this.darkMode,
    required this.onDarkModeChange,
    required this.initialIndex,
    required this.onIndexChanged,
    required this.onLogout,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late UserProfile _user;
  late List<PlazoItem> _items;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _user = widget.user;
    _loadItems();
  }

  Future<void> _loadItems() async {
    final loaded = await StorageService.loadItems();
    if (!mounted) return;
    setState(() {
      _items = loaded;
      _isLoading = false;
    });
  }

  Future<void> _saveItems() async {
    await StorageService.saveItems(_items);
  }

  @override
  void didUpdateWidget(covariant MainNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _user = widget.user;
    if (widget.initialIndex != _currentIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  void _setCurrentIndex(int index) {
    if (_currentIndex == index) {
      return;
    }
    setState(() => _currentIndex = index);
    widget.onIndexChanged(index);
  }

  void _onDetail(String id) {
    final item = _items.firstWhere(
      (it) => it.id == id,
      orElse: () => PlazoItem(
        id: '',
        type: ItemType.task,
        title: '',
        subject: '',
        date: '',
        time: '',
      ),
    );
    if (item.id.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item not found.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          item: item,
          language: widget.language,
          onUpdate: (updated) => setState(() {
            final idx = _items.indexWhere((it) => it.id == updated.id);
            if (idx == -1) {
              return;
            }
            _items[idx] = updated;
            _saveItems();
          }),
          onDelete: (id) => setState(() {
            _items.removeWhere((it) => it.id == id);
            _saveItems();
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    final List<Widget> screens = [
      HomeScreen(
        items: _items,
        language: widget.language,
        userName: _user.name,
        avatarUrl: _user.avatarUrl,
        avatarBytes: _user.avatarBytes,
        onDetail: _onDetail,
        onNavigateToProfile: () => _setCurrentIndex(3),
      ),
      CompletedScreen(
        items: _items,
        language: widget.language,
        onDetail: _onDetail,
      ),
      AddScreen(
        language: widget.language,
        onAdd: (newItem) {
          setState(() {
            _items.insert(0, newItem);
            _currentIndex = 0;
          });
          widget.onIndexChanged(0);
          _saveItems();
        },
      ),
      SettingsScreen(
        user: _user,
        language: widget.language,
        darkMode: widget.darkMode,
        onLanguageChange: widget.onLanguageChange,
        onDarkModeChange: widget.onDarkModeChange,
        onLogout: widget.onLogout,
        onUserChanged: (updatedUser) {
          setState(() => _user = updatedUser);
        },
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navIcon(Icons.home_filled, 0),
          _navIcon(Icons.check_circle_rounded, 1),
          _addIcon(),
          _navIcon(Icons.settings_rounded, 3),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, int index) => GestureDetector(
        onTap: () => _setCurrentIndex(index),
        child: Icon(
          icon,
          color: _currentIndex == index ? AppColors.primary : Colors.grey[300],
          size: 28,
        ),
      );

  Widget _addIcon() => GestureDetector(
        onTap: () => _setCurrentIndex(2),
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      );
}
