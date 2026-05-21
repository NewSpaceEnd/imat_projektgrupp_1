import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/product_card.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';

class SpecialOffersPage extends StatelessWidget {
  const SpecialOffersPage({super.key});

  List<Product> _specialOffers(ImatDataHandler iMat) {
    final sorted = [...iMat.products]..sort((a, b) => a.price.compareTo(b.price));
    final favoritesIds = iMat.favorites.map((p) => p.productId).toSet();
    return sorted.where((product) => !favoritesIds.contains(product.productId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final offers = _specialOffers(iMat);

    return Scaffold(
      appBar: const TopNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: offers.isEmpty
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
              ),
      ),
    );
  }
}