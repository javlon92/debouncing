import 'dart:async';
import 'dart:math' as math;

final _rand = math.Random();

/// {@template BackOff}
///
/// [BackOff] is used for holding options for retrying a function.
///
/// With the default configuration functions will be retried up-to 7 times
/// (8 attempts in total), sleeping 1st, 2nd, 3rd, ..., 7th attempt:
///  1. 400 ms ± 25%
///  2. 800 ms ± 25%
///  3. 1600 ms ± 25%
///  4. 3200 ms ± 25%
///  5. 6400 ms ± 25%
///  6. 12800 ms ± 25%
///  7. 25600 ms ± 25%
///
/// ### Usage Example:
///
/// ```dart
///
/// final response = await BackOff(
///   () => http.get('https://google.com').timeout(
///          const Duration(seconds: 10),
///       ),
///   retryIf: (error, stackTrace, attempt) => error is SocketException || error is TimeoutException,
///   initialDelay: const Duration(milliseconds: 200),
///   maxAttempts: 8,
///   percentageRandomization: 0.25,
///   maxDelay: const Duration(seconds: 30),
/// ).call();
///
/// print(response.body);
///
/// ```
///
/// {@endtemplate}
class BackOff<T> {
  /// The [Function] to execute. If the function throws an error, it will be
  /// retried [maxAttempts] times with an increasing delay between each attempt
  /// up to [maxDelay].
  ///
  /// If [retryIf] is provided, the function will only be retried if the error
  /// matches the predicate.
  final FutureOr<T> Function() func;

  /// Delay factor to double after every attempt.
  ///
  /// Defaults to 200 ms, which results in the following delays:
  ///
  ///  1. 400 ms
  ///  2. 800 ms
  ///  3. 1600 ms
  ///  4. 3200 ms
  ///  5. 6400 ms
  ///  6. 12800 ms
  ///  7. 25600 ms
  ///
  /// Before application of [percentageRandomization].
  final Duration initialDelay;

  /// Percentage the delay should be randomized, given as fraction between
  /// 0 and 1, (0.0 to 1.0 recommended).
  ///
  /// If [percentageRandomization] is `0.25` (default) this indicates 25 % of the
  /// delay should be increased or decreased by 25 %.
  final double percentageRandomization;

  /// Maximum delay between retries, defaults to 30 seconds.
  final Duration maxDelay;

  /// Maximum number of attempts before giving up, defaults to 8.
  final int maxAttempts;

  /// Function to determine if a retry should be attempted.
  ///
  /// If `null` (default) all errors will be retried.
  final FutureOr<bool> Function(Object error, StackTrace stackTrace, int attempt)? retryIf;

  /// {@macro BackOff}
  BackOff(
    this.func, {
    this.initialDelay = const Duration(milliseconds: 200),
    this.percentageRandomization = 0.25,
    this.maxDelay = const Duration(seconds: 30),
    this.maxAttempts = 8,
    this.retryIf,
  })  : assert(!initialDelay.isNegative, '❌ [Bad] [Duration] initialDelay must be positive!'),
        assert(!maxDelay.isNegative, '❌ [Bad] [Duration] maxDelay must be positive!'),
        assert(maxAttempts > 0, '❌ [Bad] [int] maxAttempts must be greater than 0!');

  Future<T> call() async {
    var attempt = 0;
    while (true) {
      attempt++; // first invocation is the first attempt.
      try {
        return await func();
      } catch (error, stackTrace) {
        final attemptLimitReached = attempt >= maxAttempts;
        if (attemptLimitReached) rethrow;

        final shouldRetry = await retryIf?.call(error, stackTrace, attempt);
        if (shouldRetry == false) rethrow;
      }

      // sleep for a delay.
      await Future.delayed(_getSleepDuration(attempt));
    }
  }

  // returns the sleep duration based on `attempt`.
  Duration _getSleepDuration(int attempt) {
    final rf = (percentageRandomization.clamp(0, 1) * (_rand.nextDouble() * 2 - 1) + 1);
    final exp = math.min(attempt, 31); // prevent overflows.
    final delay = (initialDelay * math.pow(2.0, exp) * rf);
    return delay < maxDelay ? delay : maxDelay;
  }
}
