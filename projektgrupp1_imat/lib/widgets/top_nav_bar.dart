import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/pages/main_view.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const TopNavBar({this.title, super.key});

  @override
  Widget build(BuildContext context) {
    // Use provider only for possible future extensions; actions navigate via context
    // final iMat = Provider.of<ImatDataHandler>(context, listen: false);

    return AppBar(
      toolbarHeight: 110,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 120,
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
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            tooltip: 'Användare',
            icon: const Icon(Icons.person_outline, size: 50),
            onPressed: () => Navigator.pushNamed(context, '/user'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            tooltip: 'Varukorg',
            icon: const Icon(Icons.shopping_cart_outlined, size: 50),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: IconButton(
            tooltip: 'Kassa',
            icon: const Icon(Icons.receipt_long_outlined, size: 50),
            onPressed: () => Navigator.pushNamed(context, '/checkout'),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
