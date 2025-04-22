import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  Interpreter? _interpreter;
  File? _image;
  String _prediction = '';
  bool _isLoading = false;
  bool _isModelLoaded = false;

  final List<String> labels = ['Normal', 'Ischemic', 'Haemorrhagic'];

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

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

  Future<void> _pickImage() async {
    if (!_isModelLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for the model to load')),
      );
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 224,
        maxHeight: 224,
      );

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _prediction = 'Processing image...';
          _isLoading = true;
        });
        await _runPrediction();
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _prediction = 'Error: Failed to pick image';
        _isLoading = false;
      });
    }
  }

  Future<void> _runPrediction() async {
    if (_interpreter == null || _image == null) {
      setState(() {
        _prediction = 'Error: Model or image not loaded';
        _isLoading = false;
      });
      return;
    }

    try {
      // Load and preprocess image
      final imageBytes = await _image!.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        setState(() {
          _prediction = 'Error: Failed to decode image';
          _isLoading = false;
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

      // Prepare input tensor [1, 224, 224, 3]
      var input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) => List.generate(
              3,
              (c) {
                // Get pixel value and normalize to [0, 1]
                var pixel = resizedImage.getPixel(x, y)[c];
                return (pixel is int ? pixel : pixel.toInt()).toDouble() / 255.0;
              },
            ),
          ),
        ),
      );

      // Prepare output tensor [1, 3]
      var output = List.generate(1, (_) => List.filled(3, 0.0));

      // Run inference
      _interpreter!.run(input, output);

      // Get prediction and confidence
      var outputArray = output[0];
      int predictedIndex = outputArray.indexOf(outputArray.reduce((a, b) => a > b ? a : b));
      String result = labels[predictedIndex];
      double confidence = outputArray[predictedIndex] * 100;

      // Format prediction string with all probabilities
      String probabilities = '';
      for (int i = 0; i < labels.length; i++) {
        probabilities += '\n${labels[i]}: ${(outputArray[i] * 100).toStringAsFixed(1)}%';
      }

      setState(() {
        _prediction = 'Prediction: $result\nConfidence: ${confidence.toStringAsFixed(1)}%\n\nProbabilities:$probabilities';
        _isLoading = false;
      });
    } catch (e) {
      print('Prediction error: $e');
      setState(() {
        _prediction = 'Error during prediction: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stroke Prediction'),
        backgroundColor: const Color.fromARGB(255, 91, 156, 45).withOpacity(0.8),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Upload a brain CT scan image for stroke prediction',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                height: 224,
                width: 224,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? const Center(child: Text('No image selected'))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickImage,
                icon: const Icon(Icons.image),
                label: Text(_isLoading ? 'Processing...' : 'Select Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 91, 156, 45),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Processing...'),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _prediction,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Note: This is a preliminary screening tool and should not replace professional medical diagnosis.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}