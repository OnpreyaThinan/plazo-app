import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

import '../app_colors.dart';
import '../item_card.dart';
import '../models.dart';

class HomeScreen extends StatefulWidget {
  final List<PlazoItem> items;
  final String userName;
  final String avatarUrl;
  final Uint8List? avatarBytes;
  final Function(String) onDetail;
  final VoidCallback? onNavigateToProfile;

  const HomeScreen({
    super.key,
    required this.items,
    required this.userName,
    required this.avatarUrl,
    this.avatarBytes,
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
      _currentStartDate =
          _currentStartDate.subtract(const Duration(days: 5));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentStartDate =
          _currentStartDate.add(const Duration(days: 5));
    });
  }

  @override
  Widget build(BuildContext context) {
    final pending =
        widget.items.where((i) => !i.isCompleted).toList();
    final tasks =
        pending.where((i) => i.type == ItemType.task).toList();
    final exams =
        pending.where((i) => i.type == ItemType.exam).toList();

    final displayMonth = _getMonthName(_currentStartDate);
    final weekNum = _getWeekOfMonth(_currentStartDate);
    final dates = List.generate(
      5,
      (i) => _currentStartDate.add(Duration(days: i)),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.accentBlue.withOpacity(0.08),
            Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[900]! 
              : Colors.white,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Greeting Row
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Hi, ${widget.userName}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: widget.onNavigateToProfile,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(child: _buildAvatarImage()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// Month + Week
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    displayMonth,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      "WEEK $weekNum",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Week Navigator
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: _prevWeek,
                    child: _arrowButton(
                        Icons.chevron_left),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,
                      child: Row(
                        children:
                            dates.map((date) {
                          final isToday =
                              date.day ==
                                      _today.day &&
                                  date.month ==
                                      _today.month &&
                                  date.year ==
                                      _today.year;

                          return _dateCard(
                            date.day.toString(),
                            _getDayName(date),
                            isToday,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _nextWeek,
                    child: _arrowButton(
                        Icons.chevron_right),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// Tasks
              _sectionHeader(
                "Tasks",
                "${tasks.length} PENDING",
                AppColors.accentBlue,
              ),
              ...tasks.map(
                (item) => ItemCard(
                  item: item,
                  onTap: () =>
                      widget.onDetail(item.id),
                ),
              ),

              const SizedBox(height: 30),

              /// Exams
              _sectionHeader(
                "Exams",
                "${exams.length} UPCOMING",
                AppColors.accentPink,
              ),
              ...exams.map(
                (item) => ItemCard(
                  item: item,
                  onTap: () =>
                      widget.onDetail(item.id),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (widget.avatarBytes != null) {
      return Image.memory(
        widget.avatarBytes!,
        fit: BoxFit.cover,
        width: 44,
        height: 44,
      );
    }

    if (widget.avatarUrl.startsWith('http')) {
      return Image.network(
        widget.avatarUrl,
        fit: BoxFit.cover,
        width: 44,
        height: 44,
        errorBuilder: (context, error, stackTrace) => _defaultAvatarIcon(24),
      );
    }

    return _defaultAvatarIcon(24);
  }

  Widget _defaultAvatarIcon(double size) {
    return Center(
      child: Text(
        "🧑",
        style: TextStyle(fontSize: size),
      ),
    );
  }

  Widget _arrowButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color:
            AppColors.primary.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
        size: 20,
      ),
    );
  }

  Widget _dateCard(
      String day, String label, bool active) {
    return Container(
      width: 70,
      height: 90,
      margin:
          const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary
            : AppColors.getCardBackgroundColor(context),
        borderRadius:
            BorderRadius.circular(24),
        border: active
            ? null
            : Border.all(
                color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
              color: active
                  ? Colors.white
                  : AppColors.getTextColor(context),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w900,
              color: active
                  ? Colors.white
                      .withOpacity(0.7)
                  : AppColors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
      String title,
      String count,
      Color color) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          Text(
            count,
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}