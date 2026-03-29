import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

import '../app_colors.dart';
import '../app_strings.dart';
import '../item_card.dart';
import '../models.dart';

class HomeScreen extends StatefulWidget {
  final List<PlazoItem> items;
  final String language;
  final String userName;
  final String avatarUrl;
  final Uint8List? avatarBytes;
  final Function(String) onDetail;
  final VoidCallback? onNavigateToProfile;

  const HomeScreen({
    super.key,
    required this.items,
    required this.language,
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

  String _getMonthName(DateTime date) {
    return DateFormat('MMMM', widget.language).format(date);
  }

  String _getDayName(DateTime date) {
    return DateFormat('EEE', widget.language).format(date).toUpperCase();
  }

  String _t(String key) => AppStrings.get(key, widget.language);

  void _shiftDays(int dayCount) {
    setState(() {
      _currentStartDate =
          _currentStartDate.add(Duration(days: dayCount));
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
              : const Color(0xFFF2FAF7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              /// Greeting Row
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_t('hi')}, ${widget.userName}",
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

              /// Month
              Text(
                displayMonth,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 20),

              /// Responsive week navigator
              LayoutBuilder(
                builder: (context, constraints) {
                  const arrowButtonWidth = 36.0;
                  const spaceAfterLeftArrow = 12.0;
                  const spaceBeforeRightArrow = 12.0;
                  const cardGap = 12.0;
                  const preferredCardWidth = 70.0;
                  const minimumDays = 3;

                  final availableForCards = constraints.maxWidth -
                      (arrowButtonWidth * 2) -
                      spaceAfterLeftArrow -
                      spaceBeforeRightArrow;

                  final rawCount =
                      ((availableForCards + cardGap) / (preferredCardWidth + cardGap))
                          .floor();
                  final visibleDayCount = rawCount < minimumDays ? minimumDays : rawCount;

                  final totalGap = cardGap * (visibleDayCount - 1);
                  final cardWidth =
                      (availableForCards - totalGap) / visibleDayCount;

                  final dates = List.generate(
                    visibleDayCount,
                    (i) => _currentStartDate.add(Duration(days: i)),
                  );

                  return Row(
                    children: [
                      InkWell(
                        onTap: () => _shiftDays(-visibleDayCount),
                        child: _arrowButton(Icons.chevron_left),
                      ),
                      const SizedBox(width: spaceAfterLeftArrow),
                      Expanded(
                        child: Row(
                          children: dates.asMap().entries.map((entry) {
                            final index = entry.key;
                            final date = entry.value;
                            final isToday =
                                date.day == _today.day &&
                                    date.month == _today.month &&
                                    date.year == _today.year;

                            return _dateCard(
                              day: date.day.toString(),
                              label: _getDayName(date),
                              active: isToday,
                              width: cardWidth,
                              isLast: index == dates.length - 1,
                              gap: cardGap,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: spaceBeforeRightArrow),
                      InkWell(
                        onTap: () => _shiftDays(visibleDayCount),
                        child: _arrowButton(Icons.chevron_right),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),

              /// Tasks
              _sectionHeader(
                _t('tasks'),
                "${tasks.length} ${_t('pending')}",
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
                _t('exams'),
                "${exams.length} ${_t('upcoming')}",
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

  Widget _dateCard({
    required String day,
    required String label,
    required bool active,
    required double width,
    required bool isLast,
    required double gap,
  }) {
    return Container(
      width: width,
      height: 90,
      margin: EdgeInsets.only(right: isLast ? 0 : gap),
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