import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';

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
                  children: ProductCategory.values.take(10).map((cat) {
                    return TextButton(
                      onPressed: () => _onCategoryPressed(cat),
                      child: Text(cat.name),
                    );
                  }).toList(),
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
}
