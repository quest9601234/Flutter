import 'dart:async';

class MyStream {
  int counter = 0;
  // StreamController counterController = StreamController<int>();
  StreamController counterController = StreamController<int>.broadcast();
  Stream get counterStream => counterController.stream.transform(counterTranformer);

  var counterTranformer = StreamTransformer<int, int>.fromHandlers(handleData: (data, sink) {
    data += 5;
    sink.add(data);
  });

  void increment() {
    counter += 1;
    counterController.sink.add(counter);
  }

  void dispose() {
    counterController.close();
  }
}