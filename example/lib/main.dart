import 'package:flutter/material.dart';
import 'package:ohso3d/ohso3d.dart';
import 'package:vector_math/vector_math.dart' hide Colors;

void main() {
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _widthInCards = 3;
  static const _heightInCards = 10;

  static const _viewportWidth = 1;

  static const _gridViewPadding = 16.0;
  static const _cardSpacing = 8.0;
  static const _cardAspectRatio = 711.0 / 990.0;

  final _controller = ScrollController();

  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _scrollPosition = _controller.offset;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cards demo'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final containerWidth = constraints.maxWidth;
          final containerHeight = constraints.maxHeight;
          final cardWidth = (containerWidth - 2 * _gridViewPadding - (_widthInCards - 1) * _cardSpacing) / _widthInCards;
          final cardHeight = cardWidth / _cardAspectRatio;
          return GridView.count(
            padding: const EdgeInsets.all(_gridViewPadding),
            crossAxisCount: _widthInCards,
            crossAxisSpacing: _cardSpacing,
            mainAxisSpacing: _cardSpacing,
            childAspectRatio: _cardAspectRatio,
            controller: _controller,
            children: List.generate(
              _widthInCards * _heightInCards,
              (index) {
                final i = index % _widthInCards;
                final j = index ~/ _widthInCards;

                final cardCenterContainerXCoord = _gridViewPadding + i * (cardWidth + _cardSpacing) + cardWidth / 2 - containerWidth / 2;
                final cardCenterContainerYCoord = _gridViewPadding + j * (cardHeight + _cardSpacing) + cardHeight / 2 - containerHeight / 2;

                final cardCenterWorldXCoord = cardCenterContainerXCoord / containerWidth * _viewportWidth;
                final cardCenterWorldYCoord = (cardCenterContainerYCoord - _scrollPosition) * _viewportWidth / containerWidth;

                // print("cardCenterWorldCoord($i, $j) = (${cardCenterWorldXCoord.toStringAsFixed(3)}, ${cardCenterWorldYCoord.toStringAsFixed(3)})");

                return ShadedCard(
                  // mainTextureFile: "assets/images/img.png",
                  mainTextureFile: "assets/images/pikachu.png",
                  maskFile: "assets/images/mask_1.png",
                  centerPos: Vector3(cardCenterWorldXCoord, cardCenterWorldYCoord, 0),
                  worldSize: Size(cardWidth / containerWidth * _viewportWidth, cardHeight / containerWidth * _viewportWidth),
                );
                // return Container(color: Colors.red);
              },
            ),
          );
        }
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () {
          setState(() {});
        },
      ),
    );
  }
}
