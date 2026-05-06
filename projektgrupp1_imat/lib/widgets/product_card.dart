import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/imat/shopping_item.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ImatDataHandler iMat;

  const ProductCard(this.product, this.iMat, {super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: iMat,
      builder: (context, _) {
        final amountInCart = iMat.shoppingCartAmount(product);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        iMat.getDetail(product)?.origin ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          iMat.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                          color: iMat.isFavorite(product) ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => iMat.toggleFavorite(product),
                        tooltip: iMat.isFavorite(product) ? 'Ta bort favorit' : 'Lägg till favorit',
                      ),
                    ),
                  ],
                ),
                Expanded(child: iMat.getImage(product)),
                const SizedBox(height: AppTheme.paddingSmall),
                const SizedBox(height: 6),
                Text(
                  product.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '${product.unit} • ${product.price.toStringAsFixed(2)} kr',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                if (amountInCart <= 0)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C3BD6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      iMat.shoppingCartAdd(ShoppingItem(product, amount: 1.0));
                    },
                    child: const Text(
                      'Lägg till i varukorg',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6FB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.remove),
                          onPressed: () => iMat.shoppingCartUpdate(ShoppingItem(product, amount: 1.0), delta: -1.0),
                        ),
                        Text(
                          amountInCart.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.add),
                          onPressed: () => iMat.shoppingCartAdd(ShoppingItem(product, amount: 1.0)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
