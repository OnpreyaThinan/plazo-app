import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models.dart';

class EditScreen extends StatefulWidget {
  final PlazoItem item;
  final Function(PlazoItem) onSave;
  final Function(String) onDelete;

  const EditScreen({
    super.key,
    required this.item,
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

  void _save() {
    final subject = _subjectController.text.trim();
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();

    if (subject.isEmpty) {
      _showMessage("Please enter a subject.");
      return;
    }
    if (title.isEmpty) {
      _showMessage("Please enter an activity.");
      return;
    }
    if (_type == ItemType.exam && location.isEmpty) {
      _showMessage("Please enter a location for exams.");
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
    final typeLabel =
        _type == ItemType.exam ? "EXAMS" : "TASKS";
    final typeColor =
        _type == ItemType.exam
            ? AppColors.accentPink
            : AppColors.accentBlue;

    return Scaffold(
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
              AppColors.primary.withOpacity(0.08),
              AppColors.accentBlue.withOpacity(0.08),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        typeColor.withOpacity(0.2),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildField("Subject",
                    _subjectController,
                    outlined: true),
                _buildField("Activity",
                    _titleController,
                    filled: true),
                Row(
                  children: [
                    Expanded(
                      child:
                          _buildPickerField(
                        value: _formatDate(
                            _selectedDate),
                        icon: Icons
                            .calendar_today,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child:
                          _buildPickerField(
                        value: _formatTime(
                            _selectedTime),
                        icon: Icons
                            .access_time,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                if (_type == ItemType.exam)
                  _buildField("Location",
                      _locationController,
                      filled: true),
                _buildField("Brief Notes",
                    _descController,
                    isLong: true,
                    filled: true),
              ],
            ),
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
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: isLong ? 4 : 1,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: filled
              ? AppColors.bgInput
              : Colors.transparent,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(22),
            borderSide: BorderSide(
              color: outlined
                  ? Colors.black87
                  : Colors.transparent,
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
            color: AppColors.bgInput,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style:
                      const TextStyle(
                          fontWeight:
                              FontWeight.w700),
                ),
              ),
              Icon(icon,
                  size: 18,
                  color:
                      Colors.grey[500]),
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
                : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: filled
                ? Colors.white
                : iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}