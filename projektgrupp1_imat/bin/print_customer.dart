#!/usr/bin/env dart

import 'dev_dump.dart';

Future<void> main() async {
  await dumpGetEndpoint(title: 'Customer', endpoint: 'customer', id: 1);
}
