part of 'mixins.dart';

/// {@template ThrottleParams}
///
/// Configuration of parameters for [Throttle].
///
/// Used inside the mixins [ThrottleMixin], [ThrottleStateMixin], [ThrottleNotifierMixin], [ThrottleGetXMixin] to configure:
/// - [interval] — interval between calls;
/// - [leading] — whether to call a callback at the beginning of the interval;
/// - [trailing] — whether to call a callback at the end of the interval.
///
/// {@endtemplate}
class ThrottleParams {
  /// The interval between calls (default [Throttle.interval 2 Hz] = 500 ms).
  final Duration interval;

  /// If `true', the callback is called at the beginning of the interval (default is `true').
  final bool leading;

  /// If `true', the callback is called at the end of the interval (default is `false`).
  final bool trailing;

  /// {@macro ThrottleParams}
  const ThrottleParams({
    this.interval = Throttle.interval2Hz,
    this.leading = true,
    this.trailing = false,
  });
}
