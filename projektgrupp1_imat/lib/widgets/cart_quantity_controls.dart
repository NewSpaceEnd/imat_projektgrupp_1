import 'package:flutter/material.dart';

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
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C3BD6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: onAdd,
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          label: const Text(
            'Lägg till i varukorg',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FB),
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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