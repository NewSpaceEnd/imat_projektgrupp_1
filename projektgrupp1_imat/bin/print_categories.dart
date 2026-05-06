#!/usr/bin/env dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:imat_app/model/imat/product.dart';

const _baseUrl = 'https://dat216.cse.chalmers.se/imat2/api/products';
const _apiKey = 'a27bg892h-jgdfg6-81kwna22lmq-sidfha9361zw-jj221112abkm77';
const _headers = {'X-API-Key': _apiKey};

Future<void> main() async {
  print('Dev menu — fetching categories...');

  try {
    final uri = Uri.parse(_baseUrl);
    final resp = await http.get(uri, headers: _headers);
    if (resp.statusCode != 200) {
      print('Failed to fetch products: HTTP ${resp.statusCode}');
      print(resp.body);
      return;
    }

    final jsonData = jsonDecode(resp.body) as List<dynamic>;

    final counts = <ProductCategory, int>{
      for (final category in ProductCategory.values)
        if (category != ProductCategory.UNDEFINED) category: 0,
    };

    for (final item in jsonData) {
      final product = Product.fromJson(item as Map<String, dynamic>);
      if (product.category != ProductCategory.UNDEFINED) {
        counts[product.category] = (counts[product.category] ?? 0) + 1;
      }
    }

    print('\nAll categories in the database:');
    for (final category in ProductCategory.values) {
      if (category == ProductCategory.UNDEFINED) {
        continue;
      }

      final count = counts[category] ?? 0;
      print('- ${category.name} ($count products)');
    }
  } catch (e, st) {
    print('Error fetching categories: $e');
    print(st);
  }
}
