import 'package:imat_app/model/imat/shopping_cart.dart';
import 'package:imat_app/model/imat/shopping_item.dart';

class SavedShoppingCart {
  final String name;
  final DateTime savedAt;
  final ShoppingCart cart;

  SavedShoppingCart({
    required this.name,
    required this.savedAt,
    required this.cart,
  });

  SavedShoppingCart.fromJson(Map<String, dynamic> json)
      : name = json[_nameKey] as String,
        savedAt = DateTime.parse(json[_savedAtKey] as String),
        cart = ShoppingCart(
          (json[_itemsKey] as List)
              .map((item) => ShoppingItem.fromJson(item as Map<String, dynamic>))
              .toList(),
        );

  Map<String, dynamic> toJson() => {
        _nameKey: name,
        _savedAtKey: savedAt.toIso8601String(),
        _itemsKey: cart.items.map((item) => item.toJson()).toList(),
      };

  SavedShoppingCart copyWith({
    String? name,
    DateTime? savedAt,
    ShoppingCart? cart,
  }) {
    return SavedShoppingCart(
      name: name ?? this.name,
      savedAt: savedAt ?? this.savedAt,
      cart: cart ?? this.cart,
    );
  }

  static const _nameKey = 'name';
  static const _savedAtKey = 'savedAt';
  static const _itemsKey = 'items';
}
