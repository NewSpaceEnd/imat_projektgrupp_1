import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:imat_app/model/imat/credit_card.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/internet_handler.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
	const CheckoutPage({super.key});

	@override
	State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
	final _formKey = GlobalKey<FormState>();

	// Customer controllers
	late TextEditingController _firstName;
	late TextEditingController _lastName;
	late TextEditingController _email;
	late TextEditingController _phone;
	late TextEditingController _address;
	late TextEditingController _postCode;
	late TextEditingController _postAddress;

	// Card controllers
	late TextEditingController _cardHolder;
	late TextEditingController _cardNumber;
	late TextEditingController _validMonth;
	late TextEditingController _validYear;
	late TextEditingController _verification;

	bool _initialized = false;

	@override
	void initState() {
		super.initState();
		_firstName = TextEditingController();
		_lastName = TextEditingController();
		_email = TextEditingController();
		_phone = TextEditingController();
		_address = TextEditingController();
		_postCode = TextEditingController();
		_postAddress = TextEditingController();

		_cardHolder = TextEditingController();
		_cardNumber = TextEditingController();
		_validMonth = TextEditingController();
		_validYear = TextEditingController();
		_verification = TextEditingController();
	}

	@override
	void dispose() {
		_firstName.dispose();
		_lastName.dispose();
		_email.dispose();
		_phone.dispose();
		_address.dispose();
		_postCode.dispose();
		_postAddress.dispose();

		_cardHolder.dispose();
		_cardNumber.dispose();
		_validMonth.dispose();
		_validYear.dispose();
		_verification.dispose();
		super.dispose();
	}

	@override
	void didChangeDependencies() {
		super.didChangeDependencies();
		if (!_initialized) {
			final iMat = Provider.of<ImatDataHandler>(context, listen: false);
			final cust = iMat.getCustomer();
			_firstName.text = cust.firstName;
			_lastName.text = cust.lastName;
			_email.text = cust.email;
			_phone.text = cust.mobilePhoneNumber.isNotEmpty ? cust.mobilePhoneNumber : cust.phoneNumber;
			_address.text = cust.address;
			_postCode.text = cust.postCode;
			_postAddress.text = cust.postAddress;

			final card = iMat.getCreditCard();
			_cardHolder.text = card.holdersName;
			_cardNumber.text = card.cardNumber;
			_validMonth.text = card.validMonth.toString();
			_validYear.text = card.validYear.toString();
			_verification.text = card.verificationCode.toString();

			_initialized = true;
		}
	}

	Future<void> _placeOrder() async {
		if (!_formKey.currentState!.validate()) return;

		final iMat = Provider.of<ImatDataHandler>(context, listen: false);

		final customer = Customer(
			_firstName.text,
			_lastName.text,
			_phone.text,
			_phone.text,
			_email.text,
			_address.text,
			_postCode.text,
			_postAddress.text,
		);

		final card = CreditCard(
			'CARD',
			_cardHolder.text,
			int.tryParse(_validMonth.text) ?? 1,
			int.tryParse(_validYear.text) ?? 24,
			_cardNumber.text,
			int.tryParse(_verification.text) ?? 0,
		);

		try {
			// Save customer and card to server (await to ensure server has latest data)
			await InternetHandler.setCustomer(customer);
			await InternetHandler.setCreditCard(card);

			// Persist current shopping cart for this user on the server
			await InternetHandler.setShoppingCart(iMat.getShoppingCart());

			// Place the order (server reads the shopping cart tied to the user)
			await iMat.placeOrder();

			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Beställning genomförd')));
			Navigator.pushReplacementNamed(context, '/order-confirmation');
		} catch (e) {
			if (!mounted) return;
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fel: $e')));
		}
	}

	@override
	Widget build(BuildContext context) {
		final iMat = Provider.of<ImatDataHandler>(context);
		final cart = iMat.getShoppingCart();

		return Scaffold(
			appBar: TopNavBar(title: 'Kassa'),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(AppTheme.paddingSmall),
				child: Form(
					key: _formKey,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.stretch,
						children: [
							const Text('Varukorg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
							const SizedBox(height: 8),
							...cart.items.map((ShoppingItem item) {
								return Card(
									margin: const EdgeInsets.symmetric(vertical: 6),
									child: ListTile(
										leading: SizedBox(width: 56, height: 56, child: iMat.getImage(item.product)),
										title: Text(item.product.name),
										subtitle: Text('${item.amount} ${item.product.unit}'),
										trailing: Text('${item.total.toStringAsFixed(2)} kr'),
									),
								);
							}).toList(),
							const SizedBox(height: 12),
							Card(
								child: Padding(
									padding: const EdgeInsets.all(12),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.stretch,
										children: [
											const Text('Leveransinformation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
											const SizedBox(height: 8),
											TextFormField(controller: _firstName, decoration: const InputDecoration(labelText: 'Förnamn')),
											TextFormField(controller: _lastName, decoration: const InputDecoration(labelText: 'Efternamn')),
											TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'E-post')),
											TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Telefon')),
											TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Adress')),
											TextFormField(controller: _postCode, decoration: const InputDecoration(labelText: 'Postnummer')),
											TextFormField(controller: _postAddress, decoration: const InputDecoration(labelText: 'Stad')),
										],
									),
								),
							),
							const SizedBox(height: 12),
							Card(
								child: Padding(
									padding: const EdgeInsets.all(12),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.stretch,
										children: [
											const Text('Betalningsinformation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
											const SizedBox(height: 8),
											TextFormField(controller: _cardHolder, decoration: const InputDecoration(labelText: 'Korthavarens namn')),
											TextFormField(controller: _cardNumber, decoration: const InputDecoration(labelText: 'Kortnummer')),
											Row(
												children: [
													Expanded(child: TextFormField(controller: _validMonth, decoration: const InputDecoration(labelText: 'MM'))),
													const SizedBox(width: 8),
													Expanded(child: TextFormField(controller: _validYear, decoration: const InputDecoration(labelText: 'YY'))),
													const SizedBox(width: 8),
													Expanded(child: TextFormField(controller: _verification, decoration: const InputDecoration(labelText: 'CVC'))),
												],
											),
										],
									),
								),
							),
							const SizedBox(height: 12),
							Card(
								child: Padding(
									padding: const EdgeInsets.all(12),
									child: Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: [
											const Text('Totalt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
											Text('${iMat.shoppingCartTotal().toStringAsFixed(2)} kr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
										],
									),
								),
							),
							const SizedBox(height: 12),
							ElevatedButton.icon(
								onPressed: _placeOrder,
								icon: const Icon(Icons.check_circle_outline),
								label: const Text('Slutför köp'),
							),
						],
					),
				),
			),
		);
	}
}
