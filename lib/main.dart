import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ohso3d/src/glorious_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards demo'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
        children: List.generate(
          8,
          (index) => GloriousCard(
            maxAngle: pi / 6,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 5,
                  ),
                ],
                color: Color(Random(index).nextInt(pow(2, 32) as int)).withOpacity(1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
