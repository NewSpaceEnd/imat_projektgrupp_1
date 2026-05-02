import 'package:flutter/material.dart';
import 'package:projektgrupp1_imat/app_theme.dart';

class ImatTopBar extends StatelessWidget {
  const ImatTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      color: AppTheme.topBar,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        'Homepage',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white70, fontSize: 13),
      ),
    );
  }
}
