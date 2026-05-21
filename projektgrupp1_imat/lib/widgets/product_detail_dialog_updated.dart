import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/imat/shopping_item.dart';
import 'package:imat_app/widgets/cart_quantity_controls.dart';

class ProductDetailDialog extends StatefulWidget {
  final Product product;
  final ImatDataHandler iMat;

  const ProductDetailDialog({
    required this.product,
    required this.iMat,
    super.key,
  });

  @override
  State<ProductDetailDialog> createState() => _ProductDetailDialogState();
}

class _ProductDetailDialogState extends State<ProductDetailDialog> {
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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: AnimatedBuilder(
        animation: widget.iMat,
        builder: (context, _) {
          final detail = widget.iMat.getDetail(widget.product);
          final image = widget.iMat.getImage(widget.product);
          final amountInCart = widget.iMat.shoppingCartAmount(widget.product);

          if (!_isEditingQuantity &&
              _quantityController.text != amountInCart.toStringAsFixed(0)) {
            _quantityController.text = amountInCart.toStringAsFixed(0);
          }

          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    SizedBox(height: 200, child: image),
                    const SizedBox(height: AppTheme.paddingLarge),
                    Text(
                      widget.product.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      '${widget.product.price.toStringAsFixed(2)} kr/${widget.product.unit}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (detail?.country.isNotEmpty == true)
                          _InfoChip(label: 'Land', value: detail!.country),
                        if (widget.product.isEcological)
                          const _InfoChip(label: 'Typ', value: 'Ekologisk'),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _DetailBlock(
                      title: 'Beskrivning',
                      value: detail?.description.isNotEmpty == true ? detail!.description : 'Saknas',
                    ),
                    _DetailBlock(
                      title: 'Innehåll',
                      value: detail?.contents.isNotEmpty == true ? detail!.contents : 'Saknas',
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _CartActionArea(
                      amountInCart: amountInCart,
                      quantityController: _quantityController,
                      quantityFocusNode: _quantityFocusNode,
                      onAdd: () => _handleAddToCart(context),
                      onRemove: () => widget.iMat.shoppingCartUpdate(ShoppingItem(widget.product, amount: 1.0), delta: -1.0),
                      onCommitAmount: _commitQuantity,
                      onBeginEditing: _beginEditingQuantity,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleAddToCart(BuildContext context) {
    final isLoggedIn = widget.iMat.getUser().userName.isNotEmpty;
    if (!isLoggedIn) {
      _showLoginRequiredDialog(context);
    } else {
      widget.iMat.shoppingCartAdd(ShoppingItem(widget.product, amount: 1.0));
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logga in krävs'),
        content: const Text('Du behöver logga in för att handla.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stäng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Close product dialog too
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logga in'),
          ),
        ],
      ),
    );
  }

  void _beginEditingQuantity() {
    _isEditingQuantity = true;
    _quantityController.selection = TextSelection(baseOffset: 0, extentOffset: _quantityController.text.length);
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
      if (_quantityController.text != currentAmount.toString()) {
        _quantityController.text = currentAmount.toString();
      }
      return;
    }

    widget.iMat.shoppingCartSetAmount(
      ShoppingItem(widget.product, amount: 1.0),
      targetAmount.toDouble(),
    );

    _quantityController.text = targetAmount.toString();
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FB),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  final String title;
  final String value;

  const _DetailBlock({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _CartActionArea extends StatelessWidget {
  final double amountInCart;
  final TextEditingController quantityController;
  final FocusNode quantityFocusNode;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onCommitAmount;
  final VoidCallback onBeginEditing;

  const _CartActionArea({
    required this.amountInCart,
    required this.quantityController,
    required this.quantityFocusNode,
    required this.onAdd,
    required this.onRemove,
    required this.onCommitAmount,
    required this.onBeginEditing,
  });

  @override
  Widget build(BuildContext context) {
    return CartQuantityControls(
      amountInCart: amountInCart,
      quantityController: quantityController,
      quantityFocusNode: quantityFocusNode,
      onAdd: onAdd,
      onRemove: onRemove,
      onCommitAmount: onCommitAmount,
      onBeginEditing: onBeginEditing,
    );
  }
}
