import 'dart:async';

import 'package:flutter/material.dart';
import 'MyStream.dart';

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);



  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MyStream myStream = MyStream();

  @override
  void initState() {
  }

  void _incrementCounter() {
  }

  @override
  Widget build(BuildContext context) {
    // myStream.listen((event) {
    //   print(event.toString());
    // });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            StreamBuilder(
                stream: myStream.counterStream,
                builder: (BuildContext context, AsyncSnapshot snapshot){

                  return  Text(
                    snapshot.hasData ? snapshot.data.toString() : "0",
                    style: Theme.of(context).textTheme.displayMedium,
                  );
                }
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          myStream.increment();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    myStream.dispose();
    super.dispose();
  }
}