import 'package:flutter/material.dart';

const double categorySortSidebarTitleTextSize = 22.0;
const double categorySortSidebarOptionTextSize = 16.0;

enum CategorySortMode {
  relevance,
  priceHighToLow,
  comparisonPriceHighToLow,
  campaigns,
}

class CategorySortSidebar extends StatelessWidget {
  final CategorySortMode selectedMode;
  final ValueChanged<CategorySortMode> onChanged;

  const CategorySortSidebar({
    required this.selectedMode,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sortera:',
            style: TextStyle(fontSize: categorySortSidebarTitleTextSize, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _SortOption(
            label: 'Relevans',
            isSelected: selectedMode == CategorySortMode.relevance,
            onTap: () => onChanged(CategorySortMode.relevance),
          ),
          _SortOption(
            label: 'Kampanjer',
            isSelected: selectedMode == CategorySortMode.campaigns,
            onTap: () => onChanged(CategorySortMode.campaigns),
          ),
          _SortOption(
            label: 'Pris: hög - lågt',
            isSelected: selectedMode == CategorySortMode.priceHighToLow,
            onTap: () => onChanged(CategorySortMode.priceHighToLow),
          ),
          _SortOption(
            label: 'Jmf. pris: hög - lågt',
            isSelected: selectedMode == CategorySortMode.comparisonPriceHighToLow,
            onTap: () => onChanged(CategorySortMode.comparisonPriceHighToLow),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? const Color(0xFFDCCFFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: categorySortSidebarOptionTextSize,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF2F2F35),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}