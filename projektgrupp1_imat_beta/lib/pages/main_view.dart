import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/pages/category_view.dart';
import 'package:imat_app/util/category_names.dart';
import 'package:imat_app/widgets/category_section.dart';
import 'package:imat_app/widgets/category_sidebar.dart';
import 'package:imat_app/widgets/preview_product_strip.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';
import 'package:provider/provider.dart';

typedef SidebarFocusChanged = void Function(
  ProductCategory? activeCategory,
  bool favoritesActive,
  bool specialOffersActive,
);

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  ProductCategory? _activeCategory;
  bool _favoritesActive = false;
  bool _specialOffersActive = false;

  final GlobalKey<_MainContentState> _mainContentKey = GlobalKey<_MainContentState>();

  void _openCategoryPage(BuildContext context, ProductCategory category) {
    final title = getCategoryName(category);
    Navigator.pushNamed(
      context,
      '/category/${Uri.encodeComponent(title)}/${category.name}',
    );
  }

  void _selectFavorites() {
    Navigator.pushNamed(context, '/favorites');
  }

  void _openSpecialOffers(BuildContext context) {
    Navigator.pushNamed(context, '/offers');
  }

  void _handleSidebarFocusChanged(
    ProductCategory? category,
    bool favoritesActive,
    bool specialOffersActive,
  ) {
    if (_activeCategory == category &&
        _favoritesActive == favoritesActive &&
        _specialOffersActive == specialOffersActive) {
      return;
    }

    setState(() {
      _activeCategory = category;
      _favoritesActive = favoritesActive;
      _specialOffersActive = specialOffersActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final iMat = context.watch<ImatDataHandler>();
    final isSearching = iMat.selectProducts.length != iMat.products.length;

    return Scaffold(
      appBar: const TopNavBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useStackedLayout = constraints.maxWidth < 980;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: useStackedLayout
                ? Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: CategorySidebar(
                          activeCategory: _activeCategory,
                            favoritesActive: _favoritesActive,
                            specialOffersActive: _specialOffersActive,
                          onCategoryTap: (category) => _openCategoryPage(context, category),
                          onFavoritesTap: _selectFavorites,
                            onSpecialOffersTap: () => _openSpecialOffers(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _MainContent(
                          key: _mainContentKey,
                          iMat: iMat,
                          isSearching: isSearching,
                          onSidebarFocusChanged: _handleSidebarFocusChanged,
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
                      CategorySidebar(
                        activeCategory: _activeCategory,
                        favoritesActive: _favoritesActive,
                        specialOffersActive: _specialOffersActive,
                        onCategoryTap: (category) => _openCategoryPage(context, category),
                        onFavoritesTap: _selectFavorites,
                        onSpecialOffersTap: () => _openSpecialOffers(context),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MainContent(
                          key: _mainContentKey,
                          iMat: iMat,
                          isSearching: isSearching,
                          onSidebarFocusChanged: _handleSidebarFocusChanged,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _MainContent extends StatefulWidget {
  final ImatDataHandler iMat;
  final bool isSearching;
  final SidebarFocusChanged onSidebarFocusChanged;

  const _MainContent({
    super.key,
    required this.iMat,
    required this.isSearching,
    required this.onSidebarFocusChanged,
  });

  @override
  State<_MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<_MainContent> {
  late final ScrollController _scrollController;
  late final Map<ProductCategory, GlobalKey> _sectionKeys;
  final GlobalKey _favoritesKey = GlobalKey();
  final GlobalKey _specialOffersKey = GlobalKey();
  ProductCategory? _lastReportedCategory;
  bool _lastFavoritesActive = false;
  bool _lastSpecialOffersActive = false;
  bool _updateScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scheduleCategoryUpdate);
    _sectionKeys = {
      for (final category in orderedCategories.where((cat) => cat != ProductCategory.UNDEFINED))
        category: GlobalKey(),
    };
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateActiveCategory());
  }

  @override
  void didUpdateWidget(covariant _MainContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateActiveCategory());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scheduleCategoryUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleCategoryUpdate() {
    if (_updateScheduled) {
      return;
    }

    _updateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScheduled = false;
      _updateActiveCategory();
    });
  }

  void _updateActiveCategory() {
    if (!mounted) {
      return;
    }

    if (widget.isSearching) {
      if (_lastReportedCategory != null || _lastFavoritesActive || _lastSpecialOffersActive) {
        _lastReportedCategory = null;
        _lastFavoritesActive = false;
        _lastSpecialOffersActive = false;
        widget.onSidebarFocusChanged(null, false, false);
      }
      return;
    }

    const markerY = 180.0;
    final sections = <_TrackedSection>[
      _TrackedSection.favorites(_favoritesKey),
      _TrackedSection.specialOffers(_specialOffersKey),
      ...orderedCategories
          .where((cat) => cat != ProductCategory.UNDEFINED)
          .map((category) => _TrackedSection.category(category, _sectionKeys[category]!)),
    ];

    ProductCategory? currentCategory;
    bool favoritesActive = false;
    bool specialOffersActive = false;

    for (final section in sections) {
      final context = section.key.currentContext;
      if (context == null) {
        continue;
      }

      final renderObject = context.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) {
        continue;
      }

      final top = renderObject.localToGlobal(Offset.zero).dy;
      if (top <= markerY) {
        currentCategory = section.category;
        favoritesActive = section.isFavorites;
        specialOffersActive = section.isSpecialOffers;
      } else {
        break;
      }
    }

    if (currentCategory != _lastReportedCategory ||
        favoritesActive != _lastFavoritesActive ||
        specialOffersActive != _lastSpecialOffersActive) {
      _lastReportedCategory = currentCategory;
      _lastFavoritesActive = favoritesActive;
      _lastSpecialOffersActive = specialOffersActive;
      widget.onSidebarFocusChanged(currentCategory, favoritesActive, specialOffersActive);
    }
  }

  void scrollToFavorites() {
    _scrollToSection(_favoritesKey);
  }

  void scrollToSpecialOffers() {
    _scrollToSection(_specialOffersKey);
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context == null || !_scrollController.hasClients) {
      return;
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return;
    }

    final targetOffset = (_scrollController.offset + renderObject.localToGlobal(Offset.zero).dy - 180)
        .clamp(0.0, _scrollController.position.maxScrollExtent)
        .toDouble();

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          if (widget.isSearching) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sökresultat (${widget.iMat.selectProducts.length})',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => widget.iMat.selectAllProducts(),
                    child: const Text('Rensa sökning'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PreviewProductStrip(
                products: widget.iMat.selectProducts,
                iMat: widget.iMat,
                height: 525,
              ),
            ),
          ],
          if (!widget.isSearching) ...[
            ..._buildCategorySections(widget.iMat),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCategorySections(ImatDataHandler iMat) {
    return orderedCategories
        .where((cat) => cat != ProductCategory.UNDEFINED)
        .map(
          (cat) => CategorySectionWidget(
            key: _sectionKeys[cat],
            title: getCategoryName(cat),
            category: cat,
            iMat: iMat,
          ),
        )
        .toList();
  }
}

class _TrackedSection {
  final GlobalKey key;
  final ProductCategory? category;
  final bool isFavorites;
  final bool isSpecialOffers;

  const _TrackedSection._(
    this.key,
    this.category,
    this.isFavorites,
    this.isSpecialOffers,
  );

  factory _TrackedSection.category(ProductCategory category, GlobalKey key) {
    return _TrackedSection._(key, category, false, false);
  }

  factory _TrackedSection.favorites(GlobalKey key) {
    return _TrackedSection._(key, null, true, false);
  }

  factory _TrackedSection.specialOffers(GlobalKey key) {
    return _TrackedSection._(key, null, false, true);
  }
}

class _FavoriteSectionWidget extends StatelessWidget {
  final ImatDataHandler iMat;

  const _FavoriteSectionWidget({super.key, required this.iMat});

  @override
  Widget build(BuildContext context) {
    final preview = iMat.favorites.take(CategorySectionWidget.previewItemCount).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingLarge),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Favoriter',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => iMat.selectFavorites(),
                child: const Text('Till alla favoriter'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PreviewProductStrip(
            products: preview,
            iMat: iMat,
            height: 525,
          ),
        ],
      ),
    );
  }
}

class _SpecialOfferSectionWidget extends StatelessWidget {
  final ImatDataHandler iMat;

  const _SpecialOfferSectionWidget({super.key, required this.iMat});

  List<Product> _specialOffers() {
    final sorted = [...iMat.products]..sort((a, b) => a.price.compareTo(b.price));
    final favoritesIds = iMat.favorites.map((p) => p.productId).toSet();
    return sorted.where((product) => !favoritesIds.contains(product.productId)).take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    final preview = _specialOffers().take(CategorySectionWidget.previewItemCount).toList();

    if (preview.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingLarge),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Specialerbjudanden',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/offers'),
                child: const Text('Till alla erbjudanden'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PreviewProductStrip(
            products: preview,
            iMat: iMat,
            height: 525,
          ),
        ],
      ),
    );
  }
}
