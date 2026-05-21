import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/preview_product_strip.dart';
import 'package:imat_app/widgets/primary_action_button.dart';

class CategorySectionWidget extends StatelessWidget {
  final String title;
  final ProductCategory category;
  final ImatDataHandler iMat;

  static const int previewItemCount = 5;

  const CategorySectionWidget({
    required this.title,
    required this.category,
    required this.iMat,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final products = iMat.findProductsByCategory(category);
    final preview = products.take(previewItemCount).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingLarge),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(
                width: 200,
                child: PrimaryActionButton(
                  label: 'Till all $title',
                  onPressed: () => _onSeeAllPressed(context, products),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PreviewProductStrip(
            products: preview,
            iMat: iMat,
            height: 525,
          ),
        ],
      ),
    );
  }

  void _onSeeAllPressed(BuildContext context, List<Product> products) {
    // Navigate to category view showing all products in this category
    final categoryName = category.toString().split('.').last;
    final encodedTitle = Uri.encodeComponent(title);
    Navigator.pushNamed(
      context,
      '/category/$encodedTitle/$categoryName',
    );
  }
}
