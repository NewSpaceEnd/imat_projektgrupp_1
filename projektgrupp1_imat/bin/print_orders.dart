#!/usr/bin/env dart

import 'dev_dump.dart';

Future<void> main() async {
  await dumpGetEndpoint(title: 'Orders', endpoint: 'orders', id: 1);
}
