import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'models.dart';
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
  final VoidCallback onLogout;

  const MainNavigation({
    super.key,
    required this.user,
    required this.language,
    required this.onLanguageChange,
    required this.darkMode,
    required this.onDarkModeChange,
    required this.onLogout,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late UserProfile _user;
  final List<PlazoItem> _items = [
    PlazoItem(
      id: '1',
      type: ItemType.task,
      title: 'Calculus Exercises',
      subject: 'Mathematics',
      date: '10/04/2025',
      time: '09:00',
    ),
    PlazoItem(
      id: '2',
      type: ItemType.task,
      title: 'Physics Report',
      subject: 'Physics Lab',
      date: '12/04/2025',
      time: '14:00',
    ),
    PlazoItem(
      id: '4',
      type: ItemType.exam,
      title: 'Midterm Quiz',
      subject: 'Economics',
      date: '11/04/2025',
      time: '08:00',
      location: 'Hall A, Room 202',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  void _onDetail(String id) {
    final item = _items.firstWhere((it) => it.id == id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          item: item,
          onUpdate: (updated) => setState(() {
            final idx = _items.indexWhere((it) => it.id == updated.id);
            _items[idx] = updated;
          }),
          onDelete: (id) => setState(() => _items.removeWhere((it) => it.id == id)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        items: _items,
        userName: _user.name,
        avatarUrl: _user.avatarUrl,
        avatarBytes: _user.avatarBytes,
        onDetail: _onDetail,
        onNavigateToProfile: () => setState(() => _currentIndex = 3),
      ),
      CompletedScreen(items: _items, onDetail: _onDetail),
      AddScreen(
        onAdd: (newItem) => setState(() {
          _items.insert(0, newItem);
          _currentIndex = 0;
        }),
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
            color: Colors.black.withOpacity(0.05),
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
        onTap: () => setState(() => _currentIndex = index),
        child: Icon(
          icon,
          color: _currentIndex == index ? AppColors.primary : Colors.grey[300],
          size: 28,
        ),
      );

  Widget _addIcon() => GestureDetector(
        onTap: () => setState(() => _currentIndex = 2),
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      );
}
