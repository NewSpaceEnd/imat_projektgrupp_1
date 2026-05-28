import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/credit_card.dart';
import 'package:imat_app/model/imat/customer.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/widgets/primary_action_button.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:provider/provider.dart';

// Text sizes used across the checkout flow.
const double checkoutStepLabelTextSize = 22.0; // Size for the text under each progress step at the top.
const double checkoutSectionTitleTextSize = 25.0; // Size for the section headings like "Personlig information".
const double checkoutSummaryTitleTextSize = 25.0; // Size for the summary title on the review page.
const double checkoutEmptyStateTextSize = 20.0; // Text size for the empty-cart message.
const double checkoutSaveCartButtonTextSize = 20.0; // Text size for the save-cart button.
const double checkoutNavButtonTextSize = 20.0; // Text size for the navigation buttons like "Tillbaka" and "Nästa".
const double checkoutStepperNumberTextSize = 20.0; // Number text size inside the stepper circles.
const double checkoutSelectAllButtonTextSize = 18.0; // Text size for "Välj alla" / "Avmarkera alla".

// Text sizes for checkout inputs and labels.
const double checkoutInputTextSize = 32.0; // Text size for the actual typed input inside all checkout fields.
const double checkoutInputLabelTextSize = 32.0; // Label / placeholder text size for checkout input fields.
const double checkoutDialogFieldLabelTextSize = 28.0; // Label size for the name field in the save-cart dialog.

// Text sizes for the save-cart dialog.
const double checkoutSaveCartTitleTextSize = 30.0; // Title size for the "Spara varukorg" dialog.
const double checkoutSaveCartSectionTextSize = 20.0; // Section title size inside the save-cart dialog.
const double checkoutDialogButtonTextSize = 20.0; // Text size for cancel/save buttons inside the save-cart dialog.

// Review step text sizes.
const double checkoutReviewProductNameTextSize = 25.0; // Product name size in the review list.
const double checkoutReviewQuantityTextSize = 20.0; // Quantity text size in the review list.
const double checkoutReviewPriceTextSize = 25.0; // Price text size in the review list.
const double checkoutSummaryLabelTextSize = 25.0; // Label size for summary rows like "Antal varor" and "Subtotal".
const double checkoutSummaryValueTextSize = 25.0; // Value size for summary rows like item count and subtotal.
const double checkoutSummaryTotalLabelTextSize = 28.0; // Label size for the final total row.
const double checkoutSummaryTotalValueTextSize = 28.0; // Value size for the final total row.
const double checkoutSummaryFooterTextSize = 20.0; // Footer text size for the total-items line.
const double checkoutReviewSectionTitleTextSize = 20.0; // Title size for each review section in the summary card.
const double checkoutReviewSectionItemTextSize = 20.0; // Item text size inside each review section.

// Layout and sizing constants.
const double checkoutMainIconSize = 200.0; // Size for the empty-cart icon.
const double checkoutNavIconSize = 20.0; // Size for the icons in the navigation buttons.
const double checkoutButtonMinHeight = 48.0; // Minimum height for the navigation buttons.
const double checkoutBoxMinHeight = 480.0; // Minimum height for each checkout step card.
const double checkoutInputHorizontalPadding = 20.0; // Horizontal padding inside checkout input fields.
const double checkoutInputVerticalPadding = 40.0; // Vertical padding inside checkout input fields.

// Summary step spacing and layout controls.
const double checkoutReviewHorizontalPadding = 0.0; // Horizontal outer padding for the summary step.
const double checkoutReviewVerticalPadding = 20.0; // Vertical outer padding for the summary step.
const double checkoutReviewCardGap = 12.0; // Gap between the three summary cards.
const double checkoutReviewCardInnerPadding = 12.0; // Padding inside the summary cards.
const double checkoutReviewListHeight = 220.0; // Height of the items list in the middle card.
const double checkoutReviewLineItemHeight = 72.0; // Height of each product row in the middle card.
const double checkoutReviewImageRadius = 6.0; // Rounded corner radius for product images in the middle card.
const double checkoutReviewSummaryButtonGap = 10.0; // Gap between buttons in the right card.
const double checkoutReviewWideBreakpoint = 700.0; // Width threshold for switching to horizontal summary cards.
const double checkoutReviewSectionGap = 12.0; // Gap between sections inside the left summary card.
const double checkoutReviewRightCardGapSmall = 8.0; // Small gap between summary rows in the right card.
const double checkoutReviewSummaryDividerGap = 12.0; // Gap around the divider in the right card.

