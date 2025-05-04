/// Signature for a function which converts an incoming event
/// into an outbound stream of events.
typedef MyEventMapper<Event> = Stream<Event> Function(Event event);

/// Used to change how events are processed.
typedef MyEventTransformer<Event> = Stream<Event> Function(Stream<Event> events, MyEventMapper<Event> mapper);
