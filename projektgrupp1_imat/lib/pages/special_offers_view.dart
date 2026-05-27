import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/product_card.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:imat_app/widgets/category_sort_sidebar.dart';

const double specialOffersTitleTextSize = 28.0;

class SpecialOffersPage extends StatefulWidget {
  const SpecialOffersPage({super.key});

  @override
  State<SpecialOffersPage> createState() => _SpecialOffersPageState();
}

class _SpecialOffersPageState extends State<SpecialOffersPage> {
  CategorySortMode _sortMode = CategorySortMode.relevance;

  List<Product> _specialOffers(ImatDataHandler iMat) {
    final products = iMat.products.where((p) => !iMat.favorites.map((f) => f.productId).contains(p.productId)).toList();
    switch (_sortMode) {
      case CategorySortMode.relevance:
        return products;
      case CategorySortMode.priceHighToLow:
        return [...products]..sort((a, b) => b.price.compareTo(a.price));
      case CategorySortMode.comparisonPriceHighToLow:
        return [...products]..sort((a, b) => b.price.compareTo(a.price));
      case CategorySortMode.campaigns:
        final sorted = [...products]..sort((a, b) => a.price.compareTo(b.price));
        if (sorted.length <= 4) return sorted;
        final limit = (sorted.length * 0.35).ceil().clamp(1, sorted.length);
        return sorted.take(limit).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final offers = _specialOffers(iMat);

    return Scaffold(
      appBar: const TopNavBar(),
      body: LayoutBuilder(
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

          final productGrid = offers.isEmpty
              ? const Center(child: Text('Inga erbjudanden just nu'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: AppTheme.paddingSmall,
                    mainAxisSpacing: AppTheme.paddingSmall,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: offers.length,
                  itemBuilder: (ctx, i) => ProductCard(offers[i], iMat),
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
                child: const Text(
                  'Specialerbjudanden',
                  style: TextStyle(fontSize: specialOffersTitleTextSize, fontWeight: FontWeight.w800),
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
    );
  }
}