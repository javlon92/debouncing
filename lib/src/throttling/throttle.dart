import 'dart:async';
import 'dart:ui';

/// {@template Throttle}
///
/// [Throttle] is used to limit the frequency of function calls. This class allows
/// to call a function with a specified delay, and the call will occur **no more than once in [interval]**.
/// To control the behavior, you can use the [leading] and [trailing] parameters.
///
/// - Protection against repeated clicks on the button
/// - Limitation of the frequency of updates in the UI
/// - Performance management when processing events, such as scrolling or resizing a window
///
/// Depending on the values of [leading] and [trailing], you can configure whether the function call occurs
/// at the beginning of the interval (leading) or at the end (trailing).
///
/// - [interval] — the interval at which the function can be called (500 ms by default) is [interval2Hz].
/// - [leading] — If `true`, [callback] will be called on the first call before the interval expires.
/// - [trailing] — If `true`, [callback] will be called after the interval ends
/// - [leading] && [trailing] If both are `true`, [leading] `callback` will be called immediately before the interval expires and [trailing] `callback` will be called after the interval ends (if there were repeated calls)
///
/// ---
///
/// ### Usage example:
///
///     final _throttle = Throttle(interval: const Duration(seconds: 6), leading: true, trailing: false); ✅ Good!
///     Config: leading: true, trailing: false
///     Input:  1-2-3---4-5-6---7-8-|
///     Output: 1-------4-------7---|
///
///     final _throttle = Throttle(interval: const Duration(seconds: 6), leading: false, trailing: true); ✅ Good!
///     Config: leading: false, trailing: true
///     Input:  1-2-3---4-5----6--|
///     Output: ------3-----5-----6|
///
///     final _throttle = Throttle(interval: const Duration(seconds: 6),  leading: true, trailing: true); ✅ Good!
///     Config: leading: true, trailing: true
///     Input:  1-2-----3-----4|
///     Output: 1-----2-----3--|
///
///     final _throttle = Throttle(interval: const Duration(seconds: 6), leading: false, trailing: false); ❌ Bad! Output empty!
///     Config: leading: false, trailing: false
///     Input:  1-2-3---4-5----6--|
///     Output: -------------------|
///
/// ```dart
/// final _throttle = Throttle(interval: const Duration(milliseconds: 300));
///
/// void onScroll() {
///   _throttle(() {
///     // ...
///   });
/// }
///
/// @override
/// void dispose() {
///   _throttle.dispose();
///   super.dispose();
/// }
/// ```
///
/// {@endtemplate}
class Throttle {
  /*
  static final Finalizer<Throttle> _finalizer = Finalizer((throttle) {
    log('⚠️️ [WARNING] [Throttle] was deleted without [dispose]: You need to call [dispose]!');
    // ⚠️ [WARNING] If the 'developer' forgets to call [dispose] manually, the finalizer guarantees that [dispose] will be called automatically during 'Garbage collection'.
    throttle.dispose();
  });
  */

  /// {@macro Throttle}
  Throttle({this.interval = interval2Hz, this.leading = true, this.trailing = false})
      : assert(!interval.isNegative, '❌ [Bad] [Duration] interval must be positive!') {
    /*
     // We bind the finalizer to the [Throttle] object at the time of its creation.
     //
     // When the object is no longer in use (for example, it will be deleted by 'Garbage collectors'), the [_finalizer] will automatically call [dispose] for the [Throttle] object.
    _finalizer.attach(this, this, detach: this);
    */
  }

  /// [Throttle.from24Hz] Constructor for the frequency of 24 Hz (interval 41.67 ms).
  ///
  /// {@macro Throttle}
  Throttle.from24Hz({bool leading = true, bool trailing = false})
      : this.fromHz(hz: 24, leading: leading, trailing: trailing);

  /// [Throttle.from48Hz] Constructor for the frequency of 48 Hz (interval 20.83 ms).
  ///
  /// {@macro Throttle}
  Throttle.from48Hz({bool leading = true, bool trailing = false})
      : this.fromHz(hz: 48, leading: leading, trailing: trailing);

  /// [Throttle.from60Hz] Constructor for the frequency of 60 Hz (interval 16.67 ms).
  ///
  /// {@macro Throttle}
  Throttle.from60Hz({bool leading = true, bool trailing = false})
      : this.fromHz(hz: 60, leading: leading, trailing: trailing);

  /// [Throttle.from120Hz] The constructor for the frequency of 120 Hz (interval 8.33 ms).
  ///
  /// {@macro Throttle}
  Throttle.from120Hz({bool leading = true, bool trailing = false})
      : this.fromHz(hz: 120, leading: leading, trailing: trailing);

  /// [Throttle.fromHz] Constructor if you need a non-standard frequency
  ///
  /// {@macro Throttle}
  Throttle.fromHz({required double hz, bool leading = true, bool trailing = false})
      : this(
          interval: Duration(microseconds: Duration.microsecondsPerSecond ~/ hz),
          leading: leading,
          trailing: trailing,
        );

  /// - [interval2Hz] — A static constant for the interval of 2 Hz (500 ms).
  static const Duration interval2Hz = Duration(microseconds: Duration.microsecondsPerSecond ~/ 2);

