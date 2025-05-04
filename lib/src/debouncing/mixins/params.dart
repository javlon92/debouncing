part of 'mixins.dart';

/// {@template DebounceParams}
///
/// Configuration of parameters for [Debounce].
///
/// Used inside the mixins [DebounceMixin], [DebounceStateMixin], [DebounceNotifierMixin], [DebounceGetXMixin] to configure:
/// - [delay] — delay between calls;
/// - [leading] — whether to call a [callback] at the beginning of the delay;
/// - [trailing] — whether to call a [callback] at the end of the delay.
///
/// {@endtemplate}
class DebounceParams {
  /// Delay time between calls (default is [Debounce.defaultDelay]).
  final Duration delay;

  /// If `true', the callback is called at the beginning of the delay (default is `false`).
  final bool leading;

  /// If `true', the callback is called at the end of the delay (default is `true').
  final bool trailing;

  /// {@macro DebounceParams}
  const DebounceParams({
    this.delay = Debounce.defaultDelay,
    this.leading = false,
    this.trailing = true,
  });
}
