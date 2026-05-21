import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/preview_product_strip.dart';
import 'package:imat_app/widgets/primary_action_button.dart';

/// En sektion som visar en kategori med:
/// - Rubrik för kategorin
/// - En lila PrimaryActionButton med "Till all [kategori]"
/// - En förhandsvisning av de första 5 produkterna i kategorin
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
    // Hämta alla produkter i denna kategori
    final products = iMat.findProductsByCategory(category);
    // Ta bara de första 5 för förhandsvisningen
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
          // Rubrik med kategori-namn och "Till all" knapp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kategori-rubrik
              Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              // Lila "Till all [kategori]" knapp som navigerar till full kategori-vy
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
          // Förhandsvisning av de första 5 produkterna i kategorin
          PreviewProductStrip(
            products: preview,
            iMat: iMat,
            height: 525,
          ),
        ],
      ),
    );
  }

  /// Navigerar till full kategori-vy med alla produkter i denna kategori
  void _onSeeAllPressed(BuildContext context, List<Product> products) {
    // Extract och URL-encode kategori-namn
    final categoryName = category.toString().split('.').last;
    final encodedTitle = Uri.encodeComponent(title);
    Navigator.pushNamed(
      context,
      '/category/$encodedTitle/$categoryName',
    );
  }
}
