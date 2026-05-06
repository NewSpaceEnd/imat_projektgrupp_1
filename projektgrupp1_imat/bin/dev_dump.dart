import 'dart:convert';

import 'package:http/http.dart' as http;

const String apiKey =
    'a27bg892h-jgdfg6-81kwna22lmq-sidfha9361zw-jj221112abkm77';

const Map<String, String> apiHeaders = {'X-API-Key': apiKey};

const String baseUrl = 'https://dat216.cse.chalmers.se/imat2/api';

Future<void> dumpGetEndpoint({
  required String title,
  required String endpoint,
  int? id,
}) async {
  final path = id == null ? '$baseUrl/$endpoint' : '$baseUrl/$endpoint/$id';
  print('Dev menu - $title');
  print('GET $path');

  final response = await http.get(Uri.parse(path), headers: apiHeaders);
  if (response.statusCode < 200 || response.statusCode >= 300) {
    print('Failed: HTTP ${response.statusCode}');
    if (response.body.isNotEmpty) {
      print(response.body);
    }
    return;
  }

  final body = response.body.trim();
  if (body.isEmpty) {
    print('No data returned.');
    return;
  }

  try {
    final decoded = jsonDecode(body);
    print(const JsonEncoder.withIndent('  ').convert(decoded));
  } catch (_) {
    print(body);
  }
}
