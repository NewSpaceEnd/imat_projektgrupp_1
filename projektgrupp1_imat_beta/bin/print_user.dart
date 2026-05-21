#!/usr/bin/env dart

import 'dev_dump.dart';

Future<void> main() async {
  await dumpGetEndpoint(title: 'User', endpoint: 'user', id: 1);
}
