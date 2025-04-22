import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionPage extends StatefulWidget {
  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  bool _isLoading = false;
  bool _isModelLoaded = false;
  String _prediction = 'Please select an image.';
  Interpreter? _interpreter;

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _prediction = 'Loading model...';
    });

    try {
      _interpreter = await Interpreter.fromAsset('lib/models/vgg19_stroke_model.tflite');
      print('Model loaded successfully');
      print('Input tensor: ${_interpreter!.getInputTensor(0).shape}');
      print('Output tensor: ${_interpreter!.getOutputTensor(0).shape}');
      
      setState(() {
        _isModelLoaded = true;
        _prediction = 'Model loaded successfully. Please select an image.';
      });
    } catch (e) {
      print('Failed to load model: $e');
      setState(() {
        _prediction = 'Error: Failed to load model. Please make sure the model file is included in lib/models.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ... existing code ...

  Future<void> _predictImage(XFile imageFile) async {
    if (!_isModelLoaded) {
      setState(() {
        _prediction = 'Please load the model first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _prediction = 'Predicting...';
    });

    try {
      var imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        setState(() {
          _prediction = 'Error: Failed to decode image.';
        });
        return;
      }

      // Resize to 224x224 and convert to RGB if needed
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      if (resizedImage.numChannels != 3) {
        // Convert to RGB by creating a new RGB image
        var rgbImage = img.Image(width: 224, height: 224, numChannels: 3);
        for (var y = 0; y < resizedImage.height; y++) {
          for (var x = 0; x < resizedImage.width; x++) {
            var pixel = resizedImage.getPixel(x, y)[0];
            rgbImage.setPixelRgba(x, y, pixel, pixel, pixel, 255);
          }
        }
        resizedImage = rgbImage;
      }

      // ... existing code ...
    } catch (e) {
      print('Failed to predict image: $e');
      setState(() {
        _prediction = 'Error: Failed to predict image.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}