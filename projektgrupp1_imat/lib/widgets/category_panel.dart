import 'package:flutter/material.dart';
import 'package:projektgrupp1_imat/app_theme.dart';

class CategoryPanel extends StatelessWidget {
  const CategoryPanel({
    super.key,
    required this.categories,
    this.compact = false,
  });

  final List<String> categories;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategorier',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 40),
          ),
          const SizedBox(height: 6),
          if (compact)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories
                  .map(
                    (category) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.panelSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 22),
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            ...categories.map(
              (category) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  category,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 37),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
