import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/product_card.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final favorites = iMat.favorites;

    return Scaffold(
      appBar: const TopNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: favorites.isEmpty
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
              ),
      ),
    );
  }
}
