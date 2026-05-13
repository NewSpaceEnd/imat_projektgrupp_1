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
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showProductDetails(context),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingSmall),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                widget.iMat.getDetail(widget.product)?.origin ?? '',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  widget.iMat.isFavorite(widget.product)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: widget.iMat.isFavorite(widget.product) ? Colors.red : Colors.grey,
                                ),
                                onPressed: () => widget.iMat.toggleFavorite(widget.product),
                                tooltip: widget.iMat.isFavorite(widget.product)
                                    ? 'Ta bort favorit'
                                    : 'Lägg till favorit',
                              ),
                            ),
                          ],
                        ),
                        Expanded(child: widget.iMat.getImage(widget.product)),
                        const SizedBox(height: AppTheme.paddingSmall),
                        const SizedBox(height: 6),
                        Text(
                          widget.product.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.product.unit} • ${widget.product.price.toStringAsFixed(2)} kr',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingSmall),
                child: CartQuantityControls(
                  amountInCart: amountInCart,
                  quantityController: _quantityController,
                  quantityFocusNode: _quantityFocusNode,
                  onAdd: () => widget.iMat.shoppingCartAdd(ShoppingItem(widget.product, amount: 1.0)),
                  onRemove: () => widget.iMat.shoppingCartUpdate(
                    ShoppingItem(widget.product, amount: 1.0),
                    delta: -1.0,
                  ),
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

    final delta = targetAmount - currentAmount;
    if (delta > 0) {
      for (var i = 0; i < delta; i++) {
        widget.iMat.shoppingCartAdd(ShoppingItem(widget.product, amount: 1.0));
      }
    } else {
      for (var i = 0; i < -delta; i++) {
        widget.iMat.shoppingCartUpdate(
          ShoppingItem(widget.product, amount: 1.0),
          delta: -1.0,
        );
      }
    }

    _quantityController.text = targetAmount.toString();
  }

  void _showProductDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => ProductDetailDialog(product: widget.product, iMat: widget.iMat),
    );
  }
}