enum ProductArtType { apple, banana, potato, chili }

class ProductData {
  const ProductData({
    required this.country,
    required this.name,
    required this.detail,
    required this.unit,
    required this.unitPrice,
    required this.price,
    required this.art,
  });

  final String country;
  final String name;
  final String detail;
  final String unit;
  final String unitPrice;
  final String price;
  final ProductArtType art;
}

class SectionData {
  const SectionData({
    required this.title,
    required this.cta,
    required this.products,
  });

  final String title;
  final String cta;
  final List<ProductData> products;
}
