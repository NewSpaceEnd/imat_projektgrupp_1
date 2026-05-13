import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/widgets/primary_action_button.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:provider/provider.dart';

class ShoppingCartPage extends StatelessWidget {
	static const double serviceFee = 25.0;

	const ShoppingCartPage({super.key});

	@override
	Widget build(BuildContext context) {
		final iMat = context.watch<ImatDataHandler>();
		final cart = iMat.getShoppingCart();
		final cartTotal = iMat.shoppingCartTotal();
		final totalWithService = cartTotal + (cart.items.isEmpty ? 0 : serviceFee);

			    return Scaffold(
				    appBar: TopNavBar(title: 'Varukorg'),
			body: Padding(
				padding: const EdgeInsets.all(AppTheme.paddingSmall),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Expanded(
							child: cart.items.isEmpty
									? const Center(child: Text('Din varukorg är tom'))
									: ListView.builder(
											itemCount: cart.items.length,
											itemBuilder: (context, index) {
												final item = cart.items[index];
												return _CartItem(
													item: item,
													onIncrease: () => iMat.shoppingCartUpdate(item, delta: 1.0),
													onDecrease: () => iMat.shoppingCartUpdate(item, delta: -1.0),
													onRemove: () => iMat.shoppingCartRemove(item),
												);
											},
										),
						),
						Card(
							color: const Color(0xFFF3F6FB),
							child: Padding(
								padding: const EdgeInsets.all(16),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.stretch,
									children: [
										const Text(
											'Summering',
											style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
										),
										const SizedBox(height: 8),
										Text('Varor: ${cart.items.length}'),
										Text('Varor totalt: ${cartTotal.toStringAsFixed(2)} kr'),
										Text('Serviceavgift: ${(cart.items.isEmpty ? 0 : serviceFee).toStringAsFixed(2)} kr'),
										const Divider(),
										Text('Att betala: ${totalWithService.toStringAsFixed(2)} kr'),
										const SizedBox(height: 16),
										SizedBox(
											width: double.infinity,
											child: PrimaryActionButton(
												onPressed: cart.items.isEmpty
													? null
													: () => Navigator.pushNamed(context, '/checkout'),
												icon: Icons.payment,
												label: 'Gå till kassan',
											),
										),
									],
								),
							),
						),
					],
				),
			),
		);
	}
}

class _CartItem extends StatelessWidget {
	final ShoppingItem item;
	final VoidCallback onIncrease;
	final VoidCallback onDecrease;
	final VoidCallback onRemove;

	const _CartItem({
		required this.item,
		required this.onIncrease,
		required this.onDecrease,
		required this.onRemove,
	});

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.symmetric(vertical: 6),
			child: ListTile(
				leading: SizedBox(
					width: 56,
					height: 56,
					child: ClipRRect(
						borderRadius: BorderRadius.circular(6),
						child: Builder(builder: (context) {
							final iMat = Provider.of<ImatDataHandler>(context, listen: false);
							return iMat.getImage(item.product);
						}),
					),
				),
				title: Text(item.product.name),
				subtitle: Text('Antal: ${item.amount.toStringAsFixed(1)}'),
				trailing: SizedBox(
					width: 140,
					child: Row(
						mainAxisAlignment: MainAxisAlignment.end,
						children: [
							IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove)),
							Text('${item.amount.toStringAsFixed(1)}'),
							IconButton(onPressed: onIncrease, icon: const Icon(Icons.add)),
							IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
						],
					),
				),
			),
		);
	}
}
