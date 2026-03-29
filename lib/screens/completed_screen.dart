import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_strings.dart';
import '../item_card.dart';
import '../models.dart';

class CompletedScreen extends StatelessWidget {
  final List<PlazoItem> items;
  final String language;
  final Function(String) onDetail;

  const CompletedScreen({
    super.key,
    required this.items,
    required this.language,
    required this.onDetail,
  });

  String _t(String key) => AppStrings.get(key, language);

  @override
  Widget build(BuildContext context) {
    final completed = items.where((i) => i.isCompleted).toList();

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
        child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(_t('finished'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),
          if (completed.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text(_t('noCompletedTasksYet'), style: TextStyle(color: AppColors.getSecondaryTextColor(context))),
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
      ),
    );
  }
}
