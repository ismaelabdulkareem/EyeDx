import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class HomeClass extends StatefulWidget {
  const HomeClass({super.key});

  @override
  State<HomeClass> createState() => _HomeClassState();
}

class _HomeClassState extends State<HomeClass> {
  final ImagePicker imgPicker = ImagePicker();
  File? imgFile;

  Future<void> choosePic() async {
    try {
      final XFile? image =
          await imgPicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File selectedFile = File(image.path);

        // Apply preprocessing
        File processedFile = await preprocessImage(selectedFile);

        setState(() {
          imgFile = processedFile;
        });
      } else {
        // User canceled the image picker
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected!")),
        );
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
        File selectedFile = File(image.path);

        // Apply preprocessing
        File processedFile = await preprocessImage(selectedFile);

        setState(() {
          imgFile = processedFile;
        });
      } else {
        // User canceled the camera
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image captured!")),
        );
      }
    } catch (e) {
      debugPrint("Error opening camera: $e");
    }
  }

  Future<File> preprocessImage(File file) async {
    final rawImage = img.decodeImage(await file.readAsBytes());
    if (rawImage == null) throw Exception("Could not decode image");

    // Resize to 224x224
    var processedImage = img.copyResize(rawImage, width: 224, height: 224);

    // Apply contrast enhancement
    processedImage = img.adjustColor(processedImage, contrast: 1.5);

    // Save processed image
    final newFile = File(file.path)
      ..writeAsBytesSync(img.encodeJpg(processedImage));
    return newFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const SizedBox(
              width: 350, // Adjust width as needed
              child: Text(
                "This App performs multiclass classification of four types of eye diseases including Diabetic retinopathy (DR), Cataract, Glaucoma and normal fundus. ",
                textAlign: TextAlign.justify, // Align text
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _pickImage(),
                  const SizedBox(width: 20), // Space between widgets
                  _openCam(),
                ],
              ),
            ),
            _displaySelectedImage(),
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Predict'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Prediction feature not implemented yet."),
                    ),
                  );
                },
              ),
            ),
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
            image: AssetImage('assets/images/partyApp2.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _openCam() {
    return InkWell(
      onTap: openCamera, // Call openCamera() instead of choosePic()
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
            fit: BoxFit.contain, // Make the icon smaller
            scale: 1.5, // Reduce icon size
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }

  Widget _displaySelectedImage() {
    return imgFile == null
        ? const SizedBox() // Hide widget if no image is selected
        : Container(
            margin: const EdgeInsets.all(20),
            width: 250, // Adjust size as needed
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue, width: 3),
              image: DecorationImage(
                image: FileImage(imgFile!),
                fit: BoxFit.cover,
              ),
            ),
          );
  }
}
