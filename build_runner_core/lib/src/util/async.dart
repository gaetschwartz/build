// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:pool/pool.dart';

/// Invokes [callback] and returns the result as soon as possible. This will
/// happen synchronously if [value] is available.
FutureOr<S> doAfter<T, S>(
    FutureOr<T> value, FutureOr<S> Function(T value) callback) {
  if (value is Future<T>) {
    return value.then(callback);
  } else {
    return callback(value);
  }
}

/// Converts [value] to a [Future] if it is not already.
Future<T> toFuture<T>(FutureOr<T> value) =>
    value is Future<T> ? value : Future.value(value);

/// Pooled Future wait.
Future<List<T>> pooledWait<T>(Iterable<Future<T>> futures) async {
  final pool = Pool(Platform.numberOfProcessors ~/ 2);
  return await Future.wait(futures.map((f) => pool.withResource(
        () async => Isolate.run(() async => await f),
      )));
}
