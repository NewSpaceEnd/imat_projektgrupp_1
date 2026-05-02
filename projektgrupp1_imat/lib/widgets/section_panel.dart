import 'package:flutter/material.dart';
import 'package:projektgrupp1_imat/app_theme.dart';
import 'package:projektgrupp1_imat/util/home_models.dart';
import 'package:projektgrupp1_imat/widgets/product_card.dart';

class SectionPanel extends StatelessWidget {
  const SectionPanel({super.key, required this.section});

  final SectionData section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  section.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 53),
                ),
              ),
              _SectionButton(label: section.cta),
            ],
          ),
          if (section.products.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: section.products
                  .map((product) => ProductCard(product: product))
                  .toList(),
            ),
          ] else
            const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.panelSoft,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 35),
      ),
    );
  }
}
