import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/category_sort_sidebar.dart';
import 'package:imat_app/widgets/product_card.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:provider/provider.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
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
    final iMat = context.watch<ImatDataHandler>();
    final searchResults = _sortedProducts(iMat.selectProducts);

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
                onPressed: () {
                  iMat.selectAllProducts();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, size: 20),
                label: const Text('Tillbaka'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            );

            final sidebar = CategorySortSidebar(
              selectedMode: _sortMode,
              onChanged: (mode) => setState(() => _sortMode = mode),
            );

            final grid = searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 72, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'Inga produkter matchade "${iMat.searchQuery}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: AppTheme.paddingSmall,
                      mainAxisSpacing: AppTheme.paddingSmall,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: searchResults.length,
                    itemBuilder: (ctx, i) => ProductCard(searchResults[i], iMat),
                  );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 190, child: sidebar),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        backButton,
                        const SizedBox(height: AppTheme.paddingSmall),
                        Expanded(child: grid),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                backButton,
                const SizedBox(height: AppTheme.paddingSmall),
                sidebar,
                const SizedBox(height: AppTheme.paddingSmall),
                Expanded(child: grid),
              ],
            );
          },
        ),
      ),
    );
  }
}
