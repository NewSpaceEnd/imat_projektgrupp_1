import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/product_card.dart';
import 'package:imat_app/widgets/primary_action_button.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/model/imat/shopping_item.dart';

const double shoppingCartSummaryLabelTextSize = 36.0;
const double shoppingCartSummaryValueTextSize = 36.0;
const double shoppingCartSummaryTotalValueTextSize = 46.0;

class ShoppingCartPage extends StatelessWidget {
  static const double serviceFee = 25.0;

  const ShoppingCartPage({super.key});

  Future<void> _showSaveCartDialog(BuildContext pageContext) async {
    final iMat = Provider.of<ImatDataHandler>(pageContext, listen: false);
    final items = iMat.getShoppingCart().items;
    if (items.isEmpty) return;

    final nameCtrl = TextEditingController();
    final selected = List<bool>.filled(items.length, true);

    bool saved = false;
    await showDialog<void>(
      context: pageContext,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final media = MediaQuery.of(context).size;
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: media.width * 0.08, vertical: media.height * 0.03),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              width: media.width * 0.75,
              height: media.height * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Spara varukorg', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Namn på sparad varukorg')),
                    const SizedBox(height: 12),
                    const Text('Välj varor att spara', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),

                    // Select / Deselect all button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            final all = selected.every((v) => v);
                            setState(() {
                              for (var idx = 0; idx < selected.length; idx++) selected[idx] = !all;
                            });
                          },
                          child: Text(selected.every((v) => v) ? 'Avmarkera alla' : 'Välj alla', style: const TextStyle(fontSize: 18)),
                        ),
                      ],
                    ),

                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: LayoutBuilder(builder: (ctx, constraints) {
                          const maxItemWidth = 220.0;
                          final crossAxisCount = (constraints.maxWidth / maxItemWidth).floor().clamp(1, 6);
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: items.length,
                            itemBuilder: (ctx, i) {
                              final prod = items[i].product;
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Center(child: AspectRatio(aspectRatio: 1, child: iMat.getImage(prod))),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Checkbox(value: selected[i], onChanged: (v) => setState(() => selected[i] = v ?? false)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(prod.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Avbryt', style: TextStyle(fontSize: 20))),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: saved
                              ? null
                              : () async {
                                  final name = nameCtrl.text.trim().isEmpty ? 'Sparad varukorg' : nameCtrl.text.trim();
                                  final selectedItems = <ShoppingItem>[];
                                  for (var i = 0; i < items.length; i++) {
                                    if (selected[i]) selectedItems.add(ShoppingItem(items[i].product, amount: items[i].amount));
                                  }

                                  if (selectedItems.length == items.length) {
                                    await iMat.saveShoppingCart(name);
                                  } else {
                                    await iMat.saveShoppingCartWithItems(name, selectedItems);
                                  }

                                  // Visual feedback: make button green and close dialog after short delay
                                  setState(() => saved = true);
                                  await Future.delayed(const Duration(milliseconds: 700));
                                  if (Navigator.canPop(context)) Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(backgroundColor: saved ? Colors.green : const Color(0xFF8B5CF6), foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: 20)),
                          child: Text(saved ? 'Sparad' : 'Spara', style: const TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

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

                          // Save cart button (under totals but above checkout)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Builder(builder: (ctx) {
                                final saved = iMat.isCurrentCartSaved();
                                return ElevatedButton.icon(
                                  onPressed: () {
                                    if (!saved) _showSaveCartDialog(context);
                                  },
                                  icon: const Icon(Icons.save),
                                  label: Text(saved ? 'Sparad' : 'Spara varukorg', style: const TextStyle(fontSize: 22)),
                                  style: ElevatedButton.styleFrom(backgroundColor: saved ? Colors.green : const Color(0xFF8B5CF6), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontSize: 22)),
                                );
                              }),
                            ),
                          ),

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
