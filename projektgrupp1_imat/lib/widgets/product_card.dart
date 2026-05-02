import 'package:flutter/material.dart';
import 'package:projektgrupp1_imat/app_theme.dart';
import 'package:projektgrupp1_imat/util/home_models.dart';
import 'package:projektgrupp1_imat/widgets/product_art.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final ProductData product;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 205,
      decoration: BoxDecoration(
        color: AppTheme.panelSoft,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.country,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 22,
              color: AppTheme.textPrimary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(height: 140, child: ProductArt(type: product.art)),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 42),
          ),
          if (product.detail.isNotEmpty)
            Text(
              product.detail,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 27),
            ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.price,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 38),
                    ),
                    Text(
                      '${product.unit}   ${product.unitPrice}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 22),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  'Lagg till i\nvarukorg',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
