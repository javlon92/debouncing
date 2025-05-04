import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';

Future<Either<String, String>> someUseCaseCall({
  required String someParams,
}) async {
  return guardAsync<String, String>(
    right: () => Future<String>.delayed(
      const Duration(milliseconds: 100),
      () => someParams.isNotEmpty ? someParams : throw Exception(),
    ),
    left: () => 'Something went wrong!',
  );
}

Future<Either<L, R>> guardAsync<L, R>({
  required FutureOr<R> Function() right,
  required FutureOr<L> Function() left,
  bool Function(Object error, StackTrace stackTrace)? test,
}) async {
  try {
    return Right(await right());
  } catch (error, stackTrace) {
    log('Error: $error StackTrace: $stackTrace');

    if (test == null || test(error, stackTrace)) {
      return Left(await left());
    }

    Error.throwWithStackTrace(error, stackTrace);
  }
}
