import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:omvoting/component/textfiled.dart';
import 'package:omvoting/viewModel/partilistApp2_viewModel.dart';
import 'package:loading_overlay/loading_overlay.dart';

class MyWidgetInsertParties extends StatefulWidget {
  const MyWidgetInsertParties({super.key});

  @override
  State<MyWidgetInsertParties> createState() => _MyWidgetRegState();
}

class _MyWidgetRegState extends State<MyWidgetInsertParties> {
  final ImagePicker imgPicker = ImagePicker();
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
        ],
      ),
    );
  }

  Widget _buildInsertButton() {
    return InkWell(
      onTap: () {
        if (_namePartyApp2.text.isNotEmpty &&
            _NoPartyApp2.text.isNotEmpty &&
            imgFile != null) {
          partyApp2VM.addParty(
              imgFile!, _namePartyApp2.text, _NoPartyApp2.text);
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
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        alignment: Alignment.center,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black), // Black border
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 91, 138, 240)
                  .withOpacity(1), // Black color with opacity for blur effect
            ),
          ],
        ),
        child: const Text(
          "Insert information",
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'georgia',
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}
