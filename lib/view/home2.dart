// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:omvoting/View/appBar.dart';
import 'package:omvoting/View/drwaer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class HomeClass2 extends StatefulWidget {
  const HomeClass2({super.key});

  @override
  State<HomeClass2> createState() => _HomeClassState2();
}

class _HomeClassState2 extends State<HomeClass2> {
  final ImagePicker imgPicker = ImagePicker();
  File? imgFile;
  File? processedImgFile;
  String predictionResult = '';
  String msgResult = '';
  bool isProcessing = false; // ✅ For showing progress indicator

  tfl.Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset(
          'assets/flutterModel_noQuantization.tflite');
      setState(() {
        msgResult = "Model loaded successfully";
      });
    } catch (e) {
      setState(() {
        msgResult = "Failed to load model!";
      });
    }
  }

  Future<void> choosePic() async {
    HapticFeedback.vibrate();
    final XFile? image = await imgPicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _resetFiles();
      setState(() {
        imgFile = File(image.path);
        msgResult = "Image selected!";
      });
    } else {
      setState(() {
        msgResult = "No image selected!";
      });
    }
    HapticFeedback.vibrate();
  }

  Future<void> openCamera() async {
    HapticFeedback.vibrate();
    final XFile? image = await imgPicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _resetFiles();
      setState(() {
        imgFile = File(image.path);
        msgResult = "Image captured!";
      });
    } else {
      setState(() {
        msgResult = "No image captured!";
      });
    }
    HapticFeedback.vibrate();
  }

  Future<void> _resetFiles() async {
    if (imgFile != null && await imgFile!.exists()) {
      await imgFile!.delete();
    }
    if (processedImgFile != null && await processedImgFile!.exists()) {
      await processedImgFile!.delete();
    }
    setState(() {
      imgFile = null;
      processedImgFile = null;
      predictionResult = '';
    });
  }

  Future<img.Image?> cropAndPreprocessServer(File file) async {
    final uri = Uri.parse('http://192.168.43.126:47356/crop');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        return img.decodeImage(bytes);
      } else {
        print('Failed to preprocess image. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Future<void> preprocessImage() async {
    if (imgFile == null) {
      setState(() => msgResult = "No image is selected!");
      return;
    }

    setState(() => isProcessing = true); // ✅ Start progress indicator

    try {
      final processedImage = await cropAndPreprocessServer(imgFile!);
      if (processedImage == null) {
        setState(() {
          msgResult = "❌ Failed to preprocess image!";
          isProcessing = false;
        });
        return;
      }

      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newFile = File(path)
        ..writeAsBytesSync(img.encodeJpg(processedImage));

      setState(() {
        processedImgFile = newFile;
        msgResult = "Image preprocessing complete!";
      });
    } catch (e) {
      setState(() => msgResult = "Image preprocessing failed!");
    } finally {
      setState(() => isProcessing = false); // ✅ Stop progress indicator
    }
  }

  Future<void> runInference(List<List<List<List<double>>>> inputImage) async {
    if (_interpreter == null) {
      setState(() => msgResult = "Model not loaded yet");
      return;
    }

    var output = List.generate(1, (_) => List.filled(4, 0.0));
    _interpreter?.run(inputImage, output);

    setState(() {
      predictionResult = getPredictionLabel(output[0]);
    });
  }

  String getPredictionLabel(List<double> output) {
    final labels = ['Cataract', 'Glaucoma', 'Normal', 'Diabetic Retinopathy'];
    int maxIndex = output
        .indexWhere((val) => val == output.reduce((a, b) => a > b ? a : b));
    double confidence = output[maxIndex] * 100;

    if (confidence < 25) {
      return 'Unknown (Confidence: ${confidence.toStringAsFixed(2)}%)';
    }
    return '${labels[maxIndex]} (${confidence.toStringAsFixed(2)}%)';
  }

  List<List<List<int>>> imageToArray(img.Image image) {
    List<List<List<int>>> imgArray = List.generate(
      image.height,
      (y) => List.generate(
        image.width,
        (x) {
          final pixel = image.getPixel(x, y);
          return [
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
            // pixel.a.toInt(),
          ];
        },
      ),
    );
    return imgArray;
  }

  List<List<List<double>>> normalizeImageArray(List<List<List<int>>> imgArray) {
    return imgArray
        .map((row) =>
            row.map((pixel) => pixel.map((v) => v / 255.0).toList()).toList())
        .toList();
  }

  List<List<List<List<double>>>> addBatchDimension(
      List<List<List<double>>> imgArray) {
    return [imgArray];
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarClass(isSaveEnabled: true),
      drawer: const MyDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Image.asset('assets/images/a2.jpg', fit: BoxFit.cover),
          ),
          Container(color: Colors.black.withOpacity(0.1)),
          Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    _tablePickAndOpenCam(),
                    _displaySelectedImage(),
                    _tablePreProcessAndPridictBtns(),
                    const SizedBox(height: 2),
                    _FinalResult(),
                  ],
                ),
              ),
              if (isProcessing)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tablePickAndOpenCam() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [_pickImage(), _openCam()],
    );
  }

  Widget _pickImage() {
    return InkWell(
      onTap: choosePic,
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          border: GradientBoxBorder(
            gradient: LinearGradient(
                colors: [Colors.orange, Color.fromARGB(99, 102, 102, 102)]),
            width: 2,
          ),
          shape: BoxShape.circle,
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/images/eyeball.png'),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _openCam() {
    return InkWell(
      onTap: openCamera,
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          border: GradientBoxBorder(
            gradient: LinearGradient(
                colors: [Colors.orange, Color.fromARGB(99, 102, 102, 102)]),
            width: 2,
          ),
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/cam.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _displaySelectedImage() {
    final file = processedImgFile ?? imgFile;
    return file != null
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(file, height: 250),
          )
        : const SizedBox.shrink();
  }

  Widget _tablePreProcessAndPridictBtns() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: isProcessing ? null : preprocessImage,
            icon: const Icon(Icons.build_circle_outlined),
            label: const Text("Preprocess"),
          ),
          ElevatedButton.icon(
            onPressed: processedImgFile != null && !isProcessing
                ? () async {
                    final imgData =
                        img.decodeImage(await processedImgFile!.readAsBytes());
                    if (imgData != null) {
                      final array = addBatchDimension(
                          normalizeImageArray(imageToArray(imgData)));
                      await runInference(array);
                    }
                  }
                : null,
            icon: const Icon(Icons.analytics_outlined),
            label: const Text("Predict"),
          ),
        ],
      ),
    );
  }

  Widget _FinalResult() {
    return Column(
      children: [
        Text(
          msgResult,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Text(
          predictionResult,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
      ],
    );
  }
}
