import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/product_card.dart';
import 'package:imat_app/widgets/category_sort_sidebar.dart';

class CategoryView extends StatefulWidget {
  final String title;
  final ProductCategory category;

  const CategoryView({
    required this.title,
    required this.category,
    super.key,
  });

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  CategorySortMode _sortMode = CategorySortMode.relevance;

  List<Product> _sortedProducts(List<Product> products) {
    switch (_sortMode) {
      case CategorySortMode.relevance:
        return products;
      case CategorySortMode.priceHighToLow:
        return [...products]..sort((a, b) => b.price.compareTo(a.price));
      case CategorySortMode.comparisonPriceHighToLow:
        return [...products]..sort((a, b) => b.price.compareTo(a.price));
      case CategorySortMode.campaigns:
        final sorted = [...products]..sort((a, b) => a.price.compareTo(b.price));
        if (sorted.length <= 4) {
          return sorted;
        }

        final limit = math.max(1, (sorted.length * 0.35).ceil());
        return sorted.take(limit).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final iMat = Provider.of<ImatDataHandler>(context);
    final products = _sortedProducts(iMat.findProductsByCategory(widget.category));

    return Scaffold(
      appBar: const TopNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final backButton = SizedBox(
              width: 120,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('Tillbaka'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            );

            final productGrid = products.isEmpty
                ? const Center(child: Text('Inga produkter i denna kategori'))
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: AppTheme.paddingSmall,
                      mainAxisSpacing: AppTheme.paddingSmall,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) => ProductCard(products[i], iMat),
                  );

            final sidebar = CategorySortSidebar(
              selectedMode: _sortMode,
              onChanged: (mode) => setState(() => _sortMode = mode),
            );

            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                backButton,
                const SizedBox(height: AppTheme.paddingSmall),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    widget.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                Expanded(child: productGrid),
              ],
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 190, child: sidebar),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Expanded(child: content),
                ],
              );
            }

            return Column(
              children: [
                sidebar,
                const SizedBox(height: AppTheme.paddingSmall),
                Expanded(child: content),
              ],
            );
          },
        ),
      ),
    );
  }
}
