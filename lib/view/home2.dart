import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omvoting/View/appBar.dart';
import 'package:omvoting/View/drwaer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
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
  String predictionResult = ''; // Store prediction result
  String msgResult = '';

  Future<img.Image?> cropAndPreprocessServer(File file,
      {int targetSize = 224}) async {
    final uri = Uri.parse(
        'http://192.168.43.126:5000/crop'); // Update with your server IP
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

  Future<void> runInference(List<List<List<List<double>>>> inputImage) async {
    if (_interpreter == null) {
      if (!mounted) return;
      setState(() {
        predictionResult = '';
        msgResult = "Model not loaded yet";
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
  }

  Future<void> choosePic() async {
    HapticFeedback.vibrate();
    try {
      final XFile? image =
          await imgPicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Delete previous files
        if (imgFile != null && await imgFile!.exists()) {
          await imgFile!.delete();
        }
        if (processedImgFile != null && await processedImgFile!.exists()) {
          await processedImgFile!.delete();
        }

        setState(() {
          imgFile = File(image.path);
          processedImgFile = null;
          predictionResult = '';
          msgResult = "Image selected!";
        });
      } else {
        if (!mounted) return;
        setState(() {
          predictionResult = '';
          msgResult = "No image selected!";
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
    HapticFeedback.vibrate();
  }

  Future<void> openCamera() async {
    HapticFeedback.vibrate();
    try {
      final XFile? image =
          await imgPicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        if (imgFile != null && await imgFile!.exists()) {
          await imgFile!.delete();
        }
        if (processedImgFile != null && await processedImgFile!.exists()) {
          await processedImgFile!.delete();
        }
        setState(() {
          imgFile = File(image.path);
          processedImgFile =
              null; // Reset processed image when selecting a new image
        });
      } else {
        if (!mounted) return;
        setState(() {
          predictionResult = '';
          msgResult = "No image captured!";
        });
      }
    } catch (e) {
      debugPrint("Error opening camera: $e");
    }
    HapticFeedback.vibrate();
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

    if (confidence < 25.0) {
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
        predictionResult = '';
        msgResult = "Model loaded successfully";
      });
    } catch (e) {
      debugPrint("Model loading error: $e");
      if (!mounted) return;
      setState(() {
        predictionResult = '';
        msgResult = "Failed to load model!";
      });
    }
  }

  late Map<String, int> labelIndex;
  late List<List<int>> confusionMatrix;
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

  Future<void> preprocessImage() async {
    if (imgFile == null) {
      if (!mounted) return;
      setState(() {
        predictionResult = '';
        msgResult = "No image is selected!";
      });
      return;
    }

    try {
      final file = File(imgFile!.path);
      final processedImage = await cropAndPreprocessServer(file);

      if (processedImage == null) {
        setState(() {
          predictionResult = '';
          msgResult = '❌ Failed to preprocess image!';
          // isLoading = false;
        });
        return;
      }

      final directory = await getTemporaryDirectory();
      final processedFilePath =
          '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      File newFile = File(processedFilePath);
      newFile.writeAsBytesSync(img.encodeJpg(processedImage));

      setState(() {
        processedImgFile = newFile;
      });
      if (!mounted) return;
      setState(() {
        predictionResult = '';
        msgResult = "Image preprocessing complete!";
      });
    } catch (e) {
      debugPrint("Error processing image: $e");
      if (!mounted) return;
      setState(() {
        predictionResult = '';
        msgResult = "Image preprocessing failed!";
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _interpreter?.close(); // Close TFLite interpreter

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarClass(
        isSaveEnabled: true,
      ),
      drawer: const MyDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur effect
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Image.asset(
              'assets/images/a2.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Optional dark overlay for more readability
          Container(
            color: Colors.black.withOpacity(
                0.1), // You can adjust this for more/less transparency
          ),

          // Main content (your existing content)
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
        ],
      ),
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
              colors: [Colors.orange, Color.fromARGB(99, 102, 102, 102)],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
            ),
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
              colors: [Colors.orange, Color.fromARGB(99, 102, 102, 102)],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
            ),
            width: 2,
          ),
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/cam.jpg'),
            fit: BoxFit.cover,
            //scale: 1.5,
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
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        side: const BorderSide(
            color: Color.fromARGB(255, 255, 171, 64), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      onPressed: () {
        preprocessImage();
        HapticFeedback.vibrate();
      },
      child: const Text(
        'Preprocess Image',
        style: TextStyle(
          fontFamily: 'georgia',
        ),
      ),
    );
  }

  Widget _predictBtn() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        side: const BorderSide(
            color: Color.fromARGB(255, 64, 169, 255), width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: const Text(
        'Predict',
        style: TextStyle(
          fontFamily: 'georgia',
        ),
      ),
      onPressed: () async {
        HapticFeedback.vibrate();
        File? imageToUse = processedImgFile ?? imgFile;

        if (imageToUse == null) {
          setState(() {
            predictionResult = '';
            msgResult = "No image selected or processed!";
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
    // Prioritize prediction result if available, else show msgResult
    String displayMessage =
        predictionResult.isNotEmpty ? predictionResult : msgResult;

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
          displayMessage,
          key: ValueKey<String>(displayMessage),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            fontFamily: 'georgia',
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _tablePickAndOpenCam() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(240, 0, 0, 0),
            Color.fromARGB(240, 71, 71, 71)
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
          TableRow(
            children: [
              TableCell(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Center align content
                  children: [
                    Image.asset(
                      'assets/images/input.png',
                      width: 25,
                      height: 25,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8), // Space between icon and text
                    const Text(
                      "Choose the Input",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'georgia',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(),
            ],
          ),
          const TableRow(
            children: [
              TableCell(child: SizedBox(height: 10)),
              TableCell(child: SizedBox()),
            ],
          ),
          TableRow(
            children: [
              TableCell(child: Center(child: _pickImage())),
              TableCell(child: Center(child: _openCam())),
            ],
          ),
          const TableRow(
            children: [
              TableCell(child: SizedBox(height: 3)),
              TableCell(child: SizedBox()),
            ],
          ),
          const TableRow(
            children: [
              TableCell(
                  child: Center(
                      child: Text(
                "Fundus",
                style: TextStyle(
                    color: Color.fromARGB(221, 255, 255, 255),
                    fontFamily: 'georgia',
                    fontSize: 10),
              ))),
              TableCell(
                  child: Center(
                      child: Text(
                "Lens",
                style: TextStyle(
                    color: Color.fromARGB(221, 255, 255, 255),
                    fontFamily: 'georgia',
                    fontSize: 10),
              ))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tablePreProcessAndPridictBtns() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(240, 0, 0, 0),
            Color.fromARGB(240, 71, 71, 71)
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
            Color.fromARGB(200, 168, 224, 99),
            Color.fromARGB(200, 86, 171, 47),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/predict.png',
                width: 30,
                height: 30,
                color: Colors
                    .black, // optional if your image is monochrome and you want to tint it
              ),
              const SizedBox(width: 8), // Space between icon and text
              const Text(
                "Result",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'georgia',
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
}
