import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _predictedClass = 'Unknown';
  File? _image;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
      );
      print('new world');
      classifyImage(null);
    } on PlatformException {
      print("Failed to load model.");
    }
  }

  Future<void> getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    print("hello world 1");

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        classifyImage(_image!);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> classifyImage(File? image) async {
    // await Tflite.close();
    // if (image == null) return;
    print("hello world 2");

    try {
      print("k");
      var results = await Tflite.runModelOnImage(
        path: 'assets/thulasi.jpeg',
        imageMean: 117.0,
        imageStd: 1.0,
        threshold: 0.1,
        asynch: true,
      );
      print("hello world 3");
      if (results != null && results.isNotEmpty) {
        final label = results[0]['label'];
        setState(() {
          _predictedClass = label;
        });
      } else {
        print('No results or an error occurred.');
      }
    } catch (e) {
      print('Error during TFLite inference: $e');
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Classifier'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('Select an image from the gallery.')
                : Image.file(_image!, height: 150, width: 150),
            SizedBox(height: 20),
            Text('Predicted Plant: $_predictedClass'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImageFromGallery,
        tooltip: 'Pick Image',
        child: Icon(Icons.image),
      ),
    );
  }
}
