import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omvoting/View/appBar.dart';
import 'package:omvoting/View/drwaer.dart';
import 'package:omvoting/ViewModel/fundusViewModel.dart';

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
  final ScrollController _scrollController = ScrollController();
  final ImagePicker imgPicker = ImagePicker();
  File? imgFile;
  File? processedImgFile;
  String predictionResult = ''; // Store prediction result
  final fundusVM = Get.put(fundusViewModel());

  Future<void> scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Future<void> runInference(List<List<List<List<double>>>> inputImage) async {
    if (_interpreter == null) {
      if (!mounted) return;
      setState(() {
        predictionResult = "Model not loaded yet";
      });

      return;
    }

    var output = List.generate(1, (_) => List.filled(4, 0.0)); // 4 classes
    _interpreter?.run(inputImage, output);
    // Get prediction and update state
    if (!mounted) return;
    setState(() {
      predictionResult = getPredictionLabel(output[0]);
    });
    await scrollToBottom();
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
        setState(() {
          predictionResult = "Image selected!";
        });
      } else {
        if (!mounted) return;
        setState(() {
          predictionResult = "No image selected!";
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
    await scrollToBottom();
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
        if (!mounted) return;
        setState(() {
          predictionResult = "No image captured!";
        });
      }
    } catch (e) {
      debugPrint("Error opening camera: $e");
    }
    await scrollToBottom();
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

    if (confidence < 50.0) {
      return 'Unknown (Confidence: ${confidence.toStringAsFixed(2)}%)';
    }
    return '${labels[maxIndex]} (${confidence.toStringAsFixed(2)}%)';
  }

  tfl.Interpreter? _interpreter;

  Future<void> _loadModel() async {
    try {
      _interpreter = await tfl.Interpreter.fromAsset(
          'assets/flutterModel_noQuantization.tflite');
      if (!mounted) return;
      setState(() {
        predictionResult = "Model loaded successfully";
      });
    } catch (e) {
      debugPrint("Model loading error: $e");
      if (!mounted) return;
      setState(() {
        predictionResult = "Failed to load model!";
      });
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
      if (!mounted) return;
      setState(() {
        predictionResult = "No image selected!";
      });
      return;
    }

    try {
      Uint8List imageBytes = await imgFile!.readAsBytes();
      img.Image croppedImg = await cropFundusCircle(imageBytes);

      final directory = await getTemporaryDirectory();
      final processedFilePath =
          '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File newFile = File(processedFilePath);
      newFile.writeAsBytesSync(img.encodeJpg(croppedImg));

      setState(() {
        processedImgFile = newFile;
      });
      if (!mounted) return;
      setState(() {
        predictionResult = "Image preprocessing complete!";
      });
    } catch (e) {
      debugPrint("Error processing image: $e");
      if (!mounted) return;
      setState(() {
        predictionResult = "Image preprocessing failed!";
      });
    }
    await scrollToBottom();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarClass(),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(height: 2),
            _banner(),
            _tablePickAndOpenCam(),
            _displaySelectedImage(),
            _tablePreProcessAndPridictBtns(),
            const SizedBox(height: 2),
            _FinalResult(),
            const SizedBox(height: 100),
            _insertButton(),
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
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 71, 71, 71)
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
            // bottomLeft: Radius.circular(15),
            // bottomRight: Radius.circular(15),
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
          setState(() {
            predictionResult = "No image selected or processed!";
          });
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

  Widget _displayPredictionResult() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: Text(
          predictionResult,
          key: ValueKey<String>(predictionResult),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _banner() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 40, top: 15, bottom: 15),
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
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.normal,
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
        borderRadius: BorderRadius.only(),
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

  Widget _tablePreProcessAndPridictBtns() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 0, 0),
            Color.fromARGB(255, 71, 71, 71),
          ],
          begin: Alignment.bottomLeft,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Align items to the start
        children: [
          _preprocessBtn(),
          const SizedBox(width: 15), // Add spacing between buttons
          _predictBtn(),
        ],
      ),
    );
  }

  Widget _FinalResult() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.92, // 92% of screen width
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFa8e063),
            Color(0xFF56ab2f),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start, // Center align content
            children: [
              SizedBox(width: 8),
              Icon(LucideIcons.checkSquare,
                  color: Color.fromARGB(255, 0, 0, 0), size: 24), // Lucide icon
              SizedBox(width: 8), // Space between icon and text
              Text(
                "Result",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _displayPredictionResult(),
        ],
      ),
    );
  }

  Widget _insertButton() {
    return InkWell(
      onTap: () {
        File? imageToSave = processedImgFile ?? imgFile;

        if (imageToSave == null) {
          setState(() {
            predictionResult = "No image selected or processed!";
          });
          return;
        }

        if (imageToSave != null) {
          fundusVM.addFundus(imageToSave, "A", "A", "a", "a");
        } else {
          predictionResult = "Failled to add data !, Please fill up all fields";
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
        alignment: Alignment.center,
        height: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 226, 225, 228),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black), // Black border
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 77, 75, 75).withOpacity(0.5),
              spreadRadius: 0.5,
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Text(
          "Insert information",
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'georgia',
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
    );
  }
}
