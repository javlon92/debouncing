part of 'd_example_1_bloc.dart';

// ---------------------------------------------------------------------------------------------------------------------

/*

@freezed
abstract class DebounceExample2Event with _$DebounceExample2Event {

  /// Example event 1 with Resettable
  @Implements<ResettableEvent>()
  const factory DebounceExample2Event.onSearchWithResettable({
    required String text,
    @Default(false) bool resetOnlyPreviousEvent,
  }) = OnSearchWithResettable;

  const factory DebounceExample2Event.onChangedWithResettable({
    required String text,
  }) = OnChangedWithResettable;

// ---------------------------------------------------------------------------------------------------------------------

  /// Example event 2 without Resettable
  const factory DebounceExample2Event.onSearchWithoutResettable({
    required String text,
  }) = OnSearchWithoutResettable;

  const factory DebounceExample2Event.onChangedWithoutResettable({
    required String text,
  }) = OnChangedWithoutResettable;
}

*/

// ---------------------------------------------------------------------------------------------------------------------

sealed class DebounceExample1Event with EquatableMixin {
  const DebounceExample1Event();
}

/// Example event 1 with Resettable
final class OnSearchWithResettable extends DebounceExample1Event with ResettableEvent { // ⚠️ ... with ResettableEvent, ... extends ResettableEvent, ... implements ResettableEvent
  @override
  final bool resetOnlyPreviousEvent;
  final String text;

  const OnSearchWithResettable({required this.text, this.resetOnlyPreviousEvent = false});

  @override
  List<Object> get props => [text, resetOnlyPreviousEvent];
}

final class OnChangedWithResettable extends DebounceExample1Event {
  final String text;

  const OnChangedWithResettable({required this.text});

  @override
  List<Object?> get props => [text];
}
// ---------------------------------------------------------------------------------------------------------------------

/// Example event 2 without Resettable
final class OnSearchWithoutResettable extends DebounceExample1Event {
  final String text;

  const OnSearchWithoutResettable({required this.text});

  @override
  List<Object> get props => [text];
}

final class OnChangedWithoutResettable extends DebounceExample1Event {
  final String text;

  const OnChangedWithoutResettable({required this.text});

  @override
  List<Object?> get props => [text];
}

// ---------------------------------------------------------------------------------------------------------------------
