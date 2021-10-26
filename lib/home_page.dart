import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:text_overlay_on_image/stack_image_text.dart';
import 'package:text_overlay_on_image/utils.dart';
import 'package:text_overlay_on_image/widget_to_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;

  bool gotLocation = false;

  String location = 'Null, Press Button';
  String Address = 'search';

  late GlobalKey key1;
  Uint8List? bytes;

  bool isSendingData = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    callGeolocationServices();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text("Home Page"),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WidgetToImage(
                  builder: (key) {
                    this.key1 = key;
                    return stack_image_and_text(
                        imageFile: _imageFile,
                        gotLocation: gotLocation,
                        location: location,
                        Address: Address);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                        onPressed: takePicture,
                        icon: Icon(Icons.camera),
                        label: Text("take picture")),
                    isSendingData == false
                        ? TextButton.icon(
                            onPressed: submitData,
                            icon: Icon(Icons.upload),
                            label: Text("Upload"))
                        : CircularProgressIndicator(),
                  ],
                ),
                //for debug purpose
                // bytes != null ? buildImage(bytes!) : Container(),
              ],
            ),
          ),
        ));
  }

  Future<void> takePicture() async {
    // print("image");
    final _picker = ImagePicker();
    final _pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    setState(() {
      _imageFile = File(_pickedImage!.path);
    });
  }

  Future<void> callGeolocationServices() async {
    Position position = await _getGeoLocationPosition();
    setState(() {
      location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
      gotLocation = true;
    });

    print("location is $location}");

    GetAddressFromLatLong(position);
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> GetAddressFromLatLong(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address =
        '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {});
  }

  submitData() async {
    if (_imageFile != null) {
      setState(() {
        isSendingData = true;
      });
      // print("Submit data");
      final bytes = await Utils.capture(key1);
      setState(() {
        this.bytes = bytes;
      });

      print(base64.encode(bytes));

      Map<String, dynamic> bodyData = {
        "byteImage": base64.encode(bytes).toString()
      };
      String bodyJsonData = jsonEncode(bodyData);

      // print("data going ${bodyJsonData}");

      var serverResponse = await http.post(
          Uri.parse(
              "https://thedigitalgamezone.com/Abhi/save_byte_to_image.php"),
          body: bodyJsonData);
      if (serverResponse.statusCode == 200) {
        setState(() {
          isSendingData = false;
          //clearing image when sent successfully
          _imageFile = null;
        });

        Map<String, dynamic> responseData = jsonDecode(serverResponse.body);
        print("response data $responseData");
      } else {
        setState(() {
          isSendingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("no response"),
          backgroundColor: Colors.cyan,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please Capture Image First"),
        backgroundColor: Colors.cyan,
      ));
    }
  }

  buildImage(Uint8List bytes) {
    if (bytes != null) {
      return Image.memory(bytes);
    } else {
      return Container();
    }
  }
}
