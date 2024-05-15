import 'dart:io';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:omvoting/component/textfiled.dart';
import 'package:omvoting/viewModel/partilistApp2_viewModel.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class MyWidgetInsertParties extends StatefulWidget {
  const MyWidgetInsertParties({super.key});

  @override
  State<MyWidgetInsertParties> createState() => _MyWidgetInsertPartiesState();
}

class _MyWidgetInsertPartiesState extends State<MyWidgetInsertParties> {
  final ImagePicker imgPicker = ImagePicker();
  Color selectedColor =
      const Color.fromARGB(255, 228, 11, 192); // Initial color

  File? imgFile;

  final TextEditingController _namePartyApp2 = TextEditingController();
  final TextEditingController _NoPartyApp2 = TextEditingController();

  final partyApp2VM = Get.put(PartyViewModel());

  @override
  void dispose() {
    _namePartyApp2.dispose();
    _NoPartyApp2.dispose();
    super.dispose();
  }

  Future<void> chooseProfilePic() async {
    final XFile? image = await imgPicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imgFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => LoadingOverlay(
          isLoading: partyApp2VM.isLoading.value,
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
                    children: <Widget>[
                      _buildProfileImageContainer(),
                      const SizedBox(height: 15),
                      _buildForm(),
                      _buildInsertButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageContainer() {
    return InkWell(
      onTap: chooseProfilePic,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          border: const GradientBoxBorder(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 23, 26, 224),
                Color.fromRGBO(23, 122, 202, 0.004),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            width: 5,
          ),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 169, 209, 241),
              Color.fromARGB(255, 255, 255, 255),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.centerLeft,
          ),
          shape: BoxShape.circle,
          image: imgFile == null
              ? const DecorationImage(
                  image: AssetImage('assets/images/partyApp2.png'),
                  fit: BoxFit.fitHeight,
                )
              : DecorationImage(
                  image: FileImage(imgFile!),
                  fit: BoxFit.fitHeight,
                ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      child: Column(
        children: <Widget>[
          myTextFiled(
            myHit: 'Party Name',
            myObscureText: false,
            myController: _namePartyApp2,
            MyPrefIcon: const Icon(Icons.flag_circle_rounded),
            myValidator: (value) {
              return null;
            },
          ),
          const SizedBox(height: 10),
          myTextFiled(
            myHit: 'Party No.',
            myObscureText: false,
            myController: _NoPartyApp2,
            MyPrefIcon: const Icon(Icons.numbers_outlined),
            myValidator: (value) {
              return null;
            },
          ),
          const SizedBox(height: 10),

          _buildColorPickerButton(), // Add color picker button/icon
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInsertButton() {
    return InkWell(
      onTap: () {
        Random random = Random();
        int partyVotes = random.nextInt(1000000) + 1;

        if (_namePartyApp2.text.isNotEmpty &&
            _NoPartyApp2.text.isNotEmpty &&
            imgFile != null) {
          partyApp2VM.addParty(imgFile!, _namePartyApp2.text, _NoPartyApp2.text,
              partyVotes, selectedColor);
        } else {
          Fluttertoast.showToast(
            msg: "Failled to add data !, Please fill up all fields",
            toastLength:
                Toast.LENGTH_SHORT, // Duration for which the toast is shown
            gravity: ToastGravity.BOTTOM, // Toast position
            timeInSecForIosWeb: 5, // Time in seconds for iOS
            backgroundColor:
                Colors.red.withOpacity(0.7), // Background color of the toast
            textColor: Colors.white, // Text color of the toast
            fontSize: 16.0, // Font size of the toast message
          );
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

  Widget _buildColorPickerButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Pick a color'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (color) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Pick'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: selectedColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.black),
        ),
        child: const Center(
          child: Text(
            'Pick a party color',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