  /// A flag indicating whether the object has been destroyed.
  bool _isDisposed = false;

  /// The time interval during which the [callback] can be called.
  final Duration interval;

  /// If true, the [callback] will be called on the first call (leading = true).
  final bool leading;

  /// If true, the [callback] will be called at the end of the interval (trailing = true).
  final bool trailing;

  /// An internal timer to limit the frequency of [callback] calls.
  Timer? _timer;

  /// The last transferred [callback].
  VoidCallback? _lastCallback;

  /// A flag indicating whether the trolling process is underway.
  bool _isThrottling = false;

  /// - [isActive] — Returns `true` if the object is active (has not been destroyed).
  bool get isActive => !_isDisposed;

  /// - [isNotActive] — Returns `true` if the instance was destroyed by calling [dispose]
  /// or both disabled: leading and trailing (both false).
  bool get isNotActive => _isDisposed || (leading == false && trailing == false);

  /// - [isTimerActive] — Returns `true` if the timer is active.
  bool get isTimerActive => _timer?.isActive ?? false;

  /// Deferred calls the transmitted [callback], no more than once per [interval].
  ///
  /// - [leading] — If `true`, [callback] will be called on the first call before the interval expires.
  /// - [trailing] — If `true`, [callback] will be called after the interval ends
  /// - [leading] && [trailing] If both are `true`, [leading] `callback` will be called immediately before the interval expires and [trailing] `callback` will be called after the interval ends (if there were repeated calls)
  ///
  void call(VoidCallback callback) {
    if (isNotActive) return;

    if (!_isThrottling) {
      _isThrottling = true; // We set the flag that the throttling will begin

      if (leading) {
        // If you need to call the function immediately (leading = true)
        callback();
      } else if (trailing) {
        // If leading is not performed, trailing is allowed.
        _lastCallback = callback; // Saving the callback for later execution
      }

      void startTimer() {
        _timer = Timer(interval, () {
          if (trailing && isActive && _lastCallback != null) {
            // If trailing is enabled, the object is still active and there is a deferred callback.
            _lastCallback?.call(); // Executing the last saved callback
            _lastCallback = null; // We clean the callback so that it does not hang in memory.

            // Starting a new interval while the calls are in progress
            startTimer();
          } else {
            _timer = null; // Deleting the timer reference to free up memory
            _lastCallback = null; // We clean the callback so that it does not hang in memory.
            _isThrottling = false; // Resetting the throttling flag
          }
        });
      }

      // Starting the timer with a throttle interval
      startTimer();
    } else if (trailing) {
      // If throttling is already active and trailing is enabled
      _lastCallback = callback; // Updating the latest callback
    }
  }

  /// Resets the current timer and clears the callback.
  ///
  /// This [reset] method cancels the execution of the current timer, if it was active,
  /// and releases the resources associated with the timer and callback. It is useful for
  /// preventing unwanted repeat calls when needed.
  /// cancel previous scheduled actions before scheduling new ones.
  ///
  /// ### Usage example:
  ///
  /// ```dart
  /// final _throttle = Throttle(interval: const Duration(milliseconds: 300));
  ///
  /// void onButtonPressed() {
  ///   _throttle(() {
  ///     // ...
  ///   });
  /// }
  ///
  /// void reset() {
  ///   _throttle.reset();
  /// }
  /// ```
  void reset() {
    _timer?.cancel(); // Stop the timer if it is still running
    _timer = null; // Delete the timer reference to free up memory
    _lastCallback = null; // Clearing the callback so that it does not hang in memory
    _isThrottling = false; // Resetting the throttling flag
  }

  /// Immediately performs a delayed callback if the timer is still active.
  ///
  /// - Stops the timer
  /// - Calls the last saved callback
  ///
  /// If the timer has already been triggered or the instance has been destroyed, nothing will happen.
  ///
  /// ### Usage example:
  ///
  /// ```dart
  /// final _throttle = Throttle(interval: const Duration(milliseconds: 300));
  ///
  /// void onButtonPressed() {
  ///   _throttle(() {
  ///     // ...
  ///   });
  /// }
  ///
  /// void flush() {
  ///   _throttle.flush();
  /// }
  /// ```
  void flush() {
    if (isNotActive || !_isThrottling || _lastCallback == null) return;
    _lastCallback?.call();
    reset();
  }

  /// Destroys the [Throttle] instance and clears all internal data.
  ///
  /// After calling [dispose], any [call] calls are ignored.
  ///
  /// ### Usage example:
  ///
  /// ```dart
  /// final _throttle = Throttle(interval: const Duration(milliseconds: 300));
  ///
  /// void onButtonPressed() {
  ///   _throttle(() {
  ///     // ...
  ///   });
  /// }
  ///
  /// void dispose() {
  ///   _throttle.dispose();
  /// }
  /// ```
  void dispose() {
    _isDisposed = true; // Marking the [Debounce] object as "destroyed"
    reset();
    /*
    _finalizer.detach(this); // Untying the _finalizer and disabling monitoring
    */
  }
}
