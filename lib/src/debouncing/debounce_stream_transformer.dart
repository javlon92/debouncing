import 'dart:async';
import 'package:debouncing/debouncing.dart';

/// {@template ResettableEvent}
///
/// [ResettableEvent] for events that **reset the current debounce** if `resetOnlyPreviousEvent = true`
/// — debounce will be reset, but **will not initiate a new call**.
///
/// This is especially useful when you want to cancel a deferred action.
///
/// ---
///
/// ### ✅ Usage example with `sealed class`:
///
/// ```dart
/// sealed class SearchEvent {}
///
/// final class SearchTextWitOutResettableEvent extends SearchEvent {
///   final String text;
///   const SearchTextChanged({required this.text});
/// }
///
/// final class SearchTextWithResettableEvent extends SearchEvent with ResettableEvent {  // ⚠️ ... with ResettableEvent, ... extends ResettableEvent, ... implements ResettableEvent
///   @override
///   final bool resetOnlyPreviousEvent;
///   final String text;
///   SearchTextWithResettableEvent({required this.text, this.resetOnlyPreviousEvent = false});
/// }
/// ```
///
/// ### ✅ Usage example with `freezed`:
///
/// ```dart
/// @freezed
/// abstract class SearchEvent with _$SearchEvent {
///
///   @Implements<ResettableEvent>()
///   const factory SearchEvent.searchTextWithResettable({
///     required String text,
///     @Default(false) bool resetOnlyPreviousEvent,
///   }) = _SearchTextWithResettable;
///
///   const factory SearchEvent.searchTextWithoutResettable({
///     required String text,
///   }) = _SearchTextWithoutResettable;
/// }
/// ```
///
/// ---
///
/// If an event implements this [ResettableEvent] and returns `resetOnlyPreviousEvent = true`
///
/// then it:
/// - cancels the previous `Event`
/// - **will not**be passed on to the event handler (`on<Event>(...)`)
///
/// This is used in the `DebounceStreamTransformer`, for example:
///
/// ```dart
/// on<OnSearchEvent>(
///   _onSearchEvent,
///   transformer: debounceTransform(
///     delay: Duration(milliseconds: 500),
///     leading: false,
///     trailing: true,
///   ),
/// );
/// ```
/// {@endtemplate}
abstract mixin class ResettableEvent {
  /// - If `true`, the event cancels the previous deferred call (`debounce`),
  /// but **does not trigger** a new logic execution.
  ///
  /// - If `false', the event will be processed as normal.
  bool get resetOnlyPreviousEvent;

  /// {@macro ResettableEvent}
  const ResettableEvent();
}

/// {@template DebounceStreamTransformer}
///
/// [debounceTransform] — event transformer, which postpones
/// the call until the [delay] time has passed without new events.
///
/// Supports:
///
/// - [leading] — If `true`, [event] will be called on the first call before the interval expires.
/// - [trailing] — If `true`, [event] will be called after the interval ends
/// - [leading] && [trailing] If both are `true`, [leading] `event` will be called immediately before the interval expires and [trailing] `event` will be called after the interval ends (if there were repeated calls)
///
/// If the event implements [ResettableEvent] and returns `resetOnlyPreviousEvent = true`,
/// then the debounce will be reset, but the event itself is ignored.
///
/// ---
///
/// ### Usage example with [Bloc]:
///
///     source.debounceTransform(delay: Duration(seconds: 1), leading: false, trailing: true); ✅ Good!
///     Config: leading: false, trailing: true
///     Input:  1-2-3---4---5-6-|
///     Output: ------3---4-----6|
///
///     source.debounceTransform(delay: Duration(seconds: 1), leading: true, trailing: false); ✅ Good!
///     Config: leading: true, trailing: false
///     Input:  1-2-3---4---5-6-|
///     Output: 1-------4---5---|
///
///     source.debounceTransform(delay: Duration(seconds: 1), leading: true, trailing: true); ✅ Good!
///     Config: leading: true, trailing: true
///     Input:  1-2-3---4---5-6-|
///     Output: 1-----3-4---5---6|
///
///     source.debounceTransform(delay: Duration(seconds: 1), leading: false, trailing: false); ❌ Bad! Output empty!
///     Config: leading: false, trailing: false
///     Input:  1-2-3---4---5-6-|
///     Output: ----------------|
///
/// ```dart
/// on<OnSearchEvent>(
///   _onSearchEvent,
///   transformer: debounceTransform(
///     delay: Duration(milliseconds: 500),
///     leading: false,
///     trailing: true,
///   ),
/// );
/// ```
///
/// {@endtemplate}
MyEventTransformer<T> debounceTransform<T>({
  Duration delay = Debounce.defaultDelay,
  bool leading = false,
  bool trailing = true,
}) =>
    (events, mapper) => events
        .transform(
          DebounceStreamTransformer(
            delay: delay,
            leading: leading,
            trailing: trailing,
          ),
        )
        .asyncExpand(mapper);

/// [DebounceStreamTransformer] is a stream transformer for use with [Debounce].
///
/// Allows you to apply debounce to the event stream.
///
/// {@macro DebounceStreamTransformer}
class DebounceStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final Debounce _debounce;

  /// {@macro DebounceStreamTransformer}
  DebounceStreamTransformer({Duration delay = Debounce.defaultDelay, bool leading = false, bool trailing = true})
      : _debounce = Debounce(delay: delay, leading: leading, trailing: trailing);

  @override
  Stream<T> bind(Stream<T> stream) {
    late StreamController<T> controller;
    late StreamSubscription<T> subscription;

    controller = StreamController<T>(
      onListen: () {
        subscription = stream.listen(
          (event) {
            _debounce.reset();

            /// If the event is marked as resetting only, we do not process it
            if (event is ResettableEvent && event.resetOnlyPreviousEvent) return;

            _debounce.call(() {
              if (!controller.isClosed) {
                controller.add(event);
              }
            });
          },
          onError: controller.addError,
          onDone: () {
            _debounce.reset();
            controller.close();
          },
          cancelOnError: false,
        );
      },
      onPause: () => subscription.pause(),
      onResume: () => subscription.resume(),
      onCancel: () async {
        _debounce.reset();
        await subscription.cancel();
      },
      sync: true,
    );

    return controller.stream;
  }
}
