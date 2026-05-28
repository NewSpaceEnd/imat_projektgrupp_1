import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/widgets/cart_quantity_controls.dart';
import 'package:imat_app/widgets/product_detail_dialog.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final ImatDataHandler iMat;

  // Ändra dessa värden för att justera textstorleken i produktkorten.
  static const double originTextSize = 25.0;
  static const double productNameTextSize = 25.0;
  static const double brandTextSize = 18.0;
  static const double unitTextSize = 18.0;
  static const double priceTextSize = 25.0;
  static const double ecoBadgeTextSize = 18.0;
  static const double favoriteIconSize = 36.0;

  const ProductCard(this.product, this.iMat, {super.key});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late final TextEditingController _quantityController;
  late final FocusNode _quantityFocusNode;
  bool _isEditingQuantity = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.iMat.shoppingCartAmount(widget.product).toStringAsFixed(0),
    );
    _quantityFocusNode = FocusNode()..addListener(_handleQuantityFocusChange);
  }

  @override
  void dispose() {
    _quantityFocusNode.removeListener(_handleQuantityFocusChange);
    _quantityFocusNode.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.iMat,
      builder: (context, _) {
        final amountInCart = widget.iMat.shoppingCartAmount(widget.product);

        if (!_isEditingQuantity && _quantityController.text != amountInCart.toStringAsFixed(0)) {
          _quantityController.text = amountInCart.toStringAsFixed(0);
        }

        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showProductDetails(context),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top row: origin left, favorite top-right
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.iMat.getDetail(widget.product)?.origin ?? '',
                                style: const TextStyle(
                                  fontSize: ProductCard.originTextSize,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                widget.iMat.isFavorite(widget.product) ? Icons.favorite : Icons.favorite_border,
                                color: widget.iMat.isFavorite(widget.product) ? Colors.red : Colors.grey,
                                size: ProductCard.favoriteIconSize,
                              ),
                              onPressed: () => widget.iMat.toggleFavorite(widget.product),
                              tooltip: widget.iMat.isFavorite(widget.product) ? 'Ta bort favorit' : 'Lägg till favorit',
                            ),
                          ],
                        ),

                        // Image (centered area)
                        Expanded(child: widget.iMat.getImage(widget.product)),

                        const SizedBox(height: 8),

                        // Name
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: ProductCard.productNameTextSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Brand / unit on left, unit-price on right
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.iMat.getDetail(widget.product)?.brand.isNotEmpty == true
                                    ? widget.iMat.getDetail(widget.product)!.brand
                                    : widget.product.unit,
                                style: const TextStyle(
                                  fontSize: ProductCard.brandTextSize,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.product.unit,
                                  style: const TextStyle(
                                    fontSize: ProductCard.unitTextSize,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${(widget.iMat.displayPrice(widget.product)).toStringAsFixed(2)} kr',
                                  style: const TextStyle(
                                    fontSize: ProductCard.unitTextSize,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Price row with eco badge and optional sale indicator
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.iMat.isOnSale(widget.product))
                                    Row(
                                      children: [
                                        Text(
                                          '${widget.product.price.toStringAsFixed(2)} kr',
                                          style: const TextStyle(
                                            fontSize: ProductCard.unitTextSize,
                                            color: Colors.black38,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${widget.iMat.displayPrice(widget.product).toStringAsFixed(2)} kr',
                                          style: TextStyle(
                                            fontSize: ProductCard.priceTextSize,
                                            fontWeight: FontWeight.w800,
                                            color: widget.iMat.isOnSale(widget.product) ? Colors.red : Colors.black,
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    Text(
                                      '${widget.iMat.displayPrice(widget.product).toStringAsFixed(2)} kr',
                                      style: TextStyle(
                                        fontSize: ProductCard.priceTextSize,
                                        fontWeight: FontWeight.w800,
                                        color: widget.iMat.isOnSale(widget.product) ? Colors.red : Colors.black,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (widget.iMat.isOnSale(widget.product))
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'REA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            if (widget.product.isEcological)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB6D42C),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'eko',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ProductCard.ecoBadgeTextSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Add button (full width)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: CartQuantityControls(
                    amountInCart: amountInCart,
                    quantityController: _quantityController,
                    quantityFocusNode: _quantityFocusNode,
                    onAdd: () => _handleAddToCart(context),
                    onRemove: () => widget.iMat.shoppingCartUpdate(ShoppingItem(widget.product), delta: -1.0),
                    onCommitAmount: _commitQuantity,
                    onBeginEditing: _beginEditingQuantity,
                  ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAddToCart(BuildContext context) {
    final isLoggedIn = widget.iMat.getUser().userName.isNotEmpty;
    if (isLoggedIn) {
      widget.iMat.shoppingCartAdd(ShoppingItem(widget.product, amount: 1.0));
      return;
    }
    if (widget.iMat.suppressLoginPrompt) {
      widget.iMat.shoppingCartAdd(ShoppingItem(widget.product, amount: 1.0));
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: AlertDialog(
            title: Text('Logga in rekommenderas', style: TextStyle(fontSize: productDetailUpdatedBlockTitleTextSize, fontWeight: FontWeight.bold)),
            content: Text('Du är inte inloggad. Vill du logga in för att spara dina köp under din profil? Du kan också fortsätta utan inloggning, men då sparas inga köp under din profil.', style: TextStyle(fontSize: productDetailUpdatedBlockValueTextSize)),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Avbryt', style: TextStyle(fontSize: productDetailUpdatedChipTextSize)),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)),
                onPressed: () {
                  // Remember user's choice and continue without login
                  widget.iMat.setSuppressLoginPrompt(true);
                  widget.iMat.shoppingCartAdd(ShoppingItem(widget.product, amount: 1.0));
                  Navigator.of(ctx).pop();
                },
                child: Text('Fortsätt utan inloggning', style: TextStyle(fontSize: productDetailUpdatedChipTextSize)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Logga in', style: TextStyle(fontSize: productDetailUpdatedChipTextSize)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _beginEditingQuantity() {
    _isEditingQuantity = true;
    _quantityController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _quantityController.text.length,
    );
  }

  void _handleQuantityFocusChange() {
    if (!_quantityFocusNode.hasFocus) {
      _commitQuantity();
    }
  }

  void _commitQuantity() {
    final parsed = int.tryParse(_quantityController.text.trim());
    final currentAmount = widget.iMat.shoppingCartAmount(widget.product).round();
    final targetAmount = parsed == null || parsed < 0 ? currentAmount : parsed;

    _isEditingQuantity = false;

    if (targetAmount == currentAmount) {
      _quantityController.text = currentAmount.toString();
      return;
    }

    widget.iMat.shoppingCartSetAmount(
      ShoppingItem(widget.product, amount: 1.0),
      targetAmount.toDouble(),
    );

    _quantityController.text = targetAmount.toString();
  }

  void _showProductDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => ProductDetailDialog(product: widget.product, iMat: widget.iMat),
    );
  }
}