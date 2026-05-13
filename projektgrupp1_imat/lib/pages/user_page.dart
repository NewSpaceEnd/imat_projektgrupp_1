import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/order.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/util/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';

class UserPage extends StatelessWidget {
	const UserPage({super.key});

	@override
	Widget build(BuildContext context) {
		final handler = context.watch<ImatDataHandler>();
		final loggedIn = handler.getUser().userName.isNotEmpty;

		return Scaffold(
			appBar: TopNavBar(title: 'Min användare'),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(AppTheme.paddingSmall),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Container(
							padding: const EdgeInsets.all(24),
							decoration: BoxDecoration(
								gradient: const LinearGradient(
									colors: [Color(0xFF1D3557), Color(0xFF457B9D)],
									begin: Alignment.topLeft,
									end: Alignment.bottomRight,
								),
								borderRadius: BorderRadius.circular(20),
							),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									const CircleAvatar(
										radius: 28,
										backgroundColor: Colors.white,
										child: Icon(Icons.person, color: Color(0xFF1D3557), size: 32),
									),
									const SizedBox(height: 16),
									Text(
										loggedIn ? handler.getUser().userName : 'Demo-användare',
										style: const TextStyle(
											color: Colors.white,
											fontSize: 24,
											fontWeight: FontWeight.bold,
										),
									),
									const SizedBox(height: 8),
									Text(
										loggedIn
												? 'Välkommen tillbaka!'
												: 'Profilvy för att hantera konto, adresser och inställningar.',
										style: const TextStyle(color: Colors.white70),
									),
								],
							),
						),
						const SizedBox(height: 20),
						if (!loggedIn) ...[
							ElevatedButton(
								onPressed: () => Navigator.pushNamed(context, '/login'),
								child: const Text('Logga in'),
							),
							TextButton(
								onPressed: () => Navigator.pushNamed(context, '/register'),
								child: const Text('Skapa konto'),
							),
						],
						if (loggedIn) ...[
							_ActionTile(
								icon: Icons.badge_outlined,
								title: 'Kontoinformation',
								subtitle: 'Visa namn, e-post och telefonnummer',
								onTap: () => _showAccountInfo(context, handler),
							),
							_ActionTile(
								icon: Icons.location_on_outlined,
								title: 'Leveransadresser',
								subtitle: 'Gå till kassan och ändra adressuppgifter',
								onTap: () => Navigator.pushNamed(context, '/checkout'),
							),
							_ActionTile(
								icon: Icons.receipt_long_outlined,
								title: 'Tidigare beställningar',
								subtitle: 'Visa dina senaste ordrar',
								onTap: () => _showOrders(context, handler),
							),
							const SizedBox(height: 10),
							ElevatedButton(
								onPressed: () {
									context.read<ImatDataHandler>().logout();
									ScaffoldMessenger.of(context).showSnackBar(
										const SnackBar(content: Text('Utloggad')),
									);
								},
								child: const Text('Logga ut'),
							),
						],
					],
				),
			),
		);
	}

	void _showAccountInfo(BuildContext context, ImatDataHandler handler) {
		final user = handler.getUser();
		final customer = handler.getCustomer();

		showDialog<void>(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: const Text('Kontoinformation'),
					content: Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text('Användarnamn: ${user.userName}'),
							const SizedBox(height: 8),
							Text('Namn: ${customer.firstName} ${customer.lastName}'),
							const SizedBox(height: 8),
							Text('E-post: ${customer.email}'),
							const SizedBox(height: 8),
							Text('Telefon: ${customer.phoneNumber.isNotEmpty ? customer.phoneNumber : customer.mobilePhoneNumber}'),
						],
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.pop(context),
							child: const Text('Stäng'),
						),
					],
				);
			},
		);
	}

	void _showOrders(BuildContext context, ImatDataHandler handler) {
		final orders = handler.orders;

		showDialog<void>(
			context: context,
			builder: (context) {
				return AlertDialog(
					title: const Text('Tidigare beställningar'),
					content: SizedBox(
						width: double.maxFinite,
						height: 420,
						child: orders.isEmpty
								? const Center(child: Text('Inga ordrar hittades.'))
								: ListView.separated(
										shrinkWrap: true,
										itemCount: orders.length,
										separatorBuilder: (_, __) => const SizedBox(height: 12),
										itemBuilder: (context, index) {
											final order = orders[index];
											return _OrderExpansionCard(
												order: order,
												onBuyAgain: () async {
													await context.read<ImatDataHandler>().addOrderToShoppingCart(order);
													if (!context.mounted) return;
													Navigator.pop(context);
													ScaffoldMessenger.of(context).showSnackBar(
														const SnackBar(content: Text('Varorna lades till i kundvagnen')),
													);
												},
												onPrint: () => _showOrderAction(context, 'Utskrift', 'Det här är ett exempel på att skicka ordern till skrivaren.'),
												onEmail: () => _showOrderAction(context, 'E-post', 'Det här är ett exempel på att skicka ordern via e-post.'),
												onFax: () => _showOrderAction(context, 'Fax', 'Det här är ett exempel på att faxa orderkvitto.'),
											);
										},
									),
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.pop(context),
							child: const Text('Stäng'),
						),
					],
				);
			},
		);
	}

	void _showOrderAction(BuildContext context, String title, String message) {
		showDialog<void>(
			context: context,
			builder: (context) => AlertDialog(
				title: Text(title),
				content: Text(message),
				actions: [
					TextButton(
						onPressed: () => Navigator.of(context).pop(),
						child: const Text('OK'),
					),
				],
			),
		);
	}
}

