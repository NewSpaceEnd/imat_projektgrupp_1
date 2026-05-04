import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/product_card.dart';

class CategorySectionWidget extends StatelessWidget {
  final String title;
  final ProductCategory category;
  final ImatDataHandler iMat;

  const CategorySectionWidget({
    required this.title,
    required this.category,
    required this.iMat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final products = iMat.findProductsByCategory(category);
    final preview = products.take(8).toList();

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
              Text(title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => _onSeeAllPressed(products),
                child: Text('Till all $title'),
              ),
            ],
          ),
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: preview.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTheme.paddingSmall),
              itemBuilder: (ctx, i) =>
                  SizedBox(width: 200, child: ProductCard(preview[i], iMat)),
            ),
          ),
        ],
      ),
    );
  }

  void _onSeeAllPressed(List<Product> products) {
    iMat.selectSelection(products);
  }
}
