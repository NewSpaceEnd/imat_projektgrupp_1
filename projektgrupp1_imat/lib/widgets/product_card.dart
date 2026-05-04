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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Align(
      alignment: Alignment.centerLeft,
      child: Text(
        iMat.getDetail(product)?.origin ?? '',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
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
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C3BD6), // purple
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {
        iMat.shoppingCartAdd(ShoppingItem(product, amount: 1.0));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lagt till i varukorg')));
      },
      child: const Text('Lägg till i varukorg', style: TextStyle(color: Colors.white)),
    ),
  ],
),
      ),
    );
  }
}
