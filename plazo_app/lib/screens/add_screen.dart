import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models.dart';

class AddScreen extends StatefulWidget {
  final Function(PlazoItem) onAdd;
  const AddScreen({super.key, required this.onAdd});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  ItemType _type = ItemType.task;
  final _subjectController = TextEditingController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => TimePickerDialog(
        initialTime: _selectedTime,
      ),
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
      _selectedDate = DateTime.now();
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
    });
    FocusScope.of(context).unfocus();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add Plan",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      _toggleButton(
                        "Tasks",
                        _type == ItemType.task,
                        () => setState(() => _type = ItemType.task),
                      ),
                      _toggleButton(
                        "Exams",
                        _type == ItemType.exam,
                        () => setState(() => _type = ItemType.exam),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildField("Subject", _subjectController,
                    hint: "e.g. Mathematics"),
                _buildField("Activity", _titleController,
                    hint: "e.g. Midterm Prep"),
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerField(
                        label: "Due Date",
                        value: _formatDate(_selectedDate),
                        icon: Icons.calendar_today,
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPickerField(
                        label: "Time",
                        value: _formatTime(_selectedTime),
                        icon: Icons.access_time,
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                if (_type == ItemType.exam)
                  _buildField("Location", _locationController,
                      hint: "e.g. Exam Hall B"),
                _buildField("Brief Notes", _descController,
                    isLong: true, hint: "Add some notes..."),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
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
                      _showMessage(
                          "Please enter a location for exams.");
                      return;
                    }

                    widget.onAdd(
                      PlazoItem(
                        id: DateTime.now().toString(),
                        type: _type,
                        title: title,
                        subject: subject,
                        date: _formatDate(_selectedDate),
                        time: _formatTime(_selectedTime),
                        description: _descController.text.trim(),
                        location:
                            _type == ItemType.exam ? location : null,
                      ),
                    );
                    _resetForm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Add Plan",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
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
                  ? Colors.white
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
                      : Colors.grey,
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: isLong ? 4 : 1,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.bgInput,
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
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
                color: AppColors.bgInput,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                          fontWeight:
                              FontWeight.w700),
                    ),
                  ),
                  Icon(icon,
                      size: 18,
                      color: Colors.grey[500]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}