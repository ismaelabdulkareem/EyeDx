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

  Future<File> preprocessImage(File file) async {
    final rawImage = img.decodeImage(await file.readAsBytes());
    if (rawImage == null) throw Exception("Could not decode image");

    // Resize to 224x224
    var processedImage = img.copyResize(rawImage, width: 224, height: 224);

    // Convert to grayscale
    processedImage = img.grayscale(processedImage);

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 100),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _pickImage(),
                  const SizedBox(height: 10),
                  const Text(
                    'Thank you for your participation',
                    style: TextStyle(fontFamily: 'georgia', fontSize: 16),
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Predict'),
                onPressed: () {
                  // Future action for prediction
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text("Prediction feature not implemented yet.")),
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
        height: 250,
        width: 250,
        decoration: BoxDecoration(
          border: const GradientBoxBorder(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
            ),
            width: 5,
          ),
          gradient: const LinearGradient(
            colors: [Color.fromARGB(255, 169, 209, 241), Colors.white],
            begin: Alignment.bottomLeft,
            end: Alignment.centerLeft,
          ),
          shape: BoxShape.circle,
          image: imgFile == null
              ? const DecorationImage(
                  image: AssetImage('assets/images/partyApp2.png'),
                  fit: BoxFit.cover,
                )
              : DecorationImage(
                  image: FileImage(imgFile!),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}
