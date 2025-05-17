import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:omvoting/Model/fundusModel.dart';

import 'dart:ui';
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
  String msgResult = '';
  final fundusVM = Get.put(fundusViewModel());
  String? selectedCase;

  Future<void> scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  Key dropdownKey = UniqueKey(); // Add this in your StatefulWidget class

  void resetDropdown() {
    setState(() {
      selectedCase = null;
      dropdownKey = UniqueKey(); // Force rebuild
    });
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
    await scrollToBottom();
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
    await scrollToBottom();
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

  final fundusViewModel _viewModel = fundusViewModel();
  // Class labels
  final List<String> classLabels = ['NL', 'CA', 'GL', 'DR', 'UNK'];

  late Map<String, int> labelIndex;
  late List<List<int>> confusionMatrix;
  @override
  void initState() {
    super.initState();
    _loadModel();
    _viewModel.fetchAllFundus();
    labelIndex = {
      for (int i = 0; i < classLabels.length; i++) classLabels[i]: i
    };
    confusionMatrix = List.generate(
        classLabels.length, (_) => List.filled(classLabels.length, 0));
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
        predictionResult = '';
        msgResult = "No image selected!";
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
    await scrollToBottom();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _interpreter?.close(); // Close TFLite interpreter
    _clearTempFiles();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarClass(
        onSave: _saveInformation,
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
                const SizedBox(height: 2),
                _tableSaveAndChooseOrginl(),
                _confusionMatrixPage(),
                const SizedBox(height: 10),
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

  Widget _banner() {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 40, top: 10, bottom: 10),
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(150, 255, 152, 0),
            Color.fromARGB(150, 238, 241, 12)
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/thisapplication.png',
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "This application performs multiclass classification of four types of eye diseases: Diabetic retinopathy (DR), Cataract, Glaucoma, and normal fundus.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'georgia',
                color: Color.fromARGB(255, 0, 0, 0),
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

  void _saveInformation() async {
    try {
      File? imageToSave = processedImgFile ?? imgFile;
      String formattedDate =
          DateFormat('MMM d yyyy, hh:mm:ss a').format(DateTime.now());

      String caseTypeToSave = selectedCase ??
          "Unknown"; // Default to "Unknown" if nothing is selected

      if (imageToSave == null || !imageToSave.existsSync()) {
        setState(() {
          predictionResult = '';
          msgResult = "No image to save!";
        });
        return;
      }

      if (predictionResult != '') {
        fundusVM.addFundus(
          imageToSave,
          formattedDate,
          caseTypeToSave,
          predictionResult,
        );
      } else {
        setState(() {
          msgResult = "No pridiction";
        });
        return;
      }
      setState(() {
        predictionResult = '';
        msgResult = "Information saved to Firebase successfully!";
        selectedCase = null;
      });
    } catch (e) {
      setState(() {
        predictionResult = '';

        msgResult = "Error saving to Firebase: $e";
      });
    }
    await scrollToBottom();
  }

  Future<void> _clearTempFiles() async {
    try {
      if (imgFile != null && await imgFile!.exists()) {
        await imgFile!.delete();
      }
      if (processedImgFile != null && await processedImgFile!.exists()) {
        await processedImgFile!.delete();
      }
    } catch (e) {
      debugPrint("Failed to delete temp files: $e");
    }
  }

  Widget _tableSaveAndChooseOrginl() {
    List<String> caseTypes = [
      "Unknown",
      "Normal",
      "Cataract",
      "Glaucoma",
      "DR",
    ];

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          margin: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DropdownMenu<String>(
                key: dropdownKey,
                hintText: "True Label",
                initialSelection: selectedCase,
                dropdownMenuEntries: caseTypes.map((caseType) {
                  return DropdownMenuEntry(value: caseType, label: caseType);
                }).toList(),
                trailingIcon: const Icon(
                  Icons.arrow_drop_down_circle, // Change to your desired icon
                  color: Colors.orange,
                ),
                leadingIcon: const Icon(
                  Icons.check_outlined, // Change to your desired icon
                  color: Color.fromARGB(99, 170, 243, 122),
                ),
                selectedTrailingIcon: const Icon(
                  Icons
                      .arrow_back_ios_new_outlined, // Change to your desired icon
                  color: Colors.orange,
                ),
                onSelected: (newValue) {
                  HapticFeedback.vibrate();
                  setState(() {
                    selectedCase = newValue;
                  });
                },
                menuStyle: MenuStyle(
                  alignment: Alignment.bottomLeft,
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromARGB(240, 255, 255, 255)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                  constraints: BoxConstraints.tight(const Size.fromHeight(40)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.orange,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.orange,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 238, 209, 45),
                      width: 2.5,
                    ),
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'georgia',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                textStyle: const TextStyle(
                  color: Colors.orange,
                  fontFamily: 'georgia',
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),

              const SizedBox(width: 15),

              // Save button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Colors.orange, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  HapticFeedback.vibrate();
                  _saveInformation(); // your custom save function
                  setState(() {
                    resetDropdown(); // This resets the dropdown
                  });
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontFamily: 'georgia',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int getTotalSamples(List<List<int>> matrix) {
    return matrix.fold(0, (sum, row) => sum + row.reduce((a, b) => a + b));
  }

  Widget buildConfusionMatrixTable() {
    final int totalSamples = getTotalSamples(confusionMatrix);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Aligns text to the left
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 12.0, left: 12, right: 10),
                child: Text(
                  'This Tabel is showing the true labels (TL) and predicted labels (PL) for all samples recently assessed by the program (total samples: $totalSamples).',
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'georgia',
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
              Table(
                border: TableBorder.all(color: Colors.orangeAccent),
                columnWidths: const {
                  0: FixedColumnWidth(65),
                },
                defaultColumnWidth: const FixedColumnWidth(55),
                children: [
                  // Header row
                  TableRow(
                    children: [
                      Container(
                        color: const Color.fromARGB(150, 100, 129, 143),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 8),
                        child: const Text(
                          'TL / PL',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: 'georgia',
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ...classLabels.map((label) => Container(
                            color: const Color.fromARGB(150, 96, 125, 139),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'georgia',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                  // Data rows
                  for (int i = 0; i < classLabels.length; i++)
                    TableRow(
                      children: [
                        Container(
                          color: const Color.fromARGB(150, 105, 105, 105),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 13),
                          child: Text(
                            classLabels[i],
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontFamily: 'georgia',
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        for (int j = 0; j < classLabels.length; j++)
                          Builder(builder: (_) {
                            final rowTotal =
                                confusionMatrix[i].reduce((a, b) => a + b);
                            final value = confusionMatrix[i][j];
                            final percentage =
                                rowTotal > 0 ? value / rowTotal : 0.0;
                            final percentText =
                                (percentage * 100).toStringAsFixed(0);

                            const baseColor = Color.fromARGB(200, 30, 140, 250);
                            final backgroundColor = Color.lerp(
                                const Color.fromARGB(150, 0, 0, 20),
                                baseColor,
                                percentage + 0.1);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              padding: const EdgeInsets.all(6.0),
                              color: backgroundColor,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 800),
                                      transitionBuilder: (Widget child,
                                          Animation<double> animation) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.0, 1.0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        value.toString(),
                                        key: ValueKey(
                                            value), // Important for change detection
                                        style: const TextStyle(
                                          fontFamily: 'georgia',
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      transitionBuilder: (Widget child,
                                          Animation<double> animation) {
                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.0, 1.0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        '($percentText%)',
                                        key: ValueKey(
                                            percentText), // Important for change detection
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'georgia',
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String normalizeLabel(String rawLabel) {
    rawLabel = rawLabel.toLowerCase();

    if (rawLabel.contains('normal')) return 'NL';
    if (rawLabel.contains('cataract')) return 'CA';
    if (rawLabel.contains('glaucoma')) return 'GL';
    if (rawLabel.contains('diabetic') || rawLabel.contains('dr')) return 'DR';
    if (rawLabel.contains('unknown')) return 'UNK';

    return rawLabel; // fallback to original if unmatched
  }

  Widget _confusionMatrixPage() {
    return StreamBuilder<List<fundus_Model>>(
      stream: _viewModel.allFundusList.stream,
      builder: (context, snapshot) {
        if (_viewModel.isLoading.value &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final List<fundus_Model>? fundusList = snapshot.data;

        if (fundusList == null || fundusList.isEmpty) {
          return const Center(
              child: Text(
            'No fundus data available!',
            style: TextStyle(
              fontFamily: 'georgia',
            ),
          ));
        }

        // Reset confusion matrix on each data update
        confusionMatrix = List.generate(
            classLabels.length, (_) => List.filled(classLabels.length, 0));

        // Process fundus data to update the confusion matrix
        for (var fu in fundusList) {
          final actual = normalizeLabel(fu.orginal);
          final predicted = normalizeLabel(fu.result);

          if (labelIndex.containsKey(actual) &&
              labelIndex.containsKey(predicted)) {
            final i = labelIndex[actual]!;
            final j = labelIndex[predicted]!;

            confusionMatrix[i][j]++;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildConfusionMatrixTable(),
        );
      },
    );
  }
}
