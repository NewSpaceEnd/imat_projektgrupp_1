import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/category_sidebar.dart';
import 'package:imat_app/widgets/search_bar.dart';
import 'package:imat_app/widgets/category_section.dart';
import 'package:provider/provider.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    var iMat = context.watch<ImatDataHandler>();

    return Scaffold(
      appBar: AppBar(title: const Text('iMats produkter')),
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
                  // Dynamically generate category sections
                  ..._buildCategorySections(iMat),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorySections(ImatDataHandler iMat) {
    return ProductCategory.values
        .where((cat) => cat != ProductCategory.UNDEFINED)
        .map((cat) => CategorySectionWidget(
              title: _categoryName(cat),
              category: cat,
              iMat: iMat,
            ))
        .toList();
  }
}


String _categoryName(ProductCategory cat) {
  const categoryNames = {
    ProductCategory.POD: 'Frukt och bär',
    ProductCategory.BREAD: 'Bröd',
    ProductCategory.BERRY: 'Bär',
    ProductCategory.CITRUS_FRUIT: 'Citrusfrukter',
    ProductCategory.HOT_DRINKS: 'Varma drycker',
    ProductCategory.COLD_DRINKS: 'Kalla drycker',
    ProductCategory.EXOTIC_FRUIT: 'Exotisk frukt',
    ProductCategory.FISH: 'Fisk & skaldjur',
    ProductCategory.VEGETABLE_FRUIT: 'Fruktgrönsaker',
    ProductCategory.CABBAGE: 'Kål',
    ProductCategory.MEAT: 'Charkuteri',
    ProductCategory.DAIRIES: 'Mejeri',
    ProductCategory.MELONS: 'Meloner',
    ProductCategory.FLOUR_SUGAR_SALT: 'Mjöl, socker & salt',
    ProductCategory.NUTS_AND_SEEDS: 'Nötter & frön',
    ProductCategory.PASTA: 'Pasta',
    ProductCategory.POTATO_RICE: 'Potatis & ris',
    ProductCategory.ROOT_VEGETABLE: 'Rotfrukter',
    ProductCategory.FRUIT: 'Frukt och grönt',
    ProductCategory.SWEET: 'Godis & snacks',
    ProductCategory.HERB: 'Örter',
  };
  return categoryNames[cat] ?? cat.name;
}
