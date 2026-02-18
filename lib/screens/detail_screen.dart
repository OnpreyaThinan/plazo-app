import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../models.dart';
import 'edit_screen.dart';

class DetailScreen extends StatefulWidget {
  final PlazoItem item;
  final Function(PlazoItem) onUpdate;
  final Function(String) onDelete;

  const DetailScreen({super.key, required this.item, required this.onUpdate, required this.onDelete});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PlazoItem _item;

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
    return Scaffold(
      backgroundColor: AppColors.bgDetailLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgDetailLight,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (_item.type == ItemType.exam ? AppColors.accentPink : AppColors.accentBlue)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _item.type == ItemType.exam ? "EXAM" : "TASK",
                  style: TextStyle(
                    color: _item.type == ItemType.exam ? AppColors.accentPink : AppColors.accentBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(_item.subject, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
              Text(_item.title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _infoRow(Icons.calendar_today, _item.date)),
                  const SizedBox(width: 16),
                  Expanded(child: _infoRow(Icons.access_time, _item.time)),
                ],
              ),
              if (_item.location != null) ...[
                const SizedBox(height: 10),
                _infoRow(Icons.location_on, _item.location!),
              ],
              const SizedBox(height: 24),
              const Text("BRIEF NOTES",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(22)),
                child: Text(
                  _item.description.isEmpty ? "No additional notes." : _item.description,
                  style: const TextStyle(height: 1.5, color: AppColors.textMain),
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
                  backgroundColor: _item.isCompleted ? Colors.grey[200] : AppColors.primary,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: Text(
                  _item.isCompleted ? "Move to Pending" : "Done",
                  style: TextStyle(
                    color: _item.isCompleted ? Colors.grey : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      );

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
