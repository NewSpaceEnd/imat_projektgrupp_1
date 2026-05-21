// Profilsida som visar:
// - Användarens personlig information (namn, email, telefon, adress, etc.)
// - Sparade varukorgar (hämtade från servern)
// - Köphistorik - alla ordrar för inloggad användare (hämtade från servern)
// - Utloggning-knapp
//
// Om användaren inte är inloggad, redirectar vi till huvudsidan.

import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/credit_card.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/model/imat/order.dart';
import 'package:imat_app/model/imat/saved_shopping_cart.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/pages/main_view.dart';
import 'package:imat_app/util/date_formatter.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:imat_app/widgets/primary_action_button.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final handler = context.watch<ImatDataHandler>();
    final customer = handler.getCustomer();
    final creditCard = handler.getCreditCard();
    final loggedIn = handler.getUser().userName.isNotEmpty;

    if (!loggedIn) {
      return const MainView();
    }

    return Scaffold(
      appBar: const TopNavBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useStackedLayout = constraints.maxWidth < 980;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: useStackedLayout
                ? Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: _ProfileSidebar(
                          onOrdersTap: () => _showOrders(context, handler),
                          onSavedCartsTap: () => _showSavedCarts(context),
                          onLogout: () {
                            handler.logout();
                            Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _ProfileContent(
                          customer: customer,
                          creditCard: creditCard,
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 190,
                        child: _ProfileSidebar(
                          onOrdersTap: () => _showOrders(context, handler),
                          onSavedCartsTap: () => _showSavedCarts(context),
                          onLogout: () {
                            handler.logout();
                            Navigator.pushReplacementNamed(context, '/');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ProfileContent(
                          customer: customer,
                          creditCard: creditCard,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  /// Visar dialog med alla sparade varukorgar för inloggad användare
  /// Hämtar sparade varukorgar från servern
  /// Användaren kan:
  /// - Se varje sparad varukorg med namn och datum
  /// - Klicka "lägg till i varukorgen" för att återställa en sparad varukorg
  /// - Klicka "Ta bort" för att ta bort en sparad varukorg
  void _showSavedCarts(BuildContext context) {
    final handler = context.read<ImatDataHandler>();

    // Fetch saved carts directly from server (no local cache)
    Future<List<Map<String, dynamic>>> loader() async {
      return await handler.fetchSavedShoppingCartsFromServer();
    }

    showDialog<void>(
      context: context,
      builder: (context) => FutureBuilder<List<Map<String, dynamic>>>(
        future: loader(),
        builder: (context, snapshot) {
          final aggregated = <Map<String, dynamic>>[];
          if (snapshot.hasData) {
            aggregated.addAll(snapshot.data!);
            aggregated.sort((a, b) {
              try {
                final aDate = DateTime.parse((a['cart'] as Map)['savedAt'] as String);
                final bDate = DateTime.parse((b['cart'] as Map)['savedAt'] as String);
                return bDate.compareTo(aDate);
              } catch (_) {
                return 0;
              }
            });
          }

          return AlertDialog(
            title: const Text('Sparade varukorgar'),
            content: snapshot.connectionState != ConnectionState.done
                ? const SizedBox(width: 200, height: 80, child: Center(child: CircularProgressIndicator()))
                : aggregated.isEmpty
                    ? const Text('Inga sparade varukorgar.')
                    : SizedBox(
                        width: double.maxFinite,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: aggregated.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final entry = aggregated[index];
                            final map = entry['cart'] as Map<String, dynamic>;
                            final owner = entry['owner'] as String;
                            final cart = SavedShoppingCart.fromJson(map);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SavedCartCard(
                                  savedCart: cart,
                                  onRestore: () {
                                    context.read<ImatDataHandler>().addSavedShoppingCartToShoppingCart(cart);
                                    Navigator.pop(context);
                                    // Snackbar intentionally removed per user preference.
                                  },
                                  onDelete: () async {
                                    context.read<ImatDataHandler>().removeSavedShoppingCart(cart.name);
                                    Navigator.pop(context);
                                    _showSavedCarts(context);
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text('Sparad av: $owner', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: PrimaryActionButton(
                  label: 'Stäng',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
      ),
    );

    
  }

  /// Visar dialog med köphistorik (alla ordrar) för inloggad användare
  /// Hämtar ordrar från servern sorterade från nyaste till äldsta
  /// Visar för varje order:
  /// - Ordernummer
  /// - Orderdatum
  /// - Total belopp
  void _showOrders(BuildContext context, ImatDataHandler handler) async {
    final orders = await handler.getAllOrders();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Köphistorik'),
        content: orders.isEmpty
            ? const Text('Inga ordrar hittades.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.separated(
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
                        // Snackbar intentionally removed per user preference.
                      },
                      onPrint: () => _showOrderAction(
                        context,
                        'Utskrift',
                        'Det här är ett exempel på att skicka ordern till skrivaren.',
                      ),
                      onEmail: () => _showOrderAction(
                        context,
                        'E-post',
                        'Det här är ett exempel på att skicka ordern via e-post.',
                      ),
                      onFax: () => _showOrderAction(
                        context,
                        'Fax',
                        'Det här är ett exempel på att faxa orderkvitto.',
                      ),
                    );
                  },
                ),
              ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: PrimaryActionButton(
              label: 'Stäng',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderAction(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          SizedBox(
            width: double.infinity,
            child: PrimaryActionButton(
              label: 'OK',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSidebar extends StatelessWidget {
  final VoidCallback onOrdersTap;
  final VoidCallback onSavedCartsTap;
  final VoidCallback onLogout;

  const _ProfileSidebar({
    required this.onOrdersTap,
    required this.onSavedCartsTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Mina Sidor',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _ProfileMenuItem(label: 'Köphistorik', onTap: onOrdersTap),
          _ProfileMenuItem(label: 'Sparade varukorgar', onTap: onSavedCartsTap),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logga ut'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final Customer customer;
  final CreditCard creditCard;

  const _ProfileContent({required this.customer, required this.creditCard});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _mobilePhoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _postAddressController = TextEditingController();
  final _cardTypeController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardMonthController = TextEditingController();
  final _cardYearController = TextEditingController();
  final _cardCvcController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _syncFromCustomer();
  }

  @override
  void didUpdateWidget(covariant _ProfileContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing) {
      _syncFromCustomer();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _mobilePhoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _postCodeController.dispose();
    _postAddressController.dispose();
    _cardTypeController.dispose();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _cardMonthController.dispose();
    _cardYearController.dispose();
    _cardCvcController.dispose();
    super.dispose();
  }

  void _syncFromCustomer() {
    _firstNameController.text = widget.customer.firstName;
    _lastNameController.text = widget.customer.lastName;
    _phoneNumberController.text = widget.customer.phoneNumber;
    _mobilePhoneNumberController.text = widget.customer.mobilePhoneNumber;
    _emailController.text = widget.customer.email;
    _addressController.text = widget.customer.address;
    _postCodeController.text = widget.customer.postCode;
    _postAddressController.text = widget.customer.postAddress;
    _cardTypeController.text = widget.creditCard.cardType;
    _cardHolderController.text = widget.creditCard.holdersName;
    _cardNumberController.text = widget.creditCard.cardNumber;
    _cardMonthController.text = widget.creditCard.validMonth.toString();
    _cardYearController.text = widget.creditCard.validYear.toString();
    _cardCvcController.text = widget.creditCard.verificationCode.toString();
  }

  Future<void> _saveCustomer() async {
    final handler = context.read<ImatDataHandler>();
    final updatedCustomer = Customer(
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      _phoneNumberController.text.trim(),
      _mobilePhoneNumberController.text.trim(),
      _emailController.text.trim(),
      _addressController.text.trim(),
      _postCodeController.text.trim(),
      _postAddressController.text.trim(),
    );
    final updatedCard = CreditCard(
      _cardTypeController.text.trim(),
      _cardHolderController.text.trim(),
      int.tryParse(_cardMonthController.text.trim()) ?? 1,
      int.tryParse(_cardYearController.text.trim()) ?? 26,
      _cardNumberController.text.trim(),
      int.tryParse(_cardCvcController.text.trim()) ?? 0,
    );

    await handler.setCustomer(updatedCustomer);
    await handler.setCreditCard(updatedCard);
    if (!mounted) return;

    setState(() => _isEditing = false);
    // Snackbar intentionally removed per user preference.
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isEditing ? Colors.white : const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isEditing ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
          width: _isEditing ? 2 : 1,
        ),
        boxShadow: _isEditing
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTextField(
                              controller: _firstNameController,
                              label: 'Förnamn',
                              enabled: _isEditing,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileTextField(
                              controller: _lastNameController,
                              label: 'Efternamn',
                              enabled: _isEditing,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTextField(
                              controller: _emailController,
                              label: 'E-post',
                              enabled: _isEditing,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileTextField(
                              controller: _phoneNumberController,
                              label: 'Telefonnummer',
                              enabled: _isEditing,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTextField(
                              controller: _mobilePhoneNumberController,
                              label: 'Mobilnummer',
                              enabled: _isEditing,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileTextField(
                              controller: _addressController,
                              label: 'Adress',
                              enabled: _isEditing,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTextField(
                              controller: _postCodeController,
                              label: 'Postnummer',
                              enabled: _isEditing,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileTextField(
                              controller: _postAddressController,
                              label: 'Postort',
                              enabled: _isEditing,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Kortinformation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTextField(
                              controller: _cardTypeController,
                              label: 'Korttyp',
                              enabled: _isEditing,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileTextField(
                              controller: _cardHolderController,
                              label: 'Kortinnehavare',
                              enabled: _isEditing,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTextField(
                              controller: _cardNumberController,
                              label: 'Kortnummer',
                              enabled: _isEditing,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileTextField(
                              controller: _cardCvcController,
                              label: 'CVC',
                              enabled: _isEditing,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTextField(
                              controller: _cardMonthController,
                              label: 'Giltig månad',
                              enabled: _isEditing,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProfileTextField(
                              controller: _cardYearController,
                              label: 'Giltigt år',
                              enabled: _isEditing,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        width: 205,
                        height: 205,
                        decoration: BoxDecoration(
                          color: _isEditing ? const Color(0xFFE8E0FF) : const Color(0xFFBCA9F7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, size: 138, color: Color(0xFF2E3236)),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 160,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _isEditing = !_isEditing),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isEditing ? const Color(0xFFE2D7FF) : const Color(0xFFBCA9F7),
                              foregroundColor: const Color(0xFF2E2E34),
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              _isEditing ? 'Avbryt' : 'Redigera\ninformation',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              softWrap: true,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.0),
                            ),
                          ),
                        ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 160,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _saveCustomer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5F38D1),
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text(
                                'Spara information',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputType? keyboardType;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.enabled,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          readOnly: !enabled,
          keyboardType: keyboardType,
          style: TextStyle(
            color: enabled ? Colors.black87 : Colors.black87,
            fontWeight: enabled ? FontWeight.w400 : FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF1F1F1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: enabled ? const Color(0xFFB7B7B7) : const Color(0xFFA9A9A9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: enabled ? const Color(0xFFB7B7B7) : const Color(0xFFA9A9A9)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFA9A9A9)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }
}

class _OrderExpansionCard extends StatefulWidget {
  final Order order;
  final VoidCallback onBuyAgain;
  final VoidCallback onPrint;
  final VoidCallback onEmail;
  final VoidCallback onFax;

  const _OrderExpansionCard({
    required this.order,
    required this.onBuyAgain,
    required this.onPrint,
    required this.onEmail,
    required this.onFax,
  });

  @override
  State<_OrderExpansionCard> createState() => _OrderExpansionCardState();
}

class _OrderExpansionCardState extends State<_OrderExpansionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        onExpansionChanged: (value) => setState(() => _expanded = value),
        title: Text('Order #${widget.order.orderNumber}'),
        subtitle: Text('${formatOrderDate(widget.order.date)} • ${widget.order.items.length} varor'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...widget.order.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item.product.name)),
                        Text('${item.amount.toStringAsFixed(2)} ${item.product.unit}'),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.onBuyAgain,
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Köp igen'),
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.onPrint,
                      icon: const Icon(Icons.print),
                      label: const Text('Skriv ut'),
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.onEmail,
                      icon: const Icon(Icons.email),
                      label: const Text('E-post'),
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.onFax,
                      icon: const Icon(Icons.fax),
                      label: const Text('Fax'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget som visar en enskild sparad varukorg i ett Card
/// Visar:
/// - Namn på varukorgen
/// - Antal varor och sparat-datum
/// - "Ta bort" och "lägg till i varukorgen" knappar
/// - Vilken användare som sparade den (ägare)
class _SavedCartCard extends StatelessWidget {
  final SavedShoppingCart savedCart;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _SavedCartCard({
    required this.savedCart,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(savedCart.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${savedCart.cart.items.length} varor • Sparad ${formatOrderDate(savedCart.savedAt)}'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDelete,
                    child: const Text('Ta bort'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRestore,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                    child: const Text('lägg till i varukorgen', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
