import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class Utils {
  static capture(GlobalKey key) async {
    if (key == null) {
      return null;
    } else {
      RenderRepaintBoundary? _boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      final image = await _boundary!.toImage(pixelRatio: 3);

      print("image $image");

      final _byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngByte = _byteData!.buffer.asUint8List();

      // print("byte is $pngByte");
      return pngByte;
    }
  }
}
