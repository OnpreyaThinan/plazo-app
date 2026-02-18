import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../item_card.dart';
import '../models.dart';

class CompletedScreen extends StatelessWidget {
  final List<PlazoItem> items;
  final Function(String) onDetail;

  const CompletedScreen({super.key, required this.items, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    final completed = items.where((i) => i.isCompleted).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text("Finished", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          if (completed.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: Text("No completed tasks yet", style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ...completed.map(
              (item) => Opacity(
                opacity: 0.7,
                child: ItemCard(item: item, onTap: () => onDetail(item.id)),
              ),
            ),
        ],
      ),
    );
  }
}
