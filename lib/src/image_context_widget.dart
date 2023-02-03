import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TODO image caching
Future<ui.Image> _getImage(String file) async {
  final asset = await rootBundle.load(file);
  final image = await decodeImageFromList(asset.buffer.asUint8List());
  return image;
}

// TODO maybe the widget should handle only on image
class ImageContextWidget extends StatefulWidget {
  final List<String> imageFiles;
  final Function(BuildContext, List<ui.Image>) builder;
  final WidgetBuilder emptyBuilder;

  const ImageContextWidget({
    Key? key,
    required this.imageFiles,
    required this.builder,
    required this.emptyBuilder,
  }) : super(key: key);

  @override
  State<ImageContextWidget> createState() => _ImageContextWidgetState();
}

class _ImageWrapper {
  final ui.Image? image;
  final bool hasError;

  _ImageWrapper(this.image, this.hasError);

  factory _ImageWrapper.loading() => _ImageWrapper(null, false);

  factory _ImageWrapper.value(ui.Image image) => _ImageWrapper(image, false);

  factory _ImageWrapper.error() => _ImageWrapper(null, true);
}

class _ImageContextWidgetState extends State<ImageContextWidget> {
  final Map<String, _ImageWrapper> imageMap = {};

  @override
  void initState() {
    super.initState();
    for (var imageFile in widget.imageFiles) {
      imageMap[imageFile] = _ImageWrapper.loading();
    }
    Future.wait(
      widget.imageFiles.map(
        (imageFile) => _getImage(imageFile)
            .then((image) => imageMap[imageFile] = _ImageWrapper.value(image))
            .catchError((e) => imageMap[imageFile] = _ImageWrapper.error()),
      ),
    ).then((value) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    bool hasError = imageMap.values.every((element) => element.hasError);
    bool isReady = imageMap.values.every((element) => element.image != null);
    return (hasError || !isReady)
        ? widget.emptyBuilder(context)
        : widget.builder(context, imageMap.values.map((e) => e.image!).toList());
  }

  @override
  void dispose() {
    super.dispose();
    imageMap.clear();
  }
}
