import 'package:flutter/material.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/shopping_cart_overlay.dart';
import 'package:imat_app/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/pages/main_view.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  static const double serviceFee = 25.0;

  const TopNavBar({this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name ?? '';
    final isCategoryPage = routeName.startsWith('/category/');
    final showSearch = title == null || isCategoryPage;
    final iMat = context.watch<ImatDataHandler>();
    final actions = <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: _ProfileCircleButton(
          onTap: () => Navigator.pushNamed(context, '/user'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: _CartSummaryButton(
          iMat: context.watch<ImatDataHandler>(),
          onTap: () => showShoppingCartOverlay(context),
        ),
      ),
    ];

    return AppBar(
      toolbarHeight: 110,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 120,
      titleSpacing: 16,
      title: showSearch
          ? SearchBarWidget(
              iMat: iMat,
              padding: EdgeInsets.zero,
              onSearchSubmitted: isCategoryPage
                  ? (_) {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainView()),
                        (route) => false,
                      );
                    }
                  : null,
            )
          : Text(title!),
      leading: SizedBox(
        width: 120,
        child: InkWell(
          onTap: () {
            // Reset selection/search and navigate to main page like a normal navigation
            FocusScope.of(context).unfocus();
            final iMat = Provider.of<ImatDataHandler>(context, listen: false);
            iMat.selectAllProducts();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MainView()),
              (route) => false,
            );
          },
          child: Center(
            child: Image.asset(
              'assets/images/imatlogo.png',
              fit: BoxFit.contain,
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/placeholder.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110);
}

class _ProfileCircleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileCircleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD9CDF7),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.person, size: 32, color: Color(0xFF2E2E34)),
        ),
      ),
    );
  }
}

class _CartSummaryButton extends StatelessWidget {
  final ImatDataHandler iMat;
  final VoidCallback onTap;

  const _CartSummaryButton({required this.iMat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cart = iMat.getShoppingCart();
    final total = iMat.shoppingCartTotal();
    final itemCount = cart.items.fold<double>(0, (sum, item) => sum + item.amount);

    return Material(
      color: const Color(0xFF5A2DD0),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 30, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                '${total.toStringAsFixed(0)} kr',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6DEF9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  itemCount.toInt().toString(),
                  style: const TextStyle(
                    color: Color(0xFF2E2E34),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
