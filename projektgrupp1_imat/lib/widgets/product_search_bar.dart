import 'package:flutter/material.dart';
import 'package:projektgrupp1_imat/app_theme.dart';

class ProductSearchBar extends StatelessWidget {
  const ProductSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppTheme.panelSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Sok efter produkter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 42,
                color: AppTheme.textPrimary.withValues(alpha: 0.45),
              ),
            ),
          ),
          const Icon(Icons.search, size: 38, color: Colors.black87),
        ],
      ),
    );
  }
}
