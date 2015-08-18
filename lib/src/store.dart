library w_flux.store;

import 'dart:async';

import 'package:w_flux/src/action.dart';

class Store {
  StreamController<Store> _streamController;
  Stream<Store> _stream;

  Store({StreamTransformer transformer}) {
    _streamController = new StreamController<Store>();

    // apply a transform to the stream if supplied
    if (transformer != null) {
      _stream = _streamController.stream.transform(transformer).asBroadcastStream();
    } else {
      _stream = _streamController.stream.asBroadcastStream();
    }
  }

  void trigger() {
    _streamController.add(this);
  }

  triggerOnAction(Action action, [void onAction(payload)]) {
    if (onAction != null) {
      action.listen((payload) async {
        await onAction(payload);
        trigger();
      });
    } else {
      action.listen((_) {
        trigger();
      });
    }
  }

  StreamSubscription<Store> listen(void onData(Store event),
      {Function onError, void onDone(), bool cancelOnError}) {
    return _stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}