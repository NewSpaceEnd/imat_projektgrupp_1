#!/usr/bin/env dart

import 'dev_dump.dart';

Future<void> main() async {
  await dumpGetEndpoint(
    title: 'Credit card',
    endpoint: 'creditcard',
    id: 1,
  );
}
