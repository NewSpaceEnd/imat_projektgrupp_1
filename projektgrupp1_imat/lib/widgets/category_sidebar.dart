import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/util/category_names.dart';

class CategorySidebar extends StatelessWidget {
  final ImatDataHandler iMat;

  const CategorySidebar({required this.iMat, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Container(
        color: Colors.grey[200],
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _onFavoritesPressed(),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Favoriter',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...orderedCategories
                          .where((cat) => cat != ProductCategory.UNDEFINED)
                          .map((cat) {
                    return GestureDetector(
                      onTap: () => _onCategoryPressed(cat),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          getCategoryName(cat),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  }).toList(),
                    ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCategoryPressed(ProductCategory category) {
    final products = iMat.findProductsByCategory(category);
    iMat.selectSelection(products);
  }

  void _onFavoritesPressed() {
    iMat.selectFavorites();
  }
}



