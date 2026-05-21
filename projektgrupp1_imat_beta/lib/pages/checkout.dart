import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/credit_card.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/primary_action_button.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> with TickerProviderStateMixin {
  static const double serviceFee = 25.0;

  int _currentStep = 0;
  late AnimationController _animationController;
  bool _cartSaved = false;

  final _formKey = GlobalKey<FormState>();
  final _savedCartName = TextEditingController();

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
    _animationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);

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
    _animationController.dispose();

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
    _savedCartName.dispose();

    super.dispose();
  }

  void _saveCurrentCart() {
    final iMat = Provider.of<ImatDataHandler>(context, listen: false);
    if (iMat.getShoppingCart().items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Det finns ingen varukorg att spara.')));
      return;
    }

    final name = _savedCartName.text.trim().isEmpty ? 'Varukorg' : _savedCartName.text.trim();
    iMat.saveShoppingCart(name);
    // Feedback via button color; no SnackBar shown.
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

  Future<void> _placeOrder(ImatDataHandler iMat) async {
    if (!_formKey.currentState!.validate()) return;

    if (iMat.getShoppingCart().items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lägg till minst en vara innan du slutför köp.')));
      return;
    }

    final customer = Customer(
      _firstName.text,
      _lastName.text,
      _phone.text,
      '',
      _email.text,
      _address.text,
      _postCode.text,
      _postAddress.text,
    );

    await iMat.setCustomer(customer);

    final card = CreditCard(
      '',
      _cardHolder.text,
      int.tryParse(_validMonth.text) ?? 0,
      int.tryParse(_validYear.text) ?? 0,
      _cardNumber.text,
      int.tryParse(_verification.text) ?? 0,
    );

    await iMat.setCreditCard(card);

    try {
      await iMat.placeOrder();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/order-confirmation');
      }
    } catch (e) {
      // Error: keep user on page and optionally set local UI state if needed.
      if (mounted) {
        // TODO: show inline error message if desired. For now do nothing to avoid pop-up.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final iMat = Provider.of<ImatDataHandler>(context);
    final cart = iMat.getShoppingCart();
    final cartTotal = iMat.shoppingCartTotal();
    final totalWithService = cartTotal + (cart.items.isEmpty ? 0 : serviceFee);

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: const TopNavBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Lägg till minst en vara innan du går till kassan.', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryActionButton(onPressed: () => Navigator.pushReplacementNamed(context, '/cart'), label: 'Till varukorgen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const TopNavBar(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.paddingSmall),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress Indicator
                  _buildProgressIndicator(),
                  const SizedBox(height: 24),

                  // Steps area
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: _buildStepContent(_currentStep, iMat, cartTotal, totalWithService),
                  ),

                  const SizedBox(height: 24),

                  // Navigation Buttons
                  Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => setState(() => _currentStep--),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Tillbaka'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400], foregroundColor: Colors.black),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: _currentStep == 3
                            ? const SizedBox.shrink()
                            : ElevatedButton.icon(
                                onPressed: () => setState(() => _currentStep++),
                                label: const Text('Nästa'),
                                icon: const Icon(Icons.arrow_forward),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _checkoutInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF7F9FE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1E6AF0), width: 1.6)),
    );
  }

  Widget _buildStepCard({required Key key, required Widget child}) {
    return Card(
      key: key,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 240), child: child),
      ),
    );
  }

  Future<void> _showSaveDialog(ImatDataHandler iMat) async {
    final items = iMat.getShoppingCart().items;
    if (items.isEmpty) return;

    final nameCtrl = TextEditingController();
    final selected = List<bool>.filled(items.length, true);

    bool saved = false;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return _buildSaveCartDialog(
            context: context,
            iMat: iMat,
            items: items,
            nameCtrl: nameCtrl,
            selected: selected,
            saved: saved,
            setSaved: (value) {
              setState(() => saved = value);
            },
            onSaved: () {
              // Update parent state to show green button
              if (mounted) {
                this.setState(() => _cartSaved = true);
              }
            },
          );
        });
      },
    );
  }

  Widget _buildSaveCartDialog({
    required BuildContext context,
    required ImatDataHandler iMat,
    required List<ShoppingItem> items,
    required TextEditingController nameCtrl,
    required List<bool> selected,
    required bool saved,
    required Function(bool) setSaved,
    required VoidCallback onSaved,
  }) {
    return StatefulBuilder(builder: (context, setState) {
      final media = MediaQuery.of(context).size;
      return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: media.width * 0.08, vertical: media.height * 0.03),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              width: media.width * 0.75,
              height: media.height * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Spara varukorg', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Namn på sparad varukorg')),
                    const SizedBox(height: 12),
                    const Text('Välj varor att spara', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),

                    // Select / Deselect all button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            final all = selected.every((v) => v);
                            setState(() {
                              for (var idx = 0; idx < selected.length; idx++) selected[idx] = !all;
                            });
                          },
                          child: Text(selected.every((v) => v) ? 'Avmarkera alla' : 'Välj alla'),
                        ),
                      ],
                    ),

                    Expanded(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: LayoutBuilder(builder: (ctx, constraints) {
                          const maxItemWidth = 220.0;
                          final crossAxisCount = (constraints.maxWidth / maxItemWidth).floor().clamp(1, 6);
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: items.length,
                            itemBuilder: (ctx, i) {
                              final prod = items[i].product;
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Center(child: AspectRatio(aspectRatio: 1, child: iMat.getImage(prod))),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Checkbox(value: selected[i], onChanged: (v) => setState(() => selected[i] = v ?? false)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(prod.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Avbryt')),
                        const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: saved
                                  ? null
                                  : () async {
                                      final name = nameCtrl.text.trim().isEmpty ? 'Sparad varukorg' : nameCtrl.text.trim();
                                      final selectedItems = <ShoppingItem>[];
                                      for (var i = 0; i < items.length; i++) {
                                        if (selected[i]) selectedItems.add(ShoppingItem(items[i].product, amount: items[i].amount));
                                      }

                                      if (selectedItems.length == items.length) {
                                        await iMat.saveShoppingCart(name);
                                      } else {
                                        await iMat.saveShoppingCartWithItems(name, selectedItems);
                                      }

                                      // Visuell feedback: gör knappen grön och ändra text, stäng dialogen efter kort fördröjning
                                      setSaved(true);
                                      onSaved();
                                      final navigator = Navigator.of(context);
                                      await Future.delayed(const Duration(milliseconds: 700));
                                      if (mounted) navigator.pop();
                                    },
                              style: ElevatedButton.styleFrom(backgroundColor: saved ? Colors.green : const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                              child: Text(saved ? 'Sparad' : 'Spara'),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildProgressIndicator() {
    const steps = ['Personlig info', 'Adress', 'Betalning', 'Sammanfattning'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(steps.length, (index) {
            final isCompleted = index < _currentStep;
            final isActive = index == _currentStep;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? const Color(0xFF8B5CF6) : isCompleted ? Colors.green : Colors.grey[300],
                    ),
                    child: Center(
                      child: isCompleted ? const Icon(Icons.check, color: Colors.white) : Text('${index + 1}', style: TextStyle(color: isActive || isCompleted ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(steps[index], textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepContent(int step, ImatDataHandler iMat, double cartTotal, double totalWithService) {
    switch (step) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildAddressStep();
      case 2:
        return _buildPaymentStep();
      case 3:
        return _buildReviewStep(iMat, cartTotal, totalWithService);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalInfoStep() {
    return _buildStepCard(
      key: const ValueKey(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Personlig information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(controller: _firstName, decoration: _checkoutInputDecoration('Förnamn'), validator: (v) => (v == null || v.isEmpty) ? 'Förnamn krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _lastName, decoration: _checkoutInputDecoration('Efternamn'), validator: (v) => (v == null || v.isEmpty) ? 'Efternamn krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _email, decoration: _checkoutInputDecoration('E-post'), validator: (v) => (v == null || v.isEmpty) ? 'E-post krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _phone, decoration: _checkoutInputDecoration('Telefon'), validator: (v) => (v == null || v.isEmpty) ? 'Telefon krävs' : null),
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return _buildStepCard(
      key: const ValueKey(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Leveransadress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(controller: _address, decoration: _checkoutInputDecoration('Adress'), validator: (v) => (v == null || v.isEmpty) ? 'Adress krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _postCode, decoration: _checkoutInputDecoration('Postnummer'), validator: (v) => (v == null || v.isEmpty) ? 'Postnummer krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _postAddress, decoration: _checkoutInputDecoration('Stad'), validator: (v) => (v == null || v.isEmpty) ? 'Stad krävs' : null),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return _buildStepCard(
      key: const ValueKey(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Betalningsinformation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(controller: _cardHolder, decoration: _checkoutInputDecoration('Korthavarens namn'), validator: (v) => (v == null || v.isEmpty) ? 'Korthavarens namn krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _cardNumber, decoration: _checkoutInputDecoration('Kortnummer'), validator: (v) => (v == null || v.isEmpty) ? 'Kortnummer krävs' : null),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(controller: _validMonth, decoration: _checkoutInputDecoration('MM'), validator: (v) => (v == null || v.isEmpty) ? 'MM krävs' : null)),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _validYear, decoration: _checkoutInputDecoration('YY'), validator: (v) => (v == null || v.isEmpty) ? 'YY krävs' : null)),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _verification, decoration: _checkoutInputDecoration('CVC'), validator: (v) => (v == null || v.isEmpty) ? 'CVC krävs' : null)),
          ]),
        ],
      ),
    );
  }

  Widget _buildReviewStep(ImatDataHandler iMat, double cartTotal, double totalWithService) {
    final itemCount = iMat.getShoppingCart().items.fold<int>(0, (sum, item) => sum + item.amount.toInt());
    return _buildStepCard(
      key: const ValueKey(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Sammanfattning', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black)),
          const SizedBox(height: 16),

          LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 700;
            final leftCard = Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReviewSection('Personlig information', [
                      '${_firstName.text} ${_lastName.text}',
                      _email.text,
                      _phone.text,
                    ]),
                    const SizedBox(height: 12),
                    _buildReviewSection('Leveransadress', [
                      _address.text,
                      '${_postCode.text} ${_postAddress.text}',
                    ]),
                    const SizedBox(height: 12),
                    _buildReviewSection('Betalning', [
                      _cardHolder.text,
                      '•••• •••• •••• ${_cardNumber.text.length >= 4 ? _cardNumber.text.substring(_cardNumber.text.length - 4) : _cardNumber.text}',
                    ]),
                  ],
                ),
              ),
            );

            final rightCard = Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 220,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: iMat.getShoppingCart().items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, idx) {
                      final it = iMat.getShoppingCart().items[idx];
                      final prod = it.product;
                      return SizedBox(
                        height: 72,
                        child: Row(
                          children: [
                            AspectRatio(aspectRatio: 1, child: ClipRRect(borderRadius: BorderRadius.circular(6), child: iMat.getImage(prod))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(prod.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 6),
                                  Text('Antal: ${it.amount.toInt()}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${(prod.price * it.amount).toStringAsFixed(2)} kr', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: leftCard),
                  const SizedBox(width: 12),
                  Expanded(flex: 1, child: rightCard),
                ],
              );
            }

            return Column(children: [leftCard, const SizedBox(height: 12), rightCard]);
          }),

          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Antal varor:', style: const TextStyle(fontSize: 15, color: Colors.black)),
            Text(itemCount.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
          ]),

          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Subtotal:', style: const TextStyle(fontSize: 15, color: Colors.black)),
            Text('${cartTotal.toStringAsFixed(2)} kr', style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600)),
          ]),

          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Leveransavgift:', style: const TextStyle(fontSize: 15, color: Colors.black)),
            Text('${serviceFee.toStringAsFixed(0)} kr', style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w600)),
          ]),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Totalt:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black)),
            Text('${totalWithService.toStringAsFixed(2)} kr', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black)),
          ]),

          const SizedBox(height: 12),
          Text('Totalt antal varor: ${itemCount.toString()}', style: const TextStyle(fontSize: 14, color: Colors.black)),
          const SizedBox(height: 12),

          // Buttons beneath both boxes
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showSaveDialog(iMat),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cartSaved ? Colors.green : const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.save),
                label: Text(_cartSaved ? 'Sparad' : 'Spara varukorg'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: PrimaryActionButton(onPressed: iMat.getShoppingCart().items.isEmpty ? null : () => _placeOrder(iMat), icon: Icons.check_circle_outline, label: 'Slutför köp')),
          ]),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
      const SizedBox(height: 8),
      ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500)))).toList(),
    ]);
  }
}
