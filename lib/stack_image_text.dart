import 'dart:io';

import 'package:flutter/material.dart';

class stack_image_and_text extends StatelessWidget {
  const stack_image_and_text({
    Key? key,
    required File? imageFile,
    required this.gotLocation,
    required this.location,
    required this.Address,
  })  : _imageFile = imageFile,
        super(key: key);

  final File? _imageFile;
  final bool gotLocation;
  final String location;
  final String Address;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // key: Key("stackkey"),
      alignment: Alignment.bottomCenter,
      children: [
        _imageFile != null
            ? Image.file(
                _imageFile!,
              )
            : Container(),
        Container(
          alignment: Alignment.bottomLeft,
          child: _imageFile != null
              ? gotLocation
                  ? Text("location is $location $Address",
                      style: const TextStyle(
                          color: Colors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.0))
                  : Container()
              : Container(),
        ),
      ],
    );
  }
}
