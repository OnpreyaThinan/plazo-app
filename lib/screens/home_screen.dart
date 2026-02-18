import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_colors.dart';
import '../item_card.dart';
import '../models.dart';

class HomeScreen extends StatefulWidget {
  final List<PlazoItem> items;
  final String userName;
  final String avatarUrl;
  final Function(String) onDetail;
  final VoidCallback? onNavigateToProfile;

  const HomeScreen({
    super.key,
    required this.items,
    required this.userName,
    required this.avatarUrl,
    required this.onDetail,
    this.onNavigateToProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _today;
  late DateTime _currentStartDate;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _currentStartDate = _today.subtract(const Duration(days: 2));
  }

  int _getWeekOfMonth(DateTime date) {
    // คำนวณ week number ของเดือน (1-6)
    // Week 1 = วันที่ 1-7, Week 2 = วันที่ 8-14 เป็นต้น
    return ((date.day - 1) ~/ 7) + 1;
  }

  String _getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  String _getDayName(DateTime date) {
    return DateFormat('EEE').format(date).toUpperCase();
  }

  void _prevWeek() {
    setState(() {
      _currentStartDate = _currentStartDate.subtract(const Duration(days: 5));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentStartDate = _currentStartDate.add(const Duration(days: 5));
    });
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.items.where((i) => !i.isCompleted).toList();
    final tasks = pending.where((i) => i.type == ItemType.task).toList();
    final exams = pending.where((i) => i.type == ItemType.exam).toList();

    final displayMonth = _getMonthName(_currentStartDate);
    final weekNum = _getWeekOfMonth(_currentStartDate);
    final dates = List.generate(5, (i) => _currentStartDate.add(Duration(days: i)));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Hi, ${widget.userName}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                InkWell(
                  onTap: widget.onNavigateToProfile,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text("🧑", style: TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(displayMonth, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "WEEK $weekNum",
                    style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _prevWeek,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chevron_left, color: AppColors.primary, size: 20),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: dates.map((date) {
                        final isToday = date.day == _today.day &&
                            date.month == _today.month &&
                            date.year == _today.year;
                        return _dateCard(date.day.toString(), _getDayName(date), isToday);
                      }).toList(),
                    ),
                  ),
                ),
                InkWell(
                  onTap: _nextWeek,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _sectionHeader("Tasks", "${tasks.length} PENDING", AppColors.accentBlue),
            ...tasks.map((item) => ItemCard(item: item, onTap: () => widget.onDetail(item.id))),
            const SizedBox(height: 30),
            _sectionHeader("Exams", "${exams.length} UPCOMING", AppColors.accentPink),
            ...exams.map((item) => ItemCard(item: item, onTap: () => widget.onDetail(item.id))),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _dateCard(String day, String label, bool active) => Container(
        width: 70,
        height: 90,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: active ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: active ? Colors.white : Colors.grey,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: active ? Colors.white.withOpacity(0.7) : Colors.grey[300],
              ),
            ),
          ],
        ),
      );

  Widget _sectionHeader(String title, String count, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            Text(count, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      );
}
