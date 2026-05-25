import 'package:flutter/material.dart';
import 'package:imat_app/model/imat/product.dart';
import 'package:imat_app/util/category_names.dart';

const double categorySidebarTitleTextSize = 32.0;
const double categorySidebarItemTextSize = 16.0;
const double categorySidebarHighlightedItemTextSize = 18.0;

/// Sidebar widget för kategori-navigering på produkt-sidan.
/// Visar Favoriter och Specialerbjudanden överst (med pekarkursor),
/// sedan en divider, och därunder alla produktkategorier.
/// Markerar den aktiva kategorin med lila bakgrund.
class CategorySidebar extends StatefulWidget {
  final ProductCategory? activeCategory;
  final bool favoritesActive;
  final bool specialOffersActive;
  final ValueChanged<ProductCategory> onCategoryTap;
  final VoidCallback onFavoritesTap;
  final VoidCallback onSpecialOffersTap;

  const CategorySidebar({
    required this.onCategoryTap,
    required this.onFavoritesTap,
    required this.onSpecialOffersTap,
    this.activeCategory,
    this.favoritesActive = false,
    this.specialOffersActive = false,
    super.key,
  });

  @override
  State<CategorySidebar> createState() => _CategorySidebarState();
}

class _CategorySidebarState extends State<CategorySidebar> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _favKey = GlobalKey();
  final GlobalKey _offersKey = GlobalKey();
  final Map<ProductCategory, GlobalKey> _categoryKeys = {};

  @override
  void initState() {
    super.initState();
    for (final cat in orderedCategories.where((c) => c != ProductCategory.UNDEFINED)) {
      _categoryKeys[cat] = GlobalKey();
    }
  }

  @override
  void didUpdateWidget(covariant CategorySidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActiveIfNeeded());
  }

  void _scrollToActiveIfNeeded() {
    try {
      if (widget.favoritesActive && _favKey.currentContext != null) {
        Scrollable.ensureVisible(_favKey.currentContext!, duration: const Duration(milliseconds: 250), alignment: 0.3);
        return;
      }

      if (widget.specialOffersActive && _offersKey.currentContext != null) {
        Scrollable.ensureVisible(_offersKey.currentContext!, duration: const Duration(milliseconds: 250), alignment: 0.3);
        return;
      }

      final cat = widget.activeCategory;
      if (cat != null && _categoryKeys.containsKey(cat)) {
        final key = _categoryKeys[cat];
        if (key?.currentContext != null) {
          Scrollable.ensureVisible(key!.currentContext!, duration: const Duration(milliseconds: 250), alignment: 0.35);
        }
      }
    } catch (_) {
      // ignore scroll errors silently
    }
  }

  @override
  Widget build(BuildContext context) {
    // Skapar en 220px bred sidopanel med grå bakgrund
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: 220),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        // Gör contentet scrollbart om det blir långt
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rubrik för sidopanelen
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Kategorier',
                  style: TextStyle(fontSize: categorySidebarTitleTextSize, fontWeight: FontWeight.bold),
                ),
              ),
              // Favoriter-knapp (prominent med chevron och hover-effekt)
              Container(key: _favKey, child: _SidebarItem(
                label: 'Favoriter',
                isHighlighted: widget.favoritesActive,
                onTap: widget.onFavoritesTap,
                prominent: true,
              )),
              // Specialerbjudanden-knapp (prominent med chevron och hover-effekt)
              Container(key: _offersKey, child: _SidebarItem(
                label: 'Specialerbjudanden',
                isHighlighted: widget.specialOffersActive,
                onTap: widget.onSpecialOffersTap,
                prominent: true,
              )),
              const SizedBox(height: 8),
              // Visuell skiljelinje mellan special items och regular categories
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 8),
              // Alla produktkategorier i ordnad lista
              ...orderedCategories
                  .where((cat) => cat != ProductCategory.UNDEFINED)
                  .map(
                    (cat) => Container(
                      key: _categoryKeys[cat],
                      child: _SidebarItem(
                        label: getCategoryName(cat),
                        isHighlighted: widget.activeCategory == cat,
                        onTap: () => widget.onCategoryTap(cat),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

/// En enskild kategori-rad i sidopanelen.
/// Stöder hover-effekter (ändrad bakgrund), highlighting (lila bakgrund),
/// och prominent-stil (visas överst med chevron-ikon).
class _SidebarItem extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isHighlighted; // True om denna kategori är aktiv
  final bool prominent; // True för Favoriter/Specialerbjudanden (överst)

  const _SidebarItem({
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
    this.prominent = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hover = false; // Spårar om musen är över denna rad

  @override
  Widget build(BuildContext context) {
    // Välj bakgrundsfärg baserat på hover, highlighted, eller neutral
    // Prominent items får en till-höger pil-ikon (chevron)
    final bgColor = widget.isHighlighted
        ? const Color(0xFFD8CFFF)
        : _hover
            ? Colors.grey.shade200
            : Colors.transparent;

    final textStyle = TextStyle(
      fontSize: widget.isHighlighted ? categorySidebarHighlightedItemTextSize : categorySidebarItemTextSize,
      fontWeight: widget.isHighlighted ? FontWeight.w800 : (widget.prominent ? FontWeight.w600 : FontWeight.w500),
      color: Colors.black87,
      decoration: widget.prominent && !_hover ? TextDecoration.none : TextDecoration.none,
    );

    // MouseRegion ger pekarkursor och hover-tracking
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      // GestureDetector hanterar tap-event
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Etikett för kategorin
              Text(widget.label, style: textStyle),
              // Visa chevron för prominent items (Favoriter/Specialerbjudanden)
              if (widget.prominent) Icon(Icons.chevron_right, size: 18, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}



