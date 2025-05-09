/// {@template ResettableEvent}
///
/// [ResettableEvent] for events that **reset the current debounce or throttle** if `resetOnlyPreviousEvent = true`
/// — debounce or throttle will be reset, but **will not initiate a new call**.
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
/// This is used in the `DebounceStreamTransformer` and `ThrottleStreamTransformer`, for example:
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
///
/// on<OnScrollEvent>(
///   _onScrollEvent,
///   transformer: throttleTransform(
///     interval: Duration(milliseconds: 500),
///     leading: true,
///     trailing: false,
///   ),
/// );
/// ```
/// {@endtemplate}
abstract mixin class ResettableEvent {
  /// - If `true`, the event cancels the previous deferred call (`debounce`) or (`throttle`),
  /// but **does not trigger** a new logic execution.
  ///
  /// - If `false', the event will be processed as normal.
  bool get resetOnlyPreviousEvent;

  /// {@macro ResettableEvent}
  const ResettableEvent();
}
