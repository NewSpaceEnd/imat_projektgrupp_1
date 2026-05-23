import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/product_card.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:imat_app/widgets/category_sort_sidebar.dart';

const double favoritesPageTitleTextSize = 28.0;

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final favorites = iMat.favorites;

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

          final productGrid = favorites.isEmpty
              ? const Center(child: Text('Du har inga favoriter än'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: AppTheme.paddingSmall,
                    mainAxisSpacing: AppTheme.paddingSmall,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (ctx, i) => ProductCard(favorites[i], iMat),
                );

          final sidebar = CategorySortSidebar(
            selectedMode: CategorySortMode.relevance,
            onChanged: (_) {},
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
                  'Favoriter',
                  style: TextStyle(fontSize: favoritesPageTitleTextSize, fontWeight: FontWeight.w800),
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
