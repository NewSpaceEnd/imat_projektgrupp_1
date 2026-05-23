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
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                widget.iMat.isFavorite(widget.product) ? Icons.favorite : Icons.favorite_border,
                                color: widget.iMat.isFavorite(widget.product) ? Colors.red : Colors.grey,
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
                                  '${(widget.product.price).toStringAsFixed(2)} kr',
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

                        // Price row with eco badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${widget.product.price.toStringAsFixed(2)} kr',
                                style: const TextStyle(
                                  fontSize: ProductCard.priceTextSize,
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
                  onAdd: () => widget.iMat.shoppingCartAdd(ShoppingItem(widget.product, amount: 1.0)),
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