import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_strings.dart';
import '../models.dart';

class EditScreen extends StatefulWidget {
  final PlazoItem item;
  final String language;
  final Function(PlazoItem) onSave;
  final Function(String) onDelete;

  const EditScreen({
    super.key,
    required this.item,
    required this.language,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late ItemType _type;
  late TextEditingController _subjectController;
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _type = widget.item.type;
    _subjectController = TextEditingController(text: widget.item.subject);
    _titleController = TextEditingController(text: widget.item.title);
    _locationController =
        TextEditingController(text: widget.item.location ?? '');
    _descController =
        TextEditingController(text: widget.item.description);
    _selectedDate =
        _parseDate(widget.item.date) ?? DateTime.now();
    _selectedTime =
        _parseTime(widget.item.time) ??
            const TimeOfDay(hour: 9, minute: 0);
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }
    return DateTime(year, month, day);
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate:
          DateTime.now().subtract(const Duration(days: 1)),
      lastDate:
          DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String _t(String key) => AppStrings.get(key, widget.language);

  void _save() {
    final subject = _subjectController.text.trim();
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    if (subject.isEmpty) {
      _showMessage(_t('pleaseEnterSubject'));
      return;
    }
    if (title.isEmpty) {
      _showMessage(_t('pleaseEnterActivity'));
      return;
    }
    if (_type == ItemType.exam && location.isEmpty) {
      _showMessage(_t('pleaseEnterExamLocation'));
      return;
    }

    final updated = PlazoItem(
      id: widget.item.id,
      type: _type,
      title: title,
      subject: subject,
      date: _formatDate(_selectedDate),
      time: _formatTime(_selectedTime),
      description: _descController.text.trim(),
      location:
          _type == ItemType.exam ? location : null,
      isCompleted: widget.item.isCompleted,
    );

    widget.onSave(updated);
    Navigator.pop(context, updated);
  }

  void _delete() {
    widget.onDelete(widget.item.id);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseBackground = isDark ? AppColors.darkBg : AppColors.bgDetailLight;
    final cardBackground = isDark ? Colors.grey[900]! : Colors.white;
    final typeLabel = _type == ItemType.exam ? _t('examsUpper') : _t('tasksUpper');
    final typeColor = _type == ItemType.exam ? AppColors.accentPink : AppColors.accentBlue;

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
            onTap: _delete,
          ),
          const SizedBox(width: 8),
          _circleIconButton(
            icon: Icons.check,
            iconColor: AppColors.primary,
            onTap: _save,
            filled: true,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
              AppColors.accentBlue.withValues(alpha: isDark ? 0.12 : 0.08),
              baseBackground,
            ],
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
                          color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
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
                            color: typeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildField(_t('subject'), _subjectController, outlined: true),
                        _buildField(_t('activity'), _titleController, filled: true),
                        Row(
                          children: [
                            Expanded(
                              child: _buildPickerField(
                                value: _formatDate(_selectedDate),
                                icon: Icons.calendar_today,
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildPickerField(
                                value: _formatTime(_selectedTime),
                                icon: Icons.access_time,
                                onTap: _pickTime,
                              ),
                            ),
                          ],
                        ),
                        if (_type == ItemType.exam)
                          _buildField(_t('location'), _locationController, filled: true),
                        _buildField(_t('briefNotes'), _descController, isLong: true, filled: true),
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

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isLong = false,
    bool filled = false,
    bool outlined = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textMain;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey;
    final borderColor = outlined
        ? (isDark ? Colors.grey[600]! : Colors.black87)
        : Colors.transparent;

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: isLong ? 4 : 1,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: secondaryTextColor),
          hintStyle: TextStyle(color: secondaryTextColor),
          filled: true,
          fillColor: filled
              ? (isDark ? Colors.grey[850]! : AppColors.bgInput)
              : (isDark ? Colors.grey[900]! : Colors.white),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(22),
            borderSide: BorderSide(
              color: borderColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerField({
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textMain;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey;

    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(20),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850]! : AppColors.bgInput,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textColor),
                ),
              ),
              Icon(icon,
                  size: 18,
                  color: secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
    bool filled = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding:
          const EdgeInsets.only(left: 12),
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: filled
                ? AppColors.primary
                : (isDark ? const Color(0xFF1F2427) : Colors.white),
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
            color: filled
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark ? Colors.white : iconColor),
            size: 20,
          ),
        ),
      ),
    );
  }
}