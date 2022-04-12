import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isload = true;
  late File _image;
  List _predictions = [];

  get controller => null;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: "assets/labels.txt");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller?.dispose();
    super.dispose();
  }

  detect_image(File image) async {
    var prediction = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _isload = false;
      _predictions = prediction!;
    });
  }

  final imagePicker = ImagePicker();
  _loadeImageFromGallery() async {
    var image = await imagePicker.getImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image);
  }

  _loadeImageFromCamera() async {
    var image = await imagePicker.getImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);
    }
    detect_image(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Faace MaskDetections"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
              height: 200,
              width: 200,
              child: Image.asset("assets/mask.png"),
            ),
            Container(
              child: Text(
                "Detection",
                style: TextStyle(fontSize: 20),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              height: 70,
              padding: EdgeInsets.all(10),
              child: RaisedButton(
                child: Text(
                  "Camera",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _loadeImageFromCamera();
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              height: 70,
              padding: EdgeInsets.all(10),
              child: RaisedButton(
                child: Text(
                  "Gallery",
                  style: TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _loadeImageFromGallery();
                },
              ),
            ),
            _isload == false
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          child: Image.file(_image),
                        ),
                        Text(_predictions[0]['label'].toString())
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
