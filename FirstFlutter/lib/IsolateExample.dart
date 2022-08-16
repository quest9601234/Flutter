// Copyright 2019-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Computes the nth number in the Fibonacci sequence.
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PerformancePage(),
    );
  }
}
int fib(int n) {
  var a = n - 1;
  var b = n - 2;

  if (n == 1) {
    return 0;
  } else if (n == 0) {
    return 1;
  } else {
    return (fib(a) + fib(b));
  }
}

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  Future<void> computeFuture = Future.value();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SmoothAnimationWidget(),
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(top: 150),
            child: Column(
              children: [
                FutureBuilder(
                  future: computeFuture,
                  builder: (context, snapshot) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(elevation: 8.0),
                      onPressed:
                      snapshot.connectionState == ConnectionState.done
                          ? () => handleComputeOnMain(context)
                          : null,
                      child: const Text('Compute on Main'),
                    );
                  },
                ),
                FutureBuilder(
                  future: computeFuture,
                  builder: (context, snapshot) {
                    return ElevatedButton(
                        style: ElevatedButton.styleFrom(elevation: 8.0),
                        onPressed:
                        snapshot.connectionState == ConnectionState.done
                            ? () => handleComputeOnSecondary(context)
                            : null,
                        child: const Text('Compute on Secondary'));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleComputeOnMain(BuildContext context) {
    var future = computeOnMainIsolate()
      ..then((_) {
        print('Main Isolate Done!');
      });

    setState(() {
      computeFuture = future;
    });
  }

  void handleComputeOnSecondary(BuildContext context) {
    var future = computeOnSecondaryIsolateBySpawn()
      ..then((_) {
        print('Secondary Isolate Done!');
      });

    setState(() {
      computeFuture = future;
    });
  }

  Future<void> computeOnMainIsolate() async {
    // A delay is added here to give Flutter the chance to redraw the UI at
    // least once before the computation (which, since it's run on the main
    // isolate, will lock up the app) begins executing.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    fib(40);
  }

  Future<void> computeOnSecondaryIsolate() async {
    // Compute the Fibonacci series on a secondary isolate.
    await compute(fib, 40);
  }

  Future<void> computeOnSecondaryIsolateBySpawn() async {
    //main isolate
    var receivePort = ReceivePort();
    Isolate.spawn(taskFib, receivePort.sendPort);
    
    receivePort.listen((data) {
      print(data[0]);
      if(data[1] is SendPort){
        data[1].send("Main hello 2");
      }
    });

  }
  static void taskFib(SendPort sendPort){
    var receivePort = ReceivePort();

    receivePort.listen((message) {
      print(message);
    });
    //new isolate
    var result = fib(40);
    sendPort.send([result,receivePort.sendPort]);
  }
}


class SmoothAnimationWidget extends StatefulWidget {
  const SmoothAnimationWidget({super.key});

  @override
  State<SmoothAnimationWidget> createState() => _SmoothAnimationWidgetState();
}

class _SmoothAnimationWidgetState extends State<SmoothAnimationWidget>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<BorderRadius?> _borderAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);

    _borderAnimation = BorderRadiusTween(
        begin: BorderRadius.circular(100.0),
        end: BorderRadius.circular(0.0))
        .animate(_animationController);

    _animationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _borderAnimation,
        builder: (context, child) {
          return Container(
            alignment: Alignment.bottomCenter,
            width: 350,
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                colors: [
                  Colors.blueAccent,
                  Colors.redAccent,
                ],
              ),
              borderRadius: _borderAnimation.value,
            ),
            child: const FlutterLogo(
              size: 200,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}