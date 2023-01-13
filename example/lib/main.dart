import 'package:flutter/material.dart';
import 'package:ohso3d/glossy_card.dart';
import 'package:ohso3d/single_card_widget.dart';

void main() async {
  await initPhongShader();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards demo'),
      ),
      body: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        crossAxisCount: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 711.0 / 990.0,
        children: List.generate(
          1,
          (index) => const SingleCardWidget(),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
