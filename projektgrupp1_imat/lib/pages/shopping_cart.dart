import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/product_card.dart';
import 'package:imat_app/widgets/primary_action_button.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:provider/provider.dart';

const double shoppingCartSummaryLabelTextSize = 36.0;
const double shoppingCartSummaryValueTextSize = 36.0;
const double shoppingCartSummaryTotalValueTextSize = 46.0;

class ShoppingCartPage extends StatelessWidget {
  static const double serviceFee = 25.0;

  const ShoppingCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final cart = iMat.getShoppingCart();
    final cartTotal = iMat.shoppingCartTotal();
    final totalWithService = cartTotal + (cart.items.isEmpty ? 0 : serviceFee);
    final itemCount = cart.items.fold<int>(0, (sum, item) => sum + item.amount.toInt());

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: const TopNavBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 132, color: Colors.grey),
                const SizedBox(height: 18),
                const Text(
                  'Din varukorg är tom',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 280,
                  height: 58,
                  child: PrimaryActionButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                    label: 'Fortsätt handla',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const TopNavBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Two-column layout: Products on left, Summary on right
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side: Products in scrollable grid
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: false,
                        physics: const AlwaysScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.78,
                        children: cart.items.map((item) {
                          return ProductCard(item.product, iMat);
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right side: Summary
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Antal varor
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(minHeight: 80),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Antal varor',
                                  style: TextStyle(fontSize: shoppingCartSummaryLabelTextSize, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  itemCount.toString(),
                                  style: const TextStyle(fontSize: shoppingCartSummaryValueTextSize, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Avgift
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(minHeight: 80),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Avgift',
                                  style: TextStyle(fontSize: shoppingCartSummaryLabelTextSize, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${serviceFee.toStringAsFixed(0)} kr',
                                  style: const TextStyle(fontSize: shoppingCartSummaryValueTextSize, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Totalt belopp
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: const BoxConstraints(minHeight: 88),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Totalt belopp',
                                  style: TextStyle(fontSize: shoppingCartSummaryLabelTextSize, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${totalWithService.toStringAsFixed(2)} kr',
                                  style: const TextStyle(fontSize: shoppingCartSummaryTotalValueTextSize, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Checkout button: no outer decoration, placed directly
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: PrimaryActionButton(
                                onPressed: () => Navigator.pushNamed(context, '/checkout'),
                                icon: Icons.shopping_cart,
                                label: 'Betala',
                                textSize: 28.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // (Checkout button moved to right-side summary column)
        ],
      ),
    );
  }
}
