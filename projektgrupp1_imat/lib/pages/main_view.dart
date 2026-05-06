import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/category_sidebar.dart';
import 'package:imat_app/widgets/search_bar.dart';
import 'package:imat_app/widgets/category_section.dart';
import 'package:imat_app/widgets/product_card.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:imat_app/util/category_names.dart';
import 'package:provider/provider.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();
    final isSearching = iMat.selectProducts.length != iMat.products.length;

      return Scaffold(
        appBar: TopNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left sidebar with categories
            CategorySidebar(iMat: iMat),
            const SizedBox(width: AppTheme.paddingSmall),
            // Right content area
            Expanded(
              child: ListView(
                children: [
                  // Search bar
                  SearchBarWidget(iMat: iMat),
                  if (isSearching) ...[
                    // Search results should appear first when searching
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingSmall),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sökresultat (${iMat.selectProducts.length})',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => iMat.selectAllProducts(),
                            child: const Text('Rensa sökning'),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppTheme.paddingSmall),
                      child: Wrap(
                        spacing: AppTheme.paddingSmall,
                        runSpacing: AppTheme.paddingSmall,
                        children: iMat.selectProducts
                            .map((product) => SizedBox(width: 200, height: 280, child: ProductCard(product, iMat)))
                            .toList(),
                      ),
                    ),
                  ],
                  if (iMat.favorites.isNotEmpty) ...[
                    _FavoriteSectionWidget(iMat: iMat),
                  ],
                  if (iMat.products.isNotEmpty) ...[
                    _SpecialOfferSectionWidget(iMat: iMat),
                  ],
                  if (!isSearching) ...[
                    // Dynamically generate category sections
                    ..._buildCategorySections(iMat),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorySections(ImatDataHandler iMat) {
    return orderedCategories
        .where((cat) => cat != ProductCategory.UNDEFINED)
        .map((cat) => CategorySectionWidget(
              title: getCategoryName(cat),
              category: cat,
              iMat: iMat,
            ))
        .toList();
  }
}

    class _FavoriteSectionWidget extends StatelessWidget {
      final ImatDataHandler iMat;

      const _FavoriteSectionWidget({required this.iMat});

      @override
      Widget build(BuildContext context) {
        final preview = iMat.favorites.take(8).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.paddingLarge),
          padding: const EdgeInsets.all(AppTheme.paddingSmall),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Favoriter',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => iMat.selectFavorites(),
                    child: const Text('Till alla favoriter'),
                  ),
                ],
              ),
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: preview.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppTheme.paddingSmall),
                  itemBuilder: (ctx, i) => SizedBox(width: 200, child: ProductCard(preview[i], iMat)),
                ),
              ),
            ],
          ),
        );
      }
    }

    class _SpecialOfferSectionWidget extends StatelessWidget {
      final ImatDataHandler iMat;

      const _SpecialOfferSectionWidget({required this.iMat});

      List<Product> _specialOffers() {
        final sorted = [...iMat.products]..sort((a, b) => a.price.compareTo(b.price));
        final favoritesIds = iMat.favorites.map((p) => p.productId).toSet();
        return sorted
            .where((product) => !favoritesIds.contains(product.productId))
            .take(8)
            .toList();
      }

      @override
      Widget build(BuildContext context) {
        final preview = _specialOffers();

        if (preview.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.paddingLarge),
          padding: const EdgeInsets.all(AppTheme.paddingSmall),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Specialerbjudanden',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/offers'),
                    child: const Text('Till alla erbjudanden'),
                  ),
                ],
              ),
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: preview.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppTheme.paddingSmall),
                  itemBuilder: (ctx, i) => SizedBox(width: 200, child: ProductCard(preview[i], iMat)),
                ),
              ),
            ],
          ),
        );
      }
    }
