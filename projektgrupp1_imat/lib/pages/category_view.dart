import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/product_card.dart';

class CategoryView extends StatelessWidget {
  final String title;
  final ProductCategory category;

  const CategoryView({
    required this.title,
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final iMat = Provider.of<ImatDataHandler>(context);
    final products = iMat.findProductsByCategory(category);

    return Scaffold(
      appBar: TopNavBar(title: title),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: products.isEmpty
            ? const Center(child: Text('Inga produkter i denna kategori'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: AppTheme.paddingSmall,
                  mainAxisSpacing: AppTheme.paddingSmall,
                ),
                itemCount: products.length,
                itemBuilder: (ctx, i) => ProductCard(products[i], iMat),
              ),
      ),
    );
  }
}
