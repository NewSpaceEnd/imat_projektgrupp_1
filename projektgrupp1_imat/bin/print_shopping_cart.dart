#!/usr/bin/env dart

import 'dev_dump.dart';

Future<void> main() async {
  await dumpGetEndpoint(
    title: 'Shopping cart',
    endpoint: 'shoppingcart',
    id: 1,
  );
}
