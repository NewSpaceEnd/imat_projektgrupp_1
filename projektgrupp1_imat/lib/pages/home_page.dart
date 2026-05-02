import 'package:flutter/material.dart';
import 'package:projektgrupp1_imat/app_theme.dart';
import 'package:projektgrupp1_imat/util/home_mock_data.dart';
import 'package:projektgrupp1_imat/widgets/category_panel.dart';
import 'package:projektgrupp1_imat/widgets/imat_header.dart';
import 'package:projektgrupp1_imat/widgets/imat_top_bar.dart';
import 'package:projektgrupp1_imat/widgets/product_search_bar.dart';
import 'package:projektgrupp1_imat/widgets/section_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: const SafeArea(
        child: Column(
          children: [
            ImatTopBar(),
            ImatHeader(cartCount: 0),
            Expanded(child: _HomeContent()),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(26, 14, 26, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 980;

          if (compact) {
            return Column(
              children: [
                const ProductSearchBar(),
                const SizedBox(height: 12),
                const CategoryPanel(categories: homeCategories, compact: true),
                const SizedBox(height: 12),
                ...homeSections
                    .map((section) => SectionPanel(section: section))
                    .toList(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 180,
                child: CategoryPanel(categories: homeCategories),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    const ProductSearchBar(),
                    const SizedBox(height: 12),
                    ...homeSections
                        .map((section) => SectionPanel(section: section))
                        .toList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
