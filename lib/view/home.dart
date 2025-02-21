import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/animation.dart';

class HomeClass extends StatefulWidget {
  const HomeClass({super.key});

  @override
  State<HomeClass> createState() => _HomeClassState();
}

class _HomeClassState extends State<HomeClass> {
  final ImagePicker imgPicker = ImagePicker();
  File? imgFile;
  File? processedImgFile;

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

  Future<void> preprocessImage() async {
    if (imgFile == null) {
      _showSnackbar("No image selected!");
      return;
    }
    try {
      final rawImage = img.decodeImage(await imgFile!.readAsBytes());
      if (rawImage == null) throw Exception("Could not decode image");

      // Resize to 224x224
      var processedImage = img.copyResize(rawImage, width: 224, height: 224);

      // Apply contrast enhancement
      processedImage = img.adjustColor(processedImage, contrast: 1.5);

// Save the processed image in the app's temporary directory
      final directory = await getTemporaryDirectory();
      final processedFilePath =
          '${directory.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final newFile = File(processedFilePath)
        ..writeAsBytesSync(img.encodeJpg(processedImage));

      setState(() {
        processedImgFile = newFile; // Update `processedImgFile` to `imgFile`
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
        backgroundColor: const Color.fromARGB(255, 5, 158, 5),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: const Text('Predict'),
      onPressed: () {
        _showSnackbar("Prediction feature not implemented yet.");
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
