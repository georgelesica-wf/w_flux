library w_flux.action;

import 'dart:async';

/// A command that can be dispatched and listened to.
///
/// An [Action] manages a collection of listeners and the manner of
/// their invocation. It *does not* rely on [Stream] for managing listeners. By
/// managing it's own listeners, an [Action] can track a [Future] that
/// completes when all registered listeners have completed. This allows
/// consumers to use `await` to wait for an action to finish processing.
///
///     var asyncListenerCompleted = false;
///     action.listen((_) async {
///       await new Future.delayed(new Duration(milliseconds: 100), () {
///         asyncListenerCompleted = true;
///       });
///     });
///
///     var future = action();
///     print(asyncListenerCompleted); // => 'false'
///
///     await future;
///     print(asyncListenerCompleted). // => 'true'
///
/// Providing a [Future] for listener completion makes actions far easier to use
/// when a consumer needs to check state changes immediately after invoking an
/// action.
///
class Action<T> implements Function {
  List _listeners = [];

  Future call([T payload]) {
    // Invoke all listeners in a microtask to enable waiting on futures. The
    // microtask queue is emptied before the event loop continues. This ensures
    // synchronous listeners are invoked in the current tick of the event loop
    // without being scheduled at the back of the event queue. A Dart [Stream]
    // behaves in a similar fashion.
    //
    // Performance benchmarks over 10,000 samples show no performance
    // degradation when dispatching actions using this action implementation vs
    // the [Stream]-based action implementation in w_flux. At smaller sample
    // sizes this implementation slows down in comparison, yielding average
    // times of 0.1 ms for w_flux actions vs. 0.14 ms for awaitable actions.
    return Future.wait(_listeners.map((l) => new Future.microtask(() => l(payload))));
  }

  ActionSubscription listen(void onData(T event)) {
    _listeners.add(onData);
    return new ActionSubscription(() => _listeners.remove(onData));
  }
}

/// A subscription used to cancel registered listeners to an [Action].
class ActionSubscription {
  final Function _onCancel;

  ActionSubscription(this._onCancel);

  void cancel() {
    if (_onCancel != null) {
      _onCancel();
    }
  }
}

/// An event that wraps payloads sent through a [Action].
///
/// This object facilitates the following:
/// - actions can be identified when filtering the central [Stream].
/// - a future can be resolved after an action is "complete".
class ActionEvent<T> {
  final Action action;
  final Completer completer = new Completer();
  final T originalPayload;

  ActionEvent(this.action, this.originalPayload);
}