/// Kassasida med 4-stegs checkout-flow:
/// Steg 0: Personlig info (förnamn, efternamn, email, telefon)
/// Steg 1: Leveransadress (adress, postnummer, stad)
/// Steg 2: Betalningsinformation (kortinnehåller, kortnummer, MM/YY, CVC)
/// Steg 3: Sammanfattning (granska och slutför köp)
///
/// Hämtar kundinformation från kundregistret och förifylls med sparad data.
/// Vid slutförande sparas info och placerar order via InternetHandler.
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> with TickerProviderStateMixin {
  static const double serviceFee = 25.0; // Fast avgift för leverans

  int _currentStep = 0; // Aktuellt steg i checkout-flödet (0-3)
  late AnimationController _animationController; // För steg-övergångar
  // The saved-state is now stored in ImatDataHandler and observed via
  // `iMat.isCurrentCartSaved()` so we don't keep a separate local flag here.
  final _stepKeys = List.generate(4, (_) => GlobalKey<FormState>());

  final _formKey = GlobalKey<FormState>(); // Form-validering för alla input
  final _savedCartName = TextEditingController(); // Namn på sparad varukorg (om sparning)

  // TextEditingControllers för kundinformation
  late TextEditingController _firstName;
  late TextEditingController _lastName;
  late TextEditingController _email;
  late TextEditingController _phone; // Telefonnummer för leverans
  late TextEditingController _address;
  late TextEditingController _postCode;
  late TextEditingController _postAddress;

  // TextEditingControllers för kreditkortsinformation
  late TextEditingController _cardHolder;
  late TextEditingController _cardNumber;
  late TextEditingController _validMonth;
  late TextEditingController _validYear;
  late TextEditingController _verification; // CVC-kod

  bool _initialized = false; // Flag för att ladda data från kundregistret en gång

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
      // Snackbar intentionally removed per user preference; simply return.
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
    if (!_stepKeys[3].currentState!.validate()) return;

    if (iMat.getShoppingCart().items.isEmpty) {
      // Snackbar intentionally removed per user preference; keep user on page.
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

  // Kärnlayouten för kassan byggs här: tomvagn, stegvy och navigation.
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
                const Icon(Icons.shopping_cart_outlined, size: checkoutMainIconSize, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('Lägg till minst en vara innan du går till kassan.', textAlign: TextAlign.center, style: TextStyle(fontSize: checkoutEmptyStateTextSize)),
                const SizedBox(height: 12),
                LayoutBuilder(builder: (context, constraints) {
                  final double btnWidth = constraints.maxWidth > 380 ? 340 : constraints.maxWidth * 0.9;
                  return SizedBox(
                    width: btnWidth,
                    height: 58,
                    child: PrimaryActionButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/cart'),
                      label: 'Till varukorgen',
                      textSize: checkoutSaveCartButtonTextSize,
                    ),
                  );
                }),
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
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.paddingSmall,
          vertical: _currentStep == 3 ? checkoutReviewVerticalPadding : AppTheme.paddingSmall,
        ),
        child: _currentStep == 3
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProgressIndicator(),
                  const SizedBox(height: 24),
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
                ],
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
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
                                icon: const Icon(Icons.arrow_back, size: checkoutNavIconSize),
                                label: const Text('Tillbaka', style: TextStyle(fontSize: checkoutNavButtonTextSize)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size.fromHeight(checkoutButtonMinHeight),
                                  textStyle: const TextStyle(fontSize: checkoutNavButtonTextSize),
                                ),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Validate current step before advancing
                                final valid = _stepKeys[_currentStep].currentState?.validate() ?? true;
                                if (!valid) return;
                                if (_currentStep < 3) setState(() => _currentStep++);
                              },
                              label: const Text('Nästa', style: TextStyle(fontSize: checkoutNavButtonTextSize)),
                              icon: const Icon(Icons.arrow_forward, size: checkoutNavIconSize),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(checkoutButtonMinHeight),
                                textStyle: const TextStyle(fontSize: checkoutNavButtonTextSize),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Hjälpare för alla checkout-inputfält så text, label och dekor hålls samlad.
  InputDecoration _checkoutInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: checkoutInputLabelTextSize),
      floatingLabelStyle: const TextStyle(fontSize: checkoutInputLabelTextSize),
      filled: true,
      fillColor: const Color(0xFFF7F9FE),
      contentPadding: const EdgeInsets.symmetric(horizontal: checkoutInputHorizontalPadding, vertical: checkoutInputVerticalPadding),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1E6AF0), width: 1.6)),
    );
  }

  TextStyle _checkoutInputStyle() {
    return const TextStyle(fontSize: checkoutInputTextSize, color: Colors.black87);
  }

  // Gemensam kortbehållare för varje steg i checkout-flödet.
  Widget _buildStepCard({required Key key, required Widget child}) {
    return Card(
      key: key,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(constraints: const BoxConstraints(minHeight: checkoutBoxMinHeight), child: child),
      ),
    );
  }

  // Spara varukorg-dialogen är samlad här eftersom den hör till samma funktionella klump.
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
            onSaved: () {},
          );
        });
      },
        // Själva dialoglayouten för att spara varukorgen.
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
                    const Text('Spara varukorg', style: TextStyle(fontSize: checkoutSaveCartTitleTextSize, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Namn på sparad varukorg', labelStyle: const TextStyle(fontSize: checkoutDialogFieldLabelTextSize))),
                    const SizedBox(height: 12),
                    const Text('Välj varor att spara', style: TextStyle(fontSize: checkoutSaveCartSectionTextSize, fontWeight: FontWeight.w600)),
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
                          child: Text(selected.every((v) => v) ? 'Avmarkera alla' : 'Välj alla', style: const TextStyle(fontSize: checkoutSelectAllButtonTextSize)),
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
                                            child: Text(prod.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: checkoutReviewSectionItemTextSize, fontWeight: FontWeight.w600)),
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
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Avbryt', style: TextStyle(fontSize: checkoutDialogButtonTextSize))),
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
                              style: ElevatedButton.styleFrom(backgroundColor: saved ? Colors.green : const Color(0xFF8B5CF6), foregroundColor: Colors.white, textStyle: const TextStyle(fontSize: checkoutSaveCartButtonTextSize)),
                              child: Text(saved ? 'Sparad' : 'Spara', style: const TextStyle(fontSize: checkoutSaveCartButtonTextSize)),
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

        // Progress-steget högst upp i checkouten.
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
                      child: isCompleted ? const Icon(Icons.check, color: Colors.white) : Text('${index + 1}', style: TextStyle(fontSize: checkoutStepperNumberTextSize, color: isActive || isCompleted ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(steps[index], textAlign: TextAlign.center, style: TextStyle(fontSize: checkoutStepLabelTextSize, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // Växlar mellan de fyra checkout-stegen.
  Widget _buildStepContent(int step, ImatDataHandler iMat, double cartTotal, double totalWithService) {
    Widget content;
    switch (step) {
      case 0:
        content = _buildPersonalInfoStep();
        break;
      case 1:
        content = _buildAddressStep();
        break;
      case 2:
        content = _buildPaymentStep();
        break;
      case 3:
        try {
          content = _buildReviewStep(iMat, cartTotal, totalWithService);
        } catch (e, st) {
          debugPrint('Checkout review build error: $e');
          debugPrint('$st');
          content = _buildStepCard(
            key: const ValueKey(999),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Fel i sammanfattningen', style: TextStyle(fontSize: checkoutSummaryTitleTextSize, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const Text('Ett internt fel uppstod när sammanfattningen byggdes. Du kan gå tillbaka och försöka igen.'),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () => setState(() => _currentStep = (_currentStep > 0 ? _currentStep - 1 : 0)), child: const Text('Tillbaka')),
              ],
            ),
          );
        }
        break;
      default:
        content = const SizedBox();
    }

    return Form(key: _stepKeys[step], child: content);
  }

  // Steg 0: kundens egna uppgifter.
  Widget _buildPersonalInfoStep() {
    return _buildStepCard(
      key: const ValueKey(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Personlig information', style: TextStyle(fontSize: checkoutSectionTitleTextSize, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(controller: _firstName, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('Förnamn'), validator: (v) => (v == null || v.isEmpty) ? 'Förnamn krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _lastName, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('Efternamn'), validator: (v) => (v == null || v.isEmpty) ? 'Efternamn krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _email, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('E-post'), validator: (v) => (v == null || v.isEmpty) ? 'E-post krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _phone, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('Telefon'), validator: (v) => (v == null || v.isEmpty) ? 'Telefon krävs' : null),
        ],
      ),
    );
  }

  // Steg 1: leveransadressen.
  Widget _buildAddressStep() {
    return _buildStepCard(
      key: const ValueKey(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Leveransadress', style: TextStyle(fontSize: checkoutSectionTitleTextSize, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(controller: _address, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('Adress'), validator: (v) => (v == null || v.isEmpty) ? 'Adress krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _postCode, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('Postnummer'), validator: (v) => (v == null || v.isEmpty) ? 'Postnummer krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _postAddress, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('Stad'), validator: (v) => (v == null || v.isEmpty) ? 'Stad krävs' : null),
        ],
      ),
    );
  }

  // Steg 2: betalningsinformationen.
  Widget _buildPaymentStep() {
    return _buildStepCard(
      key: const ValueKey(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Betalningsinformation', style: TextStyle(fontSize: checkoutSectionTitleTextSize, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(controller: _cardHolder, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('Korthavarens namn'), validator: (v) => (v == null || v.isEmpty) ? 'Korthavarens namn krävs' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _cardNumber, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('Kortnummer'), validator: (v) => (v == null || v.isEmpty) ? 'Kortnummer krävs' : null),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(controller: _validMonth, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('MM'), validator: (v) => (v == null || v.isEmpty) ? 'MM krävs' : null)),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _validYear, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('YY'), validator: (v) => (v == null || v.isEmpty) ? 'YY krävs' : null)),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(controller: _verification, style: _checkoutInputStyle(), decoration: _checkoutInputDecoration('CVC'), validator: (v) => (v == null || v.isEmpty) ? 'CVC krävs' : null)),
          ]),
        ],
      ),
    );
  }

  // Steg 3: samlar information, produktlista och totalsumma i tre separata kort.
  Widget _buildReviewStep(ImatDataHandler iMat, double cartTotal, double totalWithService) {
    final itemCount = iMat.getShoppingCart().items.fold<int>(0, (sum, item) => sum + item.amount.toInt());
    return _buildStepCard(
      key: const ValueKey(3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Sammanfattning', style: TextStyle(fontSize: checkoutSummaryTitleTextSize, fontWeight: FontWeight.w700, color: Colors.black)),
          const SizedBox(height: 16),

          // Limit the height of the summary cards area so that the middle
          // card's scrollable list can expand to fill the remaining height
          // while leaving other steps unaffected.
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.62),
            child: LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > checkoutReviewWideBreakpoint;
            final leftCard = _buildReviewInfoCard();
            final middleCard = _buildReviewItemsCard(iMat);
            final rightCard = _buildReviewSummaryCard(iMat, cartTotal, totalWithService, itemCount);

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: leftCard),
                  const SizedBox(width: checkoutReviewCardGap),
                  Expanded(flex: 1, child: middleCard),
                  const SizedBox(width: checkoutReviewCardGap),
                  Expanded(flex: 1, child: rightCard),
                ],
              );
            }

            return Column(children: [leftCard, const SizedBox(height: checkoutReviewCardGap), middleCard, const SizedBox(height: checkoutReviewCardGap), rightCard]);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(checkoutReviewCardInnerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewSection('Personlig information', [
              'Förnamn: ${_firstName.text}',
              'Efternamn: ${_lastName.text}',
              'E-post: ${_email.text}',
              'Telefon: ${_phone.text}',
            ]),
            const SizedBox(height: checkoutReviewSectionGap),
            _buildReviewSection('Leveransadress', [
              'Adress: ${_address.text}',
              'Postnummer: ${_postCode.text}',
              'Stad: ${_postAddress.text}',
            ]),
            const SizedBox(height: checkoutReviewSectionGap),
            _buildReviewSection('Betalning', [
              'Korthavare: ${_cardHolder.text}',
              'Kortnummer: •••• •••• •••• ${_cardNumber.text.length >= 4 ? _cardNumber.text.substring(_cardNumber.text.length - 4) : _cardNumber.text}',
              'Giltig till: ${_validMonth.text}/${_validYear.text}',
              'CVC: ${_verification.text}',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItemsCard(ImatDataHandler iMat) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(checkoutReviewCardInnerPadding),
        child: Column(
          children: [
            // Small visual handle to indicate the area is scrollable
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(6),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: iMat.getShoppingCart().items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: checkoutReviewRightCardGapSmall),
                  itemBuilder: (ctx, idx) {
                    final it = iMat.getShoppingCart().items[idx];
                    final prod = it.product;
                    return SizedBox(
                      height: checkoutReviewLineItemHeight,
                      child: Row(
                        children: [
                          AspectRatio(aspectRatio: 1, child: ClipRRect(borderRadius: BorderRadius.circular(checkoutReviewImageRadius), child: iMat.getImage(prod))),
                          const SizedBox(width: checkoutReviewCardGap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(prod.name, style: const TextStyle(fontSize: checkoutReviewProductNameTextSize, fontWeight: FontWeight.w700, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Text('Antal: ${it.amount.toInt()}', style: const TextStyle(fontSize: checkoutReviewQuantityTextSize, color: Colors.black54)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(iMat.displayPrice(prod) * it.amount).toStringAsFixed(2)} kr',
                            style: TextStyle(fontSize: checkoutReviewPriceTextSize, fontWeight: FontWeight.w700, color: iMat.isOnSale(prod) ? Colors.red : Colors.black),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSummaryCard(ImatDataHandler iMat, double cartTotal, double totalWithService, int itemCount) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(checkoutReviewCardInnerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Antal varor:', style: const TextStyle(fontSize: checkoutSummaryLabelTextSize, color: Colors.black)),
              Text(itemCount.toString(), style: const TextStyle(fontSize: checkoutSummaryValueTextSize, fontWeight: FontWeight.w600, color: Colors.black)),
            ]),
            const SizedBox(height: checkoutReviewRightCardGapSmall),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Subtotal:', style: const TextStyle(fontSize: checkoutSummaryLabelTextSize, color: Colors.black)),
              Text('${cartTotal.toStringAsFixed(2)} kr', style: const TextStyle(fontSize: checkoutSummaryValueTextSize, color: Colors.black, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: checkoutReviewRightCardGapSmall),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Leveransavgift:', style: const TextStyle(fontSize: checkoutSummaryLabelTextSize, color: Colors.black)),
              Text('${serviceFee.toStringAsFixed(0)} kr', style: const TextStyle(fontSize: checkoutSummaryValueTextSize, color: Colors.black, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: checkoutReviewSummaryDividerGap),
            const Divider(),
            const SizedBox(height: checkoutReviewSummaryDividerGap),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Totalt:', style: const TextStyle(fontSize: checkoutSummaryTotalLabelTextSize, fontWeight: FontWeight.w700, color: Colors.black)),
              Text('${totalWithService.toStringAsFixed(2)} kr', style: const TextStyle(fontSize: checkoutSummaryTotalValueTextSize, fontWeight: FontWeight.w800, color: Colors.black)),
            ]),
            const SizedBox(height: checkoutReviewSummaryDividerGap),
            Text('Totalt antal varor: ${itemCount.toString()}', style: const TextStyle(fontSize: checkoutSummaryFooterTextSize, color: Colors.black)),
            const SizedBox(height: checkoutReviewSummaryButtonGap),
            ElevatedButton.icon(
              onPressed: () => _placeOrder(iMat),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(checkoutButtonMinHeight),
                textStyle: const TextStyle(fontSize: checkoutSaveCartButtonTextSize),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Slutför köp'),
            ),
            const SizedBox(height: checkoutReviewSummaryButtonGap),
            Builder(builder: (ctx) {
              final saved = iMat.isCurrentCartSaved();
              return ElevatedButton.icon(
                onPressed: () {
                  if (!saved) {
                    _showSaveDialog(iMat);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: saved ? Colors.green : const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(checkoutButtonMinHeight),
                  textStyle: const TextStyle(fontSize: checkoutSaveCartButtonTextSize),
                ),
                icon: const Icon(Icons.save),
                label: Text(saved ? 'Sparad' : 'Spara varukorg', style: const TextStyle(fontSize: checkoutSaveCartButtonTextSize)),
              );
            }),
            const SizedBox(height: checkoutReviewSummaryButtonGap),
            ElevatedButton.icon(
              onPressed: () => setState(() => _currentStep--),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black87,
                minimumSize: const Size.fromHeight(checkoutButtonMinHeight),
                textStyle: const TextStyle(fontSize: checkoutNavButtonTextSize),
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Tillbaka'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(String title, List<String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: checkoutReviewSectionTitleTextSize, fontWeight: FontWeight.w700, color: Colors.black)),
      const SizedBox(height: 8),
      ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(item, style: const TextStyle(fontSize: checkoutReviewSectionItemTextSize, color: Colors.black, fontWeight: FontWeight.w500)))).toList(),
    ]);
  }
}
