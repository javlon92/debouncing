import 'dart:async';
import 'dart:ui';

/// {@template Debounce}
///
/// [Debounce] is used to control the frequency of function calls with support
/// for flexible delay and "leading" / "trailing" options.
///
/// This class is especially useful when you need to prevent frequent repeated calls:
/// - when entering text (for example, search)
/// - when processing scroll events
/// - when using resize handlers
/// - when pressing buttons (for example, double-click protection)
///
/// Supports:
/// - [delay] — How long to wait after the last call before executing
/// - [leading] — If `true`, [callback] will be called on the first call before the interval expires.
/// - [trailing] — If `true`, [callback] will be called after the interval ends
/// - [leading] && [trailing] If both are `true`, [leading] `callback` will be called immediately before the interval expires and [trailing] `callback` will be called after the interval ends (if there were repeated calls)
///
/// ### Usage example:
///
///     final _debounce = Debounce(delay: Duration(seconds: 1), leading: false, trailing: true); ✅ Good!
///     Config: leading: false, trailing: true
///     Input:  1-2-3---4---5-6-|
///     Output: ------3---4-----6|
///
///     final _debounce = Debounce(delay: Duration(seconds: 1), leading: true, trailing: false); ✅ Good!
///     Config: leading: true, trailing: false
///     Input:  1-2-3---4---5-6-|
///     Output: 1-------4---5---|
///
///     final _debounce = Debounce(delay: Duration(seconds: 1), leading: true, trailing: true); ✅ Good!
///     Config: leading: true, trailing: true
///     Input:  1-2-3---4---5-6-|
///     Output: 1-----3-4---5---6|
///
///     final _debounce = Debounce(delay: Duration(seconds: 1), leading: false, trailing: false); ❌ Bad! Output empty!
///     Config: leading: false, trailing: false
///     Input:  1-2-3---4---5-6-|
///     Output: ----------------|
///
/// ```dart
/// final _debounce = Debounce(delay: Duration(milliseconds: 500));
///
/// void onTextChanged(String text) {
///   _debounce(() {
///     // ...
///   });
/// }
///
/// @override
/// void dispose() {
///   _debounce.dispose();
///   super.dispose();
/// }
/// ```
///
/// {@endtemplate}
class Debounce {
  /// The default delay is 800 milliseconds.
  static const Duration defaultDelay = Duration(milliseconds: 800);

  /// User-defined delay between function calls.
  ///
  /// Defines how much time must pass after the last [call],
  /// before [callback] is executed if [trailing] is enabled.
  final Duration delay;

  /// If `true', [callback] is called immediately on the first call to [call].
  ///
  /// Convenient if you want an immediate reaction to an event.
  final bool leading;

  /// If `true', [callback] is called once at the end of the [delay].
  ///
  /// It is used to perform an action only after the event has ended.
  final bool trailing;

  /// An internal timer that controls the call delay [callback].
  Timer? _timer;

  /// The saved function is a callback that will be called after [delay].
  VoidCallback? _callback;

  /// Indicates whether this instance has been destroyed.
  ///
  /// After calling [dispose], the instance is considered inactive.
  bool _isDisposed = false;

  /// A flag indicating whether a call has already been made in [leading].
  bool _hasCalledLeading = false;

  /// If `true`, the [callback] call will be skipped at the end of the timer.
  bool _skipTrailing = false;

  /// - [isActive] — Returns `true` if the instance is active (has not been destroyed).
  bool get isActive => !_isDisposed;

  /// - [isNotActive] — Returns `true` if the instance was destroyed by calling [dispose]
  /// or both disabled: leading and trailing (both false).
  bool get isNotActive => _isDisposed || (leading == false && trailing == false);

  /// - [isTimerActive] — Returns `true` if the internal timer is currently active.
  bool get isTimerActive => _timer?.isActive ?? false;

