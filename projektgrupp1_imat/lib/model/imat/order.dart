import 'dart:convert';

import 'package:imat_app/model/imat/shopping_item.dart';

class Order {
  int orderNumber;
  DateTime date;
  List<ShoppingItem> items;

  Order(this.orderNumber, this.date, this.items);

  factory Order.fromJson(Map<String, dynamic> json) {
    int orderNumber = json[_orderNumber] as int;
    int timeStamp = json[_date] as int;
    // The server may return the 'items' field either as a decoded List or as
    // a JSON-encoded string. Handle both cases defensively to avoid mapping
    // errors where characters or wrong types are passed into ShoppingItem.
    final rawItems = json[_items];
    List jsonItems;
    if (rawItems is String) {
      try {
        jsonItems = jsonDecode(rawItems) as List;
      } catch (e) {
        jsonItems = [];
      }
    } else if (rawItems is List) {
      jsonItems = rawItems;
    } else {
      jsonItems = [];
    }

    final List<ShoppingItem> items = [];
    for (final dynamic ji in jsonItems) {
      if (ji is Map<String, dynamic>) {
        items.add(ShoppingItem.fromJson(ji));
      } else {
        // If the server returned nested strings, try to decode each entry.
        try {
          final decoded = jsonDecode(ji.toString()) as Map<String, dynamic>;
          items.add(ShoppingItem.fromJson(decoded));
        } catch (e) {
          // ignore malformed item
        }
      }
    }
    return Order(
      orderNumber,
      DateTime.fromMillisecondsSinceEpoch(timeStamp),
      items,
    );
  }

  Map<String, dynamic> toJson() => {
    _orderNumber: orderNumber,
    _date: date.millisecondsSinceEpoch,
    _items: jsonEncode(items.map((item) => item.toJson()).toList()),
  };

  double getTotal() {
    var total = 0.0;

    for (final item in items) {
      total = total + item.product.price * item.amount;
    }
    return total;
  }

  static const _orderNumber = 'orderNumber';
  static const _date = 'date';
  static const _items = 'items';
}