class _OrderExpansionCard extends StatelessWidget {
	final Order order;
	final VoidCallback onPrint;
	final VoidCallback onEmail;
	final VoidCallback onFax;
	final VoidCallback onBuyAgain;

	const _OrderExpansionCard({
		required this.order,
		required this.onPrint,
		required this.onEmail,
		required this.onFax,
		required this.onBuyAgain,
	});

	@override
	Widget build(BuildContext context) {
		return Card(
			child: ExpansionTile(
				title: Text('Order ${order.orderNumber}'),
				subtitle: Text('${formatOrderDate(order.date)} • ${order.items.length} varor • ${order.getTotal().toStringAsFixed(2)} kr'),
				childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
				children: [
					const Divider(height: 1),
					const SizedBox(height: 12),
					...order.items.map(
						(item) => Padding(
							padding: const EdgeInsets.only(bottom: 10),
							child: Row(
								children: [
									SizedBox(
										width: 56,
										height: 56,
										child: ClipRRect(
											borderRadius: BorderRadius.circular(10),
											child: context.read<ImatDataHandler>().getImage(item.product),
										),
									),
									const SizedBox(width: 12),
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
												Text('Antal: ${item.amount.toStringAsFixed(0)} • Pris: ${item.product.price.toStringAsFixed(2)} kr'),
											],
										),
									),
									Text('${item.total.toStringAsFixed(2)} kr'),
								],
							),
						),
					),
					const Divider(),
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							const Text('Totalt', style: TextStyle(fontWeight: FontWeight.bold)),
							Text('${order.getTotal().toStringAsFixed(2)} kr', style: const TextStyle(fontWeight: FontWeight.bold)),
						],
					),
					const SizedBox(height: 12),
					Wrap(
						spacing: 10,
						runSpacing: 10,
						children: [
							ElevatedButton.icon(
								onPressed: onPrint,
								icon: const Icon(Icons.print),
								label: const Text('Skriv ut'),
							),
							OutlinedButton.icon(
								onPressed: onEmail,
								icon: const Icon(Icons.email_outlined),
								label: const Text('Maila'),
							),
							OutlinedButton.icon(
								onPressed: onFax,
								icon: const Icon(Icons.fax),
								label: const Text('Faxa'),
							),
							OutlinedButton.icon(
								onPressed: onBuyAgain,
								icon: const Icon(Icons.add_shopping_cart_outlined),
								label: const Text('Köp igen'),
							),
						],
					),
				],
			),
		);
	}
}

class _ActionTile extends StatelessWidget {
	final IconData icon;
	final String title;
	final String subtitle;
	final VoidCallback onTap;

	const _ActionTile({
		required this.icon,
		required this.title,
		required this.subtitle,
		required this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.only(bottom: 12),
			child: ListTile(
				onTap: onTap,
				leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
				title: Text(title),
				subtitle: Text(subtitle),
				trailing: const Icon(Icons.chevron_right),
			),
		);
	}
}