  /*
  static final Finalizer<Debounce> _finalizer = Finalizer((debounce) {
    log('⚠️️ [WARNING] [Debounce] was deleted without [dispose]: You need to call [dispose]!');
    // ⚠️ [WARNING] If the 'developer' forgets to call [dispose] manually, the finalizer guarantees that [dispose] will be called automatically during 'Garbage collection'.
    debounce.dispose();
  });
  */

  /// {@macro Debounce}
  Debounce({this.delay = defaultDelay, this.leading = false, this.trailing = true})
      : assert(!delay.isNegative, '❌ [Bad] [Duration] delay must be positive!') {
    /*
     // We bind the finalizer to the [Debounce] object at the time of its creation.
     //
     // When the object is no longer in use (for example, it will be deleted by 'Garbage collectors'), the [_finalizer] will automatically call [dispose] for the [Debounce] object.
    _finalizer.attach(this, this, detach: this);
    */
  }

  /// Calls the [callback], taking into account the [leading] and [trailing] settings.
  ///
  /// - [leading] — If `true`, [callback] will be called on the first call before the interval expires.
  /// - [trailing] — If `true`, [callback] will be called after the interval ends
  /// - [leading] && [trailing] If both are `true`, [leading] `callback` will be called immediately before the interval expires and [trailing] `callback` will be called after the interval ends (if there were repeated calls)
  ///
  void call(VoidCallback callback) {
    if (isNotActive) return;

    // If the timer is already active, cancel it to restart the countdown.
    if (isTimerActive) _timer?.cancel();

    // If the "call immediately" leading = true, and we haven't called the callback yet, we execute it immediately.
    if (leading && !_hasCalledLeading) {
      callback();
      _hasCalledLeading = true; // That leading has already been called — do not call it again until the end of the loop
      _skipTrailing = true; // Setting the flag to not perform trailing later.
    } else if (trailing) {
      _skipTrailing = false; // If leading is not performed, trailing is allowed.
    }

    _callback = callback; // Saving the callback for a possible subsequent timer call.
    // We start the timer for the set delay.
    _timer = Timer(delay, () {
      _timer = null; // We clear the timer — it has ended.

      // Performing a callback if:
      // - trailing is allowed
      // - skipTrailing is not active (i.e. leading failed)
      // - the instance is not destroyed
      // - the callback still exists
      if (!_skipTrailing && trailing && isActive && _callback != null) {
        _callback?.call();
      }
      // After the execution or completion of the cycle:
      _hasCalledLeading = false; // Resetting the leading flag
      _callback = null; // Clearing the callback so that it does not hang in memory
    });
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
  /// final _debounce = Debounce(delay: const Duration(milliseconds: 300));
  ///
  /// void onTextChanged(String text) {
  ///   _debounce(() {
  ///     // ...
  ///   });
  /// }
  ///
  /// void reset() {
  ///   _debounce.reset();
  /// }
  /// ```
  void reset() {
    _timer?.cancel(); // Stop the timer if it is still running
    _timer = null; // Delete the timer reference to free up memory
    _callback = null; // Clearing the callback so that it does not hang in memory
    _hasCalledLeading = false; // Resetting the leading flag
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
  /// final _debounce = Debounce(delay: const Duration(milliseconds: 300));
  ///
  /// void onTextChanged(String text) {
  ///   _debounce(() {
  ///     // ...
  ///   });
  /// }
  ///
  /// void flush() {
  ///   _debounce.flush();
  /// }
  /// ```
  void flush() {
    if (isNotActive || _timer == null || _callback == null) return;
    _callback?.call();
    reset();
  }

  /// Destroys the [Debounce] instance and clears all internal data.
  ///
  /// After calling [dispose], any [call] and [flush] calls are ignored.
  ///
  /// ### Usage example:
  ///
  /// ```dart
  /// final _debounce = Debounce(delay: const Duration(milliseconds: 300));
  ///
  /// void onTextChanged(String text) {
  ///   _debounce(() {
  ///     // ...
  ///   });
  /// }
  ///
  /// void dispose() {
  ///   _debounce.dispose();
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
