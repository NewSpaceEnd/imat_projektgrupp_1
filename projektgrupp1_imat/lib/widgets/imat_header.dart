import 'package:flutter/material.dart';
import 'package:projektgrupp1_imat/app_theme.dart';

class ImatHeader extends StatelessWidget {
  const ImatHeader({super.key, required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.panel,
        border: Border(bottom: BorderSide(color: AppTheme.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'i',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 50,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: 'Mat',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 50,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _CartButton(count: cartCount),
        ],
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_cart_checkout,
            color: Colors.white,
            size: 29,
          ),
          const SizedBox(width: 10),
          Text(
            'Kassa',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 41,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '$count',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
