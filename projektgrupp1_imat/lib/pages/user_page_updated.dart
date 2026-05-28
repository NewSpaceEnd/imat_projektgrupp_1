// Profilsida som visar:
// - Användarens personliga information
// - Sparade varukorgar
// - Köphistorik
// - Utloggning

import 'package:flutter/material.dart';
import 'package:imat_app/model/imat/credit_card.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/model/imat/order.dart';
import 'package:imat_app/model/imat/saved_shopping_cart.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/pages/main_view.dart';
import 'package:imat_app/util/date_formatter.dart';
import 'package:imat_app/widgets/primary_action_button.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:imat_app/widgets/product_detail_dialog.dart';
import 'package:imat_app/widgets/shopping_cart_overlay.dart';
import 'package:provider/provider.dart';

const double userPageSavedByTextSize = 12.0;
const double userPageSidebarTitleTextSize = 22.0;
const double userPageMenuItemTextSize = 16.0;
const double userPageCardSectionTitleTextSize = 16.0;
const double userPageSaveButtonTextSize = 15.0;
const double userPageSavedCartNameTextSize = 16.0;
const double userPageProfileFieldLabelTextSize = 16.0;
const double userPageProfileFieldTextSize = 19.0;
const double userPageProfileFieldCornerRadius = 10.0;
const EdgeInsets userPageProfileFieldContentPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 10);

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
                      Expanded(child: _ProfileContent(customer: customer, creditCard: creditCard)),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 245,
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
                      Expanded(child: _ProfileContent(customer: customer, creditCard: creditCard)),
                    ],
                  ),
          );
        },
      ),
    );
  }

  void _showSavedCarts(BuildContext context) {
    final pageContext = context;
    final handler = context.read<ImatDataHandler>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: handler.fetchSavedShoppingCartsFromServer(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const AlertDialog(
                title: Text('Sparade varukorgar'),
                content: SizedBox(
                  width: 200,
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final carts = List<Map<String, dynamic>>.from(snapshot.data ?? const []);
            carts.sort((a, b) {
              try {
                final aDate = DateTime.parse((a['cart'] as Map<String, dynamic>)['savedAt'] as String);
                final bDate = DateTime.parse((b['cart'] as Map<String, dynamic>)['savedAt'] as String);
                return bDate.compareTo(aDate);
              } catch (_) {
                return 0;
              }
            });

            return AlertDialog(
              title: const Text('Sparade varukorgar'),
              content: carts.isEmpty
                  ? const Text('Inga sparade varukorgar.')
                  : SizedBox(
                      width: double.maxFinite,
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: carts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = carts[index];
                          final cartData = entry['cart'] as Map<String, dynamic>;
                          final owner = entry['owner'] as String;
                          final savedCart = SavedShoppingCart.fromJson(cartData);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SavedCartCard(
                                savedCart: savedCart,
                                onRestore: () {
                                  final handler = context.read<ImatDataHandler>();
                                  final isLoggedIn = handler.getUser().userName.isNotEmpty;
                                  if (isLoggedIn) {
                                    handler.addSavedShoppingCartToShoppingCart(savedCart);
                                    Navigator.pop(context);
                                    // Open the shopping cart side panel to provide visual feedback
                                    Future.microtask(() => showShoppingCartOverlay(pageContext));
                                    return;
                                  }

                                  showDialog<void>(
                                    context: context,
                                    builder: (ctx) => Center(
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 900),
                                        child: AlertDialog(
                                          title: Text('Logga in rekommenderas', style: TextStyle(fontSize: productDetailUpdatedBlockTitleTextSize, fontWeight: FontWeight.bold)),
                                          content: Text('Du är inte inloggad. Vill du logga in för att spara dina köp under din profil? Du kan fortsätta utan inloggning, men då sparas inga köp under din profil.', style: TextStyle(fontSize: productDetailUpdatedBlockValueTextSize)),
                                          actions: [
                                            TextButton(
                                              style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                                              onPressed: () => Navigator.of(ctx).pop(),
                                              child: Text('Avbryt', style: TextStyle(fontSize: productDetailUpdatedChipTextSize)),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                                              onPressed: () {
                                                      // remember user's choice and continue without login
                                                      handler.setSuppressLoginPrompt(true);
                                                      handler.addSavedShoppingCartToShoppingCart(savedCart);
                                                      Navigator.of(ctx).pop();
                                                      Navigator.pop(context);
                                                      Future.microtask(() => showShoppingCartOverlay(pageContext));
                                                    },
                                              child: Text('Fortsätt utan inloggning', style: TextStyle(fontSize: productDetailUpdatedChipTextSize)),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                                Navigator.pop(context);
                                                Navigator.pushNamed(context, '/login');
                                              },
                                              child: Text('Logga in', style: TextStyle(fontSize: productDetailUpdatedChipTextSize)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  context.read<ImatDataHandler>().removeSavedShoppingCart(savedCart.name);
                                  Navigator.pop(context);
                                  _showSavedCarts(context);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Sparad av: $owner',
                                  style: const TextStyle(fontSize: userPageSavedByTextSize, color: Colors.black54),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: PrimaryActionButton(label: 'Stäng', onPressed: () => Navigator.pop(dialogContext)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showOrders(BuildContext context, ImatDataHandler handler) async {
    final orders = await handler.getAllOrders();
    if (!context.mounted) return;
    final pageContext = context;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
                      onBuyAgain: () {
                        final handler = context.read<ImatDataHandler>();
                        final isLoggedIn = handler.getUser().userName.isNotEmpty;
                        if (isLoggedIn) {
                          handler.addOrderToShoppingCart(order);
                          Navigator.pop(context);
                          Future.microtask(() => showShoppingCartOverlay(pageContext));
                          return;
                        }

                        showDialog<void>(
                          context: context,
                          builder: (ctx) => Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: AlertDialog(
                                title: Text('Logga in rekommenderas', style: TextStyle(fontSize: productDetailUpdatedBlockTitleTextSize, fontWeight: FontWeight.bold)),
                                content: Text('Du är inte inloggad. Vill du logga in för att spara dina köp under din profil? Du kan fortsätta utan inloggning, men då sparas inga köp under din profil.', style: TextStyle(fontSize: productDetailUpdatedBlockValueTextSize)),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text('Avbryt', style: TextStyle(fontSize: productDetailUpdatedChipTextSize)),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                                    onPressed: () {
                                      // remember user's choice and continue without login
                                      handler.setSuppressLoginPrompt(true);
                                      handler.addOrderToShoppingCart(order);
                                      Navigator.of(ctx).pop();
                                      Navigator.pop(context);
                                      Future.microtask(() => showShoppingCartOverlay(pageContext));
                                    },
                                    child: Text('Fortsätt utan inloggning', style: TextStyle(fontSize: productDetailUpdatedChipTextSize)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      Navigator.pop(context);
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    child: Text('Logga in', style: TextStyle(fontSize: productDetailUpdatedChipTextSize)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      onPrint: () => _showOrderAction(context, 'Utskrift', 'Det här är ett exempel på att skriva ut orderkvitto.'),
                      onEmail: () => _showOrderAction(context, 'E-post', 'Det här är ett exempel på att skicka ordern via e-post.'),
                      onFax: () => _showOrderAction(context, 'Fax', 'Det här är ett exempel på att faxa orderkvitto.'),
                    );
                  },
                ),
              ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: PrimaryActionButton(label: 'Stäng', onPressed: () => Navigator.pop(dialogContext)),
          ),
        ],
      ),
    );
  }

  void _showOrderAction(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          SizedBox(
            width: double.infinity,
            child: PrimaryActionButton(label: 'OK', onPressed: () => Navigator.of(dialogContext).pop()),
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
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7F2FF), Color(0xFFE9E2FF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBFA8FF), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 22, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.dashboard_rounded, color: Color(0xFF5F38D1), size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mina sidor',
                        style: TextStyle(fontSize: userPageSidebarTitleTextSize, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ProfileMenuItem(label: 'Köphistorik', icon: Icons.receipt_long_rounded, onTap: onOrdersTap),
          const SizedBox(height: 8),
          _ProfileMenuItem(label: 'Sparade varukorgar', icon: Icons.shopping_bag_rounded, onTap: onSavedCartsTap),
          const SizedBox(height: 14),
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
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileMenuItem({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF5F38D1), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: userPageMenuItemTextSize, fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.black45, size: 20),
            ],
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

  bool _hasPendingChanges = false;

  @override
  void initState() {
    super.initState();
    _syncFromCustomer();
    _registerListeners();
  }

  @override
  void didUpdateWidget(covariant _ProfileContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasPendingChanges) {
      _syncFromCustomer();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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

  void _registerListeners() {
    for (final controller in [
      _firstNameController,
      _lastNameController,
      _mobilePhoneNumberController,
      _emailController,
      _addressController,
      _postCodeController,
      _postAddressController,
      _cardTypeController,
      _cardHolderController,
      _cardNumberController,
      _cardMonthController,
      _cardYearController,
      _cardCvcController,
    ]) {
      controller.addListener(_updateDirtyState);
    }
  }

  void _syncFromCustomer() {
    _firstNameController.text = widget.customer.firstName;
    _lastNameController.text = widget.customer.lastName;
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

  void _updateDirtyState() {
    final hasChanges =
        _firstNameController.text != widget.customer.firstName ||
        _lastNameController.text != widget.customer.lastName ||
        _mobilePhoneNumberController.text != widget.customer.mobilePhoneNumber ||
        _emailController.text != widget.customer.email ||
        _addressController.text != widget.customer.address ||
        _postCodeController.text != widget.customer.postCode ||
        _postAddressController.text != widget.customer.postAddress ||
        _cardTypeController.text != widget.creditCard.cardType ||
        _cardHolderController.text != widget.creditCard.holdersName ||
        _cardNumberController.text != widget.creditCard.cardNumber ||
        _cardMonthController.text != widget.creditCard.validMonth.toString() ||
        _cardYearController.text != widget.creditCard.validYear.toString() ||
        _cardCvcController.text != widget.creditCard.verificationCode.toString();

    if (hasChanges != _hasPendingChanges && mounted) {
      setState(() => _hasPendingChanges = hasChanges);
    }
  }

  Future<void> _saveCustomer() async {
    final handler = context.read<ImatDataHandler>();

    final updatedCustomer = Customer(
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
      '',
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

    setState(() => _hasPendingChanges = false);
    _syncFromCustomer();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _hasPendingChanges ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
          width: _hasPendingChanges ? 2 : 1,
        ),
        boxShadow: _hasPendingChanges
            ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 18, offset: const Offset(0, 8))]
            : null,
      ),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: _ProfileTextField(controller: _firstNameController, label: 'Förnamn', enabled: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _ProfileTextField(controller: _lastNameController, label: 'Efternamn', enabled: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _ProfileTextField(controller: _emailController, label: 'E-post', enabled: true, keyboardType: TextInputType.emailAddress)),
                      const SizedBox(width: 12),
                      Expanded(child: _ProfileTextField(controller: _mobilePhoneNumberController, label: 'Mobilnummer', enabled: true, keyboardType: TextInputType.phone)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ProfileTextField(controller: _addressController, label: 'Adress', enabled: true),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _ProfileTextField(controller: _postCodeController, label: 'Postnummer', enabled: true, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _ProfileTextField(controller: _postAddressController, label: 'Postort', enabled: true)),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Kortinformation',
                    style: TextStyle(fontSize: userPageCardSectionTitleTextSize, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _ProfileTextField(controller: _cardTypeController, label: 'Korttyp', enabled: true)),
                      const SizedBox(width: 12),
                      Expanded(child: _ProfileTextField(controller: _cardHolderController, label: 'Kortinnehavare', enabled: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _ProfileTextField(controller: _cardNumberController, label: 'Kortnummer', enabled: true, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _ProfileTextField(controller: _cardCvcController, label: 'CVC', enabled: true, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _ProfileTextField(controller: _cardMonthController, label: 'Giltig månad', enabled: true, keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: _ProfileTextField(controller: _cardYearController, label: 'Giltigt år', enabled: true, keyboardType: TextInputType.number)),
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
                  const SizedBox(height: 20),
                  Container(
                    width: 205,
                    height: 205,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasPendingChanges ? const Color(0xFFE8E0FF) : const Color(0xFFBCA9F7),
                    ),
                    child: const Icon(Icons.person, size: 138, color: Color(0xFF2E3236)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 170,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _hasPendingChanges ? _saveCustomer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _hasPendingChanges ? const Color(0xFF5F38D1) : const Color(0xFFE0E0E0),
                        foregroundColor: _hasPendingChanges ? Colors.white : Colors.black54,
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        disabledForegroundColor: Colors.black54,
                        elevation: _hasPendingChanges ? 3 : 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Spara information',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: userPageSaveButtonTextSize, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
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
        Text(
          label,
          style: const TextStyle(fontSize: userPageProfileFieldLabelTextSize, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          readOnly: !enabled,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: userPageProfileFieldTextSize, color: Colors.black87, fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF1F1F1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(userPageProfileFieldCornerRadius),
              borderSide: BorderSide(color: enabled ? const Color(0xFFB7B7B7) : const Color(0xFFA9A9A9)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(userPageProfileFieldCornerRadius),
              borderSide: BorderSide(color: enabled ? const Color(0xFFB7B7B7) : const Color(0xFFA9A9A9)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(userPageProfileFieldCornerRadius),
              borderSide: const BorderSide(color: Color(0xFFA9A9A9)),
            ),
            contentPadding: userPageProfileFieldContentPadding,
          ),
        ),
      ],
    );
  }
}

class _OrderExpansionCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final handler = context.read<ImatDataHandler>();
    final orderTotal = order.items.fold<double>(0.0, (sum, it) => sum + it.amount * handler.displayPrice(it.product));
    return Card(
      child: ExpansionTile(
        title: Text('Order #${order.orderNumber}'),
        subtitle: Text('${formatOrderDate(order.date)} • ${order.items.length} varor'),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: order.items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final item = order.items[idx];
                      return Container(
                        width: 150,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: context.read<ImatDataHandler>().getImage(item.product),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('Antal: ${item.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text(
                              '${handler.displayPrice(item.product).toStringAsFixed(2)} kr',
                              style: TextStyle(fontSize: 14, color: handler.isOnSale(item.product) ? Colors.red : Colors.black),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Totalt: ${orderTotal.toStringAsFixed(2)} kr', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onBuyAgain,
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Köp igen'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                    ),
                    ElevatedButton.icon(onPressed: onPrint, icon: const Icon(Icons.print), label: const Text('Skriv ut')),
                    ElevatedButton.icon(onPressed: onEmail, icon: const Icon(Icons.email), label: const Text('E-post')),
                    ElevatedButton.icon(onPressed: onFax, icon: const Icon(Icons.fax), label: const Text('Fax')),
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
            Text(savedCart.name, style: const TextStyle(fontSize: userPageSavedCartNameTextSize, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${savedCart.cart.items.length} varor • Sparad ${formatOrderDate(savedCart.savedAt)}'),
            const SizedBox(height: 10),
            if (savedCart.cart.items.isNotEmpty) ...[
              SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: savedCart.cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final item = savedCart.cart.items[idx];
                    return Container(
                      width: 150,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 1,
                                  child: context.watch<ImatDataHandler>().getImage(item.product),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('Antal: ${item.amount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(
                            '${context.watch<ImatDataHandler>().displayPrice(item.product).toStringAsFixed(2)} kr',
                            style: TextStyle(fontSize: 14, color: context.watch<ImatDataHandler>().isOnSale(item.product) ? Colors.red : Colors.black),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
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