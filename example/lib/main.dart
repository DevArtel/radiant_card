import 'package:flutter/material.dart';
import 'package:radiant_card/radiant_card.dart';
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
  static const _widthInCards = 1;
  static const _heightInCards = 1;

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
      body: ImageContextWidget(
        imageFiles: const ["assets/images/pikachu.png", "assets/images/mask_1.png"], // todo maybe remove first image
        builder: (context, images) {
          return LayoutBuilder(builder: (context, constraints) {
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

                  return WidgetToImageBuilder(
                    child: Container(
                      color: Colors.blue,
                      alignment: Alignment.center,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'assets/images/den.jpg', // TODO make sure this image exists
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 80,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black,
                              child: const Text(
                                "УКЛАДКА ДЕРЖИТСЯ ИДЕАЛЬНО",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    builder: (context, widgetImage) => widgetImage == null
                        ? const SizedBox.shrink()
                        : RotatableShadedCard(
                            mainTexture: widgetImage,
                            mask: images[1],
                            centerPos: Vector3(cardCenterWorldXCoord, cardCenterWorldYCoord, 0),
                            worldSize: Size(cardWidth / containerWidth * _viewportWidth, cardHeight / containerWidth * _viewportWidth),
                          ),
                  );
                },
              ),
            );
          });
        },
        emptyBuilder: (context) => const SizedBox.shrink(),
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
