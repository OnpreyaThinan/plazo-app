import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_strings.dart';
import '../models.dart';
import 'edit_screen.dart';

class DetailScreen extends StatefulWidget {
  final PlazoItem item;
  final String language;
  final bool darkMode;
  final Function(PlazoItem) onUpdate;
  final Function(String) onDelete;

  const DetailScreen({
    super.key,
    required this.item,
    required this.language,
    required this.darkMode,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PlazoItem _item;
  String _t(String key) => AppStrings.get(key, widget.language);

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _openEdit() async {
    final updated = await Navigator.push<PlazoItem>(
      context,
      MaterialPageRoute(
        builder: (context) => EditScreen(
          item: _item,
          language: widget.language,
          onSave: widget.onUpdate,
          onDelete: widget.onDelete,
        ),
      ),
    );

    if (updated != null) {
      setState(() => _item = updated);
      widget.onUpdate(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.darkMode;
    final baseBackground = isDark ? AppColors.darkBg : AppColors.bgDetailLight;
    final cardBackground = isDark ? Colors.grey[900]! : Colors.white;
    final inputBackground = isDark ? Colors.grey[850]! : AppColors.bgInput;
    final textColor = isDark ? Colors.white : AppColors.textMain;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Scaffold(
      backgroundColor: baseBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _circleIconButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.pop(context),
        ),
        actions: [
          _circleIconButton(
            icon: Icons.delete_outline,
            iconColor: Colors.redAccent,
            onTap: () {
              widget.onDelete(_item.id);
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
          _circleIconButton(
            icon: Icons.edit_outlined,
            iconColor: AppColors.primary,
            onTap: _openEdit,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.10),
              AppColors.accentBlue.withValues(alpha: isDark ? 0.12 : 0.10),
              baseBackground,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (_item.type == ItemType.exam ? AppColors.accentPink : AppColors.accentBlue)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _item.type == ItemType.exam ? _t('exam') : _t('task'),
                            style: TextStyle(
                              color: _item.type == ItemType.exam ? AppColors.accentPink : AppColors.accentBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _item.subject,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                          ),
                        ),
                        Text(
                          _item.title,
                          style: TextStyle(
                            fontSize: 16,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _infoRow(Icons.calendar_today, _item.date),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _infoRow(Icons.access_time, _item.time),
                            ),
                          ],
                        ),
                        if (_item.location != null) ...[
                          const SizedBox(height: 10),
                          _infoRow(Icons.location_on, _item.location!),
                        ],
                        const SizedBox(height: 24),
                        Text(
                          _t('briefNotes').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: inputBackground,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            _item.description.isEmpty ? _t('noAdditionalNotes') : _item.description,
                            style: TextStyle(
                              height: 1.5,
                              color: textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            _item.isCompleted = !_item.isCompleted;
                            widget.onUpdate(_item);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _item.isCompleted
                                ? inputBackground
                                : AppColors.primary,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _item.isCompleted ? _t('moveToPending') : _t('done'),
                            style: TextStyle(
                              color: _item.isCompleted ? secondaryTextColor : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    final secondaryTextColor =
        widget.darkMode ? Colors.grey[400]! : Colors.grey;

    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final cardBackground =
        widget.darkMode ? Colors.grey[900]! : Colors.white;
    final textColor =
        widget.darkMode ? Colors.white : AppColors.textMain;

    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cardBackground,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor ?? textColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}