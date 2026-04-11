import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_strings.dart';
import '../models.dart';

class AddScreen extends StatefulWidget {
  final String language;
  final Future<void> Function(PlazoItem) onAdd;
  const AddScreen({
    super.key,
    required this.language,
    required this.onAdd,
  });

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  ItemType _type = ItemType.task;
  final _subjectController = TextEditingController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isSubmitting = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return "$day/$month/$year";
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  void _resetForm() {
    _subjectController.clear();
    _titleController.clear();
    _locationController.clear();
    _descController.clear();
    setState(() {
      _type = ItemType.task;
      _selectedDate = null;
      _selectedTime = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _t(String key) => AppStrings.get(key, widget.language);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.accentBlue.withValues(alpha: 0.08),
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
                Text(
                  _t('addPlan'),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.getInputBackgroundColor(context),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      _toggleButton(
                        _t('tasks'),
                        _type == ItemType.task,
                        () => setState(() => _type = ItemType.task),
                      ),
                      _toggleButton(
                        _t('exams'),
                        _type == ItemType.exam,
                        () => setState(() => _type = ItemType.exam),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildField(_t('subject'), _subjectController,
                    hint: "e.g. Mathematics"),
                _buildField(_t('activity'), _titleController,
                    hint: "e.g. Midterm Prep"),
                if (_type == ItemType.exam)
                  _buildField(_t('location'), _locationController,
                      hint: "e.g. Exam Hall B"),
                _buildField(_t('briefNotes'), _descController,
                    isLong: true, hint: "Add some notes..."),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerField(
                        label: _t('dueDate'),
                        value: _selectedDate != null ? _formatDate(_selectedDate!) : "",
                        hint: _t('selectDate'),
                        icon: Icons.calendar_today,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPickerField(
                        label: _t('time'),
                        value: _selectedTime != null ? _formatTime(_selectedTime!) : "",
                        hint: _t('selectTime'),
                        icon: Icons.access_time,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
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
                    if (_selectedDate == null) {
                      _showMessage(_t('pleaseSelectDueDate'));
                      return;
                    }
                    if (_selectedTime == null) {
                      _showMessage(_t('pleaseSelectTime'));
                      return;
                    }

                    setState(() => _isSubmitting = true);

                    try {
                      await widget.onAdd(
                        PlazoItem(
                          id: DateTime.now().toIso8601String(),
                          type: _type,
                          title: title,
                          subject: subject,
                          date: _formatDate(_selectedDate!),
                          time: _formatTime(_selectedTime!),
                          description: _descController.text.trim(),
                          location: _type == ItemType.exam ? location : null,
                        ),
                      );

                      if (!mounted) return;
                      _resetForm();
                    } finally {
                      if (mounted) {
                        setState(() => _isSubmitting = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _t('addPlan'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggleButton(
          String label, bool active, VoidCallback onTap) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.getCardBackgroundColor(context)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: active
                      ? AppColors.primary
                      : AppColors.getSecondaryTextColor(context),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isLong = false,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: isLong ? 4 : 1,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.getInputBackgroundColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(18),
              hintText: hint,
              hintStyle: TextStyle(
                  color: Colors.grey[400], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onTap,
            borderRadius:
                BorderRadius.circular(20),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.getInputBackgroundColor(context),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.isNotEmpty ? value : hint,
                      style: TextStyle(
                          fontWeight: value.isNotEmpty ? FontWeight.w700 : FontWeight.w500,
                          color: value.isNotEmpty ? AppColors.getTextColor(context) : AppColors.getSecondaryTextColor(context)),
                    ),
                  ),
                  Icon(icon,
                      size: 18,
                      color: AppColors.getSecondaryTextColor(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}