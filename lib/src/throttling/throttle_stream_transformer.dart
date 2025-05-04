import 'dart:async';
import 'package:debouncing/debouncing.dart';

/// {@template ThrottleStreamTransformer}
///
/// [throttleTransform] - event transformer for the [Bloc] that limits the frequency of event processing.
///
/// Uses [Throttle] in order to process events no more than once in the specified [interval].
///
/// Supports:
///
/// - [leading] — If `true`, [event] will be called on the first call before the interval expires.
/// - [trailing] — If `true`, [event] will be called after the interval ends
/// - [leading] && [trailing] If both are `true`, [leading] `event` will be called immediately before the interval expires and [trailing] `event` will be called after the interval ends (if there were repeated calls)
///
///
/// ---
///
/// ### Usage example with [Bloc]:
///
///     source.throttleTransform(interval: const Duration(seconds: 6), leading: true, trailing: false); ✅ Good!
///     Config: leading: true, trailing: false
///     Input:  1-2-3---4-5-6---7-8-|
///     Output: 1-------4-------7---|
///
///     source.throttleTransform(interval: const Duration(seconds: 6), leading: false, trailing: true); ✅ Good!
///     Config: leading: false, trailing: true
///     Input:  1-2-3---4-5----6--|
///     Output: ------3-----5-----6|
///
///     source.throttleTransform(interval: const Duration(seconds: 6),  leading: true, trailing: true); ✅ Good!
///     Config: leading: true, trailing: true
///     Input:  1-2-----3-----4|
///     Output: 1-----2-----3--|
///
///     source.throttleTransform(interval: const Duration(seconds: 6), leading: false, trailing: false); ❌ Bad! Output empty!
///     Config: leading: false, trailing: false
///     Input:  1-2-3---4-5----6--|
///     Output: -------------------|
///
/// ```dart
/// on<OnScrollEvent>(
///   _onScrollEvent,
///   transformer: throttleTransform(
///     interval: Duration(milliseconds: 500),
///     leading: true,
///     trailing: false,
///   ),
/// );
/// ```
///
/// {@endtemplate}
MyEventTransformer<T> throttleTransform<T>({
  Duration interval = Throttle.interval2Hz,
  bool leading = true,
  bool trailing = false,
}) =>
    (events, mapper) => events
        .transform(
          ThrottleStreamTransformer(
            interval: interval,
            leading: leading,
            trailing: trailing,
          ),
        )
        .asyncExpand(mapper);

/// [ThrottleStreamTransformer] — a stream transformer for use with [Throttle].
///
/// Allows you to apply trolling to the event stream.
///
/// {@macro ThrottleStreamTransformer}
class ThrottleStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final Throttle _throttle;

  /// {@macro ThrottleStreamTransformer}
  ThrottleStreamTransformer({Duration interval = Throttle.interval2Hz, bool leading = true, bool trailing = false})
      : _throttle = Throttle(interval: interval, leading: leading, trailing: trailing);

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamController<T> controller;
    late StreamSubscription<T> subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = stream.listen(
          (event) {
            _throttle.call(() {
              if (!controller.isClosed) {
                controller.add(event);
              }
            });
          },
          onError: controller.addError,
          onDone: () {
            _throttle.reset();
            controller.close();
          },
          cancelOnError: false,
        );
      },
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      onCancel: () async {
        _throttle.reset();
        await subscription.cancel();
      },
      sync: true,
    );

    return controller.stream;
  }
}
