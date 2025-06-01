import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart';

class HomeClass3 extends StatefulWidget {
  const HomeClass3({super.key});

  @override
  _HomeClassState3 createState() => _HomeClassState3();
}

class _HomeClassState3 extends State<HomeClass3> {
  Interpreter? interpreter;
  String resultText = '';
  img.Image? displayImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset(
          'assets/flutterModel_noQuantization.tflite');
      print('✅ Model loaded');
    } catch (e) {
      print('❌ Failed to load model: $e');
    }
  }

  Future<XFile?> choosePic() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<img.Image?> cropAndPreprocessServer(File file,
      {int targetSize = 224}) async {
    final uri = Uri.parse(
        'http://192.168.43.126:47356/crop'); // Update with your server IP
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final serverImage = img.decodeImage(responseData);
        if (serverImage != null) {
          return serverImage;
        }
      } else {
        print('❌ Failed to preprocess image. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error communicating with server: $e');
    }

    return null;
  }

  List<List<List<List<double>>>> preprocessImage(img.Image image) {
    return List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = image.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
  }

  Future<List<double>> runInference(Interpreter interpreter, List input) async {
    var output = List.filled(4, 0.0).reshape([1, 4]);
    interpreter.run(input, output);
    return output[0].cast<double>();
  }

  Map<String, dynamic> interpretPrediction(List<double> predictions) {
    final classLabels = ['Cataract', 'Glaucoma', 'Normal', 'DR'];
    int index = predictions.indexWhere(
        (score) => score == predictions.reduce((a, b) => a > b ? a : b));
    return {
      'label': classLabels[index],
      'confidence': predictions[index],
    };
  }

  Future<void> predictImage() async {
    final pickedFile = await choosePic();
    if (pickedFile == null) return;

    setState(() {
      isLoading = true;
      resultText = '';
    });

    final file = File(pickedFile.path);
    final processedImage = await cropAndPreprocessServer(file);

    if (processedImage == null) {
      setState(() {
        resultText = '❌ Failed to preprocess image.';
        isLoading = false;
      });
      return;
    }

    if (interpreter == null) {
      setState(() {
        resultText = '❌ Model not loaded.';
        isLoading = false;
      });
      return;
    }

    final input = preprocessImage(processedImage);
    final predictions = await runInference(interpreter!, input);
    final result = interpretPrediction(predictions);

    setState(() {
      displayImage = processedImage;
      resultText =
          'Prediction: ${result['label']}\nConfidence: ${(result['confidence'] * 100).toStringAsFixed(2)}%';

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eye Disease Predictor')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              displayImage != null
                  ? Image.memory(
                      Uint8List.fromList(
                          img.encodeJpg(displayImage!, quality: 100)),
                      width: 224,
                      height: 224,
                    )
                  : const Icon(Icons.image, size: 100),
              const SizedBox(height: 20),
              Text(
                resultText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: predictImage,
                      child: const Text('Select and Predict Image'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
