import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class HomeClass extends StatefulWidget {
  const HomeClass({super.key});

  @override
  State<HomeClass> createState() => _HomeClassState();
}

class _HomeClassState extends State<HomeClass> {
  final ImagePicker imgPicker = ImagePicker();
  File? imgFile;
  File? processedImgFile;

  Future<void> runInference(List<List<List<List<double>>>> inputImage) async {
    if (_interpreter == null) {
      _showSnackbar("Model not loaded yet.");
      return;
    }

    print('Input tensor shape: ${_interpreter!.getInputTensor(0).shape}');
    print('Input tensor type: ${_interpreter!.getInputTensor(0).type}');

    var output = List.generate(1, (_) => List.filled(4, 0.0)); // 4 classes
    _interpreter?.run(inputImage, output);
    _showSnackbar("Prediction: ${getPredictionLabel(output[0])}");
  }

  Future<void> choosePic() async {
    try {
      final XFile? image =
          await imgPicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          imgFile = File(image.path);
          processedImgFile =
              null; // Reset processed image when selecting a new image
        });
      } else {
        _showSnackbar("No image selected!");
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> openCamera() async {
    try {
      final XFile? image =
          await imgPicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          imgFile = File(image.path);
          processedImgFile =
              null; // Reset processed image when selecting a new image
        });
      } else {
        _showSnackbar("No image captured!");
      }
    } catch (e) {
      debugPrint("Error opening camera: $e");
    }
  }

  String getPredictionLabel(List<double> output) {
    // Define your class labels in the same order as model output
    List<String> labels = [
      'Cataract',
      'Glaucoma',
      'Normal',
      'Diabetic Retinopathy',
    ];

    // Find the index of the max value
    int maxIndex = 0;
    double maxValue = output[0];
    for (int i = 1; i < output.length; i++) {
      if (output[i] > maxValue) {
        maxValue = output[i];
        maxIndex = i;
      }
    }

    // Format confidence as percentage
    double confidence = (maxValue * 100.0);
    return '${labels[maxIndex]} (${confidence.toStringAsFixed(2)}%)';
  }

  tfl.Interpreter? _interpreter;

  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset(
          'assets/flutterModel_noQuantization.tflite');
      _showSnackbar("Model loaded successfully.");
    } catch (e) {
      debugPrint("Model loading error: $e");
      _showSnackbar("Failed to load model.");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadModel();
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

  List<List<List<List<double>>>> addBatchDimension(
      List<List<List<double>>> imgArray) {
    return [imgArray]; // Wrap in another list to add batch dimension
  }

  List<List<List<double>>> normalizeImageArray(List<List<List<int>>> imgArray) {
    return imgArray.map((row) {
      return row.map((pixel) {
        return pixel.map((value) => value / 255.0).toList();
      }).toList();
    }).toList();
  }

  Future<img.Image> cropFundusCircle(Uint8List imageBytes,
      {int targetSize = 224}) async {
    // Decode image
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception("Could not decode image");
    }

    int centerX = image.width ~/ 2;
    int centerY = image.height ~/ 2;
    int radius = (image.width < image.height ? image.width : image.height) ~/ 2;

    // Create a circular mask
    img.Image mask = img.Image(width: image.width, height: image.height);
    img.fill(mask, color: img.ColorUint8.rgb(0, 0, 0)); // Fill with black
    img.drawCircle(
      mask,
      x: centerX,
      y: centerY,
      radius: radius,
      color: img.ColorUint8.rgb(255, 255, 255), // Draw circle in white
    );

    // Apply the mask to the image
    img.Image maskedImage =
        img.copyResize(image, width: image.width, height: image.height);
    for (int y = 0; y < maskedImage.height; y++) {
      for (int x = 0; x < maskedImage.width; x++) {
        if (mask.getPixel(x, y) == img.ColorUint8.rgb(0, 0, 0)) {
          // Check black areas
          maskedImage.setPixel(
              x, y, img.ColorUint8.rgb(0, 0, 0)); // Set background to black
        }
      }
    }

    // Crop to the detected circle
    int x1 = (centerX - radius).clamp(0, image.width - 1);
    int y1 = (centerY - radius).clamp(0, image.height - 1);
    int x2 = (centerX + radius).clamp(0, image.width);
    int y2 = (centerY + radius).clamp(0, image.height);
    img.Image croppedImage = img.copyCrop(maskedImage,
        x: x1, y: y1, width: x2 - x1, height: y2 - y1);

    // Resize to target size
    return img.copyResize(croppedImage, width: targetSize, height: targetSize);
  }

  Future<void> preprocessImage() async {
    if (imgFile == null) {
      _showSnackbar("No image selected!");
      return;
    }

    try {
      Uint8List imageBytes = await imgFile!.readAsBytes();
      img.Image croppedImg = await cropFundusCircle(imageBytes);

      // // Convert image to array & normalize
      // List<List<List<int>>> imgArray = imageToArray(croppedImg);
      // List<List<List<double>>> normalizedImgArray = imgArray
      //     .map((row) => row
      //         .map((pixel) => pixel.map((value) => value / 255.0).toList())
      //         .toList())
      //     .toList();

      // Save processed image
      final directory = await getTemporaryDirectory();
      final processedFilePath =
          '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File newFile = File(processedFilePath);
      newFile.writeAsBytesSync(img.encodeJpg(croppedImg));

      setState(() {
        processedImgFile = newFile;
      });

      _showSnackbar("Image preprocessing complete!");
    } catch (e) {
      debugPrint("Error processing image: $e");
      _showSnackbar("Image processing failed!");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            _banner(),
            _tablePickAndOpenCam(),
            _displaySelectedImage(),
            const SizedBox(height: 20),

            // Preprocessing Button
            _preprocessBtn(),

            const SizedBox(height: 20),
            _predictBtn(),
          ],
        ),
      ),
    );
  }

  Widget _pickImage() {
    return InkWell(
      onTap: choosePic,
      child: Container(
        height: 70,
        width: 70,
        decoration: const BoxDecoration(
          border: GradientBoxBorder(
            gradient: LinearGradient(
              colors: [Colors.blue, Color.fromARGB(0, 148, 27, 27)],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
            ),
            width: 5,
          ),
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 169, 209, 241), Colors.white],
            begin: Alignment.bottomLeft,
            end: Alignment.centerLeft,
          ),
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/partyApp2.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _openCam() {
    return InkWell(
      onTap: openCamera,
      child: Container(
        height: 70,
        width: 70,
        decoration: const BoxDecoration(
          border: GradientBoxBorder(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
            ),
            width: 5,
          ),
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 169, 209, 241), Colors.white],
            begin: Alignment.bottomLeft,
            end: Alignment.centerLeft,
          ),
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/cam.png'),
            fit: BoxFit.contain,
            scale: 1.5,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _displaySelectedImage() {
    return processedImgFile != null
        ? _imageContainer(processedImgFile!)
        : imgFile != null
            ? _imageContainer(imgFile!)
            : const SizedBox();
  }

  Widget _imageContainer(File image) {
    return Container(
      width: 365,
      height: 365,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 71, 71, 71)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(image, fit: BoxFit.contain),
      ),
    );
  }

  Widget _preprocessBtn() {
    return ElevatedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.orangeAccent,
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      onPressed: preprocessImage,
      child: const Text('Preprocess Image'),
    );
  }

  Widget _predictBtn() {
    return ElevatedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      child: const Text('Predict'),
      onPressed: () async {
        // Use processed image if available, else original image
        File? imageToUse = processedImgFile ?? imgFile;

        if (imageToUse == null) {
          _showSnackbar("No image selected or processed!");
          return;
        }

        Uint8List imageBytes = await imageToUse.readAsBytes();
        img.Image? image = img.decodeImage(imageBytes);
        if (image == null) {
          _showSnackbar("Failed to decode image.");
          return;
        }

        // Resize, normalize, add batch dimension
        img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
        List<List<List<int>>> imgArray = imageToArray(resizedImage);
        List<List<List<double>>> normalizedImgArray =
            normalizeImageArray(imgArray);
        List<List<List<List<double>>>> inputTensor =
            addBatchDimension(normalizedImgArray);

        runInference(inputTensor);
      },
    );
  }

  Widget _banner() {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 243, 33, 79),
            Color.fromARGB(255, 248, 98, 98)
          ], // Blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.activity, color: Colors.white, size: 32), // Eye icon
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "This app performs multiclass classification of four types of eye diseases: Diabetic retinopathy (DR), Cataract, Glaucoma, and normal fundus.",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tablePickAndOpenCam() {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 71, 71, 71)
          ], // Blue gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 2,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1),
        },
        children: [
          const TableRow(
            children: [
              TableCell(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center align content
                  children: [
                    Icon(LucideIcons.fileInput,
                        color: Colors.white, size: 24), // Lucide icon
                    SizedBox(width: 8), // Space between icon and text
                    Text(
                      "Choose the Input",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(),
            ],
          ),
          const TableRow(
            children: [
              TableCell(child: SizedBox(height: 16)),
              TableCell(child: SizedBox()),
            ],
          ),
          TableRow(
            children: [
              TableCell(child: Center(child: _pickImage())),
              TableCell(child: Center(child: _openCam())),
            ],
          ),
        ],
      ),
    );
  }
}
