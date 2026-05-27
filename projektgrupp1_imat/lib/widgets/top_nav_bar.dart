import 'package:flutter/material.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/shopping_cart_overlay.dart';
import 'package:imat_app/widgets/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/pages/main_view.dart';
import 'package:imat_app/pages/search_results.dart';

const double topNavBarProfileLabelTextSize = 18.0; // 1.2x of base 15.0
const double topNavBarCartTotalTextSize = 20.0;
const double topNavBarCartCountTextSize = 16.0;
const double topNavBarTitleTextSize = 18.0;

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final double? searchBarWidth;
  final double itemSpacing;
  static const double serviceFee = 25.0;
  static const double defaultSearchBarWidth = 1420.0;

  const TopNavBar({this.title, this.searchBarWidth, this.itemSpacing = 16.0, super.key});

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name ?? '';
    final isCategoryPage = routeName.startsWith('/category/');
    final showSearch = title == null || isCategoryPage;
    final iMat = context.watch<ImatDataHandler>();

    return AppBar(
      toolbarHeight: 110,
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      centerTitle: false,
      leading: const SizedBox.shrink(),
      actions: const [],
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _LogoButton(onTap: () {
              FocusScope.of(context).unfocus();
              final iMat = Provider.of<ImatDataHandler>(context, listen: false);
              iMat.selectAllProducts();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const MainView()),
                (route) => false,
              );
            }),
            SizedBox(width: itemSpacing),
            Flexible(
              fit: FlexFit.loose,
              child: SizedBox(
                width: searchBarWidth ?? defaultSearchBarWidth,
                child: showSearch
                    ? SearchBarWidget(
                        iMat: iMat,
                        padding: EdgeInsets.zero,
                        width: searchBarWidth ?? defaultSearchBarWidth,
                        onSearchSubmitted: (query) {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SearchResultsPage()),
                          );
                        },
                      )
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title!,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: topNavBarTitleTextSize, fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
            ),
            SizedBox(width: itemSpacing),
            _ProfileCircleButton(
              onTap: () => Navigator.pushNamed(context, '/user'),
            ),
            SizedBox(width: itemSpacing),
            _CartSummaryButton(
              iMat: iMat,
              onTap: () => showShoppingCartOverlay(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(110);
}

class _LogoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: InkWell(
        onTap: onTap,
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
    );
  }
}

class _ProfileCircleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ProfileCircleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final handler = Provider.of<ImatDataHandler>(context);
    final isLoggedIn = handler.getUser().userName.isNotEmpty;
    // Prefer to show the customer's first name under the profile icon.
    // Fallback to the userName (username/email) and finally 'Logga in'.
    final customer = handler.getCustomer();
    final user = handler.getUser();
    final displayName = customer.firstName.isNotEmpty
      ? customer.firstName
      : (user.userName.isNotEmpty ? user.userName : 'Logga in');

    // Visual: top = circular lavender avatar, bottom = rectangular label
    // that looks like a button. Functionally both are one tappable area.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoggedIn ? onTap : () => Navigator.pushNamed(context, '/login'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular avatar (visual button)
            Material(
              color: const Color(0xFFD9CDF7),
              shape: const CircleBorder(),
              child: SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.person, size: 32, color: const Color(0xFF2E2E34)),
              ),
            ),
            const SizedBox(height: 8),
            // Rectangular label (visual separate button) but inside same InkWell
            Container(
              width: 78,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD9CDF7), // same lavender as avatar
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD9CDF7)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                displayName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: topNavBarProfileLabelTextSize, fontWeight: FontWeight.w500, color: Color(0xFF2E2E34)),
              ),
            ),
          ],
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
                  fontSize: topNavBarCartTotalTextSize,
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
                    fontSize: topNavBarCartCountTextSize,
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
