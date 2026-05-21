import 'package:flutter/material.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/product_card.dart';

class PreviewProductStrip extends StatelessWidget {
  final List<Product> products;
  final ImatDataHandler iMat;
  final double height;

  static const int maxVisibleItems = 5;
  static const double targetCardWidth = 300;
  static const double minFallbackCardWidth = 260;
  static const double gap = 16;

  const PreviewProductStrip({
    required this.products,
    required this.iMat,
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final preview = products.take(maxVisibleItems).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final requiredWidth = (targetCardWidth * preview.length) + (gap * (preview.length - 1));

        if (constraints.maxWidth >= requiredWidth) {
          return SizedBox(
            width: double.infinity,
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: preview
                  .map(
                    (product) => SizedBox(
                      width: targetCardWidth,
                      height: height,
                      child: ProductCard(product, iMat),
                    ),
                  )
                  .toList(),
            ),
          );
        }

        final fallbackCardWidth = ((constraints.maxWidth - (gap * (preview.length - 1))) / preview.length)
            .clamp(minFallbackCardWidth, targetCardWidth)
            .toDouble();

        return SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: preview.length,
            separatorBuilder: (_, __) => const SizedBox(width: gap),
            itemBuilder: (ctx, i) => SizedBox(
              width: fallbackCardWidth,
              height: height,
              child: ProductCard(preview[i], iMat),
            ),
          ),
        );
      },
    );
  }
}
