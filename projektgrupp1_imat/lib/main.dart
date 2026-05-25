import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/pages/main_view.dart';
import 'package:imat_app/pages/favorites_view.dart';
import 'package:imat_app/pages/checkout.dart';
import 'package:imat_app/pages/shopping_cart.dart';
import 'package:imat_app/pages/user_page_updated.dart';
import 'package:imat_app/pages/order_confirmation.dart';
import 'package:imat_app/pages/login_page.dart';
import 'package:imat_app/pages/register_page.dart';
import 'package:imat_app/pages/category_view.dart';
import 'package:imat_app/pages/special_offers_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ImatDataHandler(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iMat - Projekgrupp 1',
      theme: ThemeData(colorScheme: AppTheme.colorScheme),
      home: const MainView(),
      routes: {
        '/user': (_) => const UserPage(),
        '/cart': (_) => const ShoppingCartPage(),
        '/checkout': (_) => const CheckoutPage(),
        '/favorites': (_) => const FavoritesPage(),
        '/order-confirmation': (_) => const OrderConfirmationPage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/offers': (_) => const SpecialOffersPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/category/') ?? false) {
          final parts = settings.name!.split('/');
          final title = parts[2];
          final categoryName = parts[3];
          final category = ProductCategory.values.firstWhere(
            (c) => c.toString() == 'ProductCategory.$categoryName',
            orElse: () => ProductCategory.UNDEFINED,
          );
          return MaterialPageRoute(
            builder: (_) => CategoryView(title: Uri.decodeComponent(title), category: category),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
