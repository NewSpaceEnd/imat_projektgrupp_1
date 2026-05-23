import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/widgets/primary_action_button.dart';
import 'package:provider/provider.dart';

const double shoppingCartOverlayHeaderTextSize = 30.0;
const double shoppingCartOverlaySummaryTextSize = 25.0;
const double shoppingCartOverlayLineItemNameTextSize = 25.0;
const double shoppingCartOverlayBodyTextSize = 25.0;
const double shoppingCartOverlaySmallTextSize = 25.0;

Future<void> showShoppingCartOverlay(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Stäng varukorg',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      final width = MediaQuery.of(context).size.width;
      final panelWidth = width < 720 ? width * 0.92 : 420.0;

      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Stack(
            children: [
              // Fullskärms tryckbar yta bakom panelen - tänker "dismiss" när man klickar
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Container(),
                ),
              ),
              // Sidopanelen som glider in från höger
              Align(
                alignment: Alignment.centerRight,
                child: SlideTransition(
                  position: slide,
                  child: SizedBox(
                    width: panelWidth,
                    height: double.infinity,
                    child: const _ShoppingCartOverlayPanel(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ShoppingCartOverlayPanel extends StatelessWidget {
  /// Panelen inuti overlay som visar:
  /// - Rubrik med antal varor
  /// - Lista av varor i varukorgen
  /// - Totalbeläpp med serviceavgift
  /// - Knappar för "Varukorg" och "Till kassan"
  const _ShoppingCartOverlayPanel();

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final cart = iMat.getShoppingCart();
    final cartTotal = iMat.shoppingCartTotal();
    final serviceFee = cart.items.isEmpty ? 0.0 : 25.0;
    final totalWithService = cartTotal + serviceFee;

    return Material(
      color: const Color(0xFFF6F6F8),
      elevation: 24,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Varukorg (${cart.items.length} varor)',
                    style: const TextStyle(fontSize: shoppingCartOverlayHeaderTextSize, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Stäng',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: cart.items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Din varukorg är tom', style: TextStyle(fontSize: shoppingCartOverlayBodyTextSize)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _CartLineItem(item: item);
                    },
                  ),
          ),
          // Totalsumma och knapprar för navigation
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Card(
              color: const Color(0xFFEFEAFB),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Varor totalt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Varor totalt', style: TextStyle(fontSize: shoppingCartOverlayBodyTextSize)),
                        Text('${cartTotal.toStringAsFixed(2)} kr', style: TextStyle(fontSize: shoppingCartOverlayBodyTextSize)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Serviceavgift (25 kr om varukorgen inte är tom)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Serviceavgift', style: TextStyle(fontSize: shoppingCartOverlayBodyTextSize)),
                        Text('${serviceFee.toStringAsFixed(2)} kr', style: TextStyle(fontSize: shoppingCartOverlayBodyTextSize)),
                      ],
                    ),
                    const Divider(height: 18),
                    // Total belopp att betala
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Att betala',
                          style: TextStyle(fontSize: shoppingCartOverlaySummaryTextSize, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${totalWithService.toStringAsFixed(2)} kr',
                          style: TextStyle(fontSize: shoppingCartOverlaySummaryTextSize, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Knappar för att gå till varukorg-sidan eller kassan
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: PrimaryActionButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pushNamed(context, '/cart');
                              },
                              label: 'Varukorg',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryActionButton(
                              onPressed: cart.items.isEmpty
                                  ? null
                                  : () {
                                      Navigator.of(context).pop();
                                      Navigator.pushNamed(context, '/checkout');
                                    },
                              label: 'Till kassan',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLineItem extends StatelessWidget {
  final ShoppingItem item;

  const _CartLineItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final iMat = context.read<ImatDataHandler>();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: iMat.getImage(item.product),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(fontSize: shoppingCartOverlayLineItemNameTextSize, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.product.unit,
                    style: TextStyle(fontSize: shoppingCartOverlaySmallTextSize, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text('${item.total.toStringAsFixed(2)} kr', style: TextStyle(fontSize: shoppingCartOverlayBodyTextSize)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => iMat.shoppingCartRemove(item),
                  child: Text('Ta bort', style: TextStyle(fontSize: shoppingCartOverlaySmallTextSize)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      padding: EdgeInsets.zero,
                      onPressed: () => iMat.shoppingCartUpdate(item, delta: -1.0),
                      icon: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        item.amount.toStringAsFixed(0),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: shoppingCartOverlaySmallTextSize),
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      padding: EdgeInsets.zero,
                      onPressed: () => iMat.shoppingCartUpdate(item, delta: 1.0),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
