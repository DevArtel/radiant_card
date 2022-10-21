import 'package:flutter/material.dart';
import 'package:ohso3d/glorious_card.dart';

///
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'This is going ot be awesome',
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: GloriousCard(
                  aspectRatio: 1,
                  cornerRadius: 16,
                  maxAngleX: 100,
                  maxAngleY: 100,
                  elevation: 20,
                  child: Text('hi'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
