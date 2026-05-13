import 'package:flutter/material.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/util/category_names.dart';

class CategorySidebar extends StatelessWidget {
  final ProductCategory? activeCategory;
  final bool favoritesActive;
  final bool specialOffersActive;
  final ValueChanged<ProductCategory> onCategoryTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onSpecialOffersTap;

  const CategorySidebar({
    required this.onCategoryTap,
    required this.onFavoritesTap,
    required this.onSpecialOffersTap,
    this.activeCategory,
    this.favoritesActive = false,
    this.specialOffersActive = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 220),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Kategorier',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _SidebarItem(
                label: 'Favoriter',
                isHighlighted: favoritesActive,
                onTap: onFavoritesTap,
              ),
              _SidebarItem(
                label: 'Specialerbjudanden',
                isHighlighted: specialOffersActive,
                onTap: onSpecialOffersTap,
              ),
              const SizedBox(height: 8),
              ...orderedCategories
                  .where((cat) => cat != ProductCategory.UNDEFINED)
                  .map(
                    (cat) => _SidebarItem(
                      label: getCategoryName(cat),
                      isHighlighted: activeCategory == cat,
                      onTap: () => onCategoryTap(cat),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _SidebarItem({
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFFD8CFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isHighlighted ? 15 : 14,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}



