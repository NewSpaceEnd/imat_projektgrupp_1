import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/widgets/primary_action_button.dart';

const double cartQuantityInputTextSize = 25.0;

class CartQuantityControls extends StatelessWidget {
  final double amountInCart;
  final TextEditingController quantityController;
  final FocusNode quantityFocusNode;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onCommitAmount;
  final VoidCallback onBeginEditing;

  const CartQuantityControls({
    required this.amountInCart,
    required this.quantityController,
    required this.quantityFocusNode,
    required this.onAdd,
    required this.onRemove,
    required this.onCommitAmount,
    required this.onBeginEditing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (amountInCart <= 0) {
      return SizedBox(
        width: double.infinity,
        child: PrimaryActionButton(
          onPressed: onAdd,
          icon: Icons.shopping_cart,
          label: 'Lägg till i varukorg',
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.remove),
            onPressed: onRemove,
          ),
          SizedBox(
            width: 72,
            child: Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  onCommitAmount();
                }
              },
              child: TextField(
                controller: quantityController,
                focusNode: quantityFocusNode,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                style: const TextStyle(fontSize: cartQuantityInputTextSize, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: onBeginEditing,
                onSubmitted: (_) => onCommitAmount(),
                onEditingComplete: onCommitAmount,
              ),
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}