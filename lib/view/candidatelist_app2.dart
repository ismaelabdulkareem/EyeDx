import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omvoting/component/textfiled.dart';
import 'package:omvoting/view/home_app2.dart';
import 'package:omvoting/viewModel/candListApp2_viewModel.dart';
import 'package:text_area/text_area.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';

class MyWidgetInsertCandidates extends StatefulWidget {
  const MyWidgetInsertCandidates({super.key});

  @override
  State<MyWidgetInsertCandidates> createState() => _MyWidgetRegState();
}

TextEditingController cNameApp2 = TextEditingController();
TextEditingController cNoApp2 = TextEditingController();
TextEditingController cPartApp2 = TextEditingController();
TextEditingController cEduApp2 = TextEditingController();
TextEditingController cExpApp2 = TextEditingController();
TextEditingController cDiscApp2 = TextEditingController();

GlobalKey<FormState> user_key = GlobalKey<FormState>();
GlobalKey<FormState> pass_key = GlobalKey<FormState>();
GlobalKey<FormState> _formKey = GlobalKey<FormState>();

String selectedOption = "";

class _MyWidgetRegState extends State<MyWidgetInsertCandidates> {
  int selectedOption = 1;
  final ImagePicker imgPicker = ImagePicker();
  File? imgFile;

  final candApp2VM = Get.put(CandView_Model());
/*
  @override
  void dispose() {
    cNameApp2.dispose();
    cNoApp2.dispose();
    cPartApp2.dispose();
    cEduApp2.dispose();
    cExpApp2.dispose();
    cDiscApp2.dispose();
    super.dispose();
  }*/

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
          isLoading: candApp2VM.isLoading.value,
          child: _XYZ(),
        ),
      ),
    );
  }

  Widget _profile_Pic() {
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
                  image: AssetImage('assets/images/userIcon.png'),
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

  Widget _XYZ() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: <Widget>[
              _profile_Pic(),
              const SizedBox(
                height: 15,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    myTextFiled(
                      myHit: 'Full name',
                      myObscureText: false,
                      myController: cNameApp2,
                      MyPrefIcon: const Icon(Icons.person_3),
                      myValidator: (value) {
                        if (value == '') {
                          return "Please input candidate name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    myTextFiled(
                      myHit: 'Candidate No.',
                      myObscureText: false,
                      myController: cNoApp2,
                      MyPrefIcon: const Icon(Icons.numbers_outlined),
                      myValidator: (value) {
                        if (value == '') {
                          return "Please input candidate #";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 226, 236, 247),
                            Color.fromARGB(255, 186, 190, 238),
                          ],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                      padding: const EdgeInsets.only(right: 65),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: const Text(
                                'Male',
                                style: TextStyle(fontFamily: 'georgia'),
                              ),
                              contentPadding: EdgeInsets.zero,
                              visualDensity:
                                  const VisualDensity(horizontal: -4),
                              leading: Radio<int>(
                                value: 1,
                                groupValue: selectedOption,
                                activeColor:
                                    const Color.fromARGB(255, 88, 134, 166),
                                fillColor: MaterialStateProperty.all(const Color
                                    .fromARGB(255, 88, 134,
                                    166)), // Change the fill color when selected
                                splashRadius:
                                    20, // Change the splash radius when clicked

                                onChanged: (int? value) {
                                  setState(() {
                                    selectedOption = value!;
                                  });
                                }, // Provide the actual selected value here
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text(
                                'Female',
                                style: TextStyle(fontFamily: 'georgia'),
                              ),
                              visualDensity:
                                  const VisualDensity(horizontal: -4),
                              leading: Radio<int>(
                                value: 2,
                                groupValue: selectedOption,
                                activeColor:
                                    const Color.fromARGB(255, 88, 134, 166),
                                fillColor: MaterialStateProperty.all(const Color
                                    .fromARGB(255, 88, 134,
                                    166)), // Change the fill color when selected
                                splashRadius:
                                    20, // Change the splash radius when clicked
                                onChanged: (int? value) {
                                  setState(() {
                                    selectedOption = value!;
                                  });
                                },
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    myTextFiled(
                      myHit: 'Party name',
                      myObscureText: false,
                      myController: cPartApp2,
                      MyPrefIcon: const Icon(Icons.flag_outlined),
                      myValidator: (value) {
                        if (value == '') {
                          return "Enter Party name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    myTextFiled(
                      myHit: 'Education',
                      myObscureText: false,
                      myController: cEduApp2,
                      MyPrefIcon: const Icon(Icons.grade_outlined),
                      myValidator: (value) {
                        if (value == '') {
                          return "Enter Candidate education";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    myTextFiled(
                      myHit: 'Experiences',
                      myObscureText: false,
                      myController: cExpApp2,
                      MyPrefIcon: const Icon(Icons.work_history_outlined),
                      myValidator: (value) {
                        if (value == '') {
                          return "Enter Candidate education";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextArea(
                      borderRadius: 30,
                      borderColor: const Color.fromARGB(255, 73, 69, 69),
                      textEditingController: cDiscApp2,
                      suffixIcon: Icons.attach_file_rounded,
                      onSuffixIconPressed: () => {},
                      validation: (true),
                      // errorText: 'Please type a reason!',
                    ),
                    Container(
                      child: InkWell(
                        onTap: () {
                          if (cNameApp2.text.isNotEmpty &&
                              cExpApp2.text.isNotEmpty &&
                              cDiscApp2.text.isNotEmpty &&
                              cNoApp2.text.isNotEmpty &&
                              cPartApp2.text.isNotEmpty &&
                              cEduApp2.text.isNotEmpty &&
                              imgFile != null) {
                            candApp2VM.addCandidate(
                                imgFile!,
                                cNameApp2.text,
                                cNoApp2.text,
                                cPartApp2.text,
                                cEduApp2.text,
                                cExpApp2.text,
                                cDiscApp2.text);
                          } else {
                            Fluttertoast.showToast(
                              msg:
                                  "Failled to add data !, Please fill up all fields",
                              toastLength: Toast
                                  .LENGTH_SHORT, // Duration for which the toast is shown
                              gravity: ToastGravity.TOP, // Toast position
                              timeInSecForIosWeb: 5, // Time in seconds for iOS
                              backgroundColor: Colors.red.withOpacity(
                                  0.7), // Background color of the toast
                              textColor:
                                  Colors.white, // Text color of the toast
                              fontSize: 16.0, // Font size of the toast message
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 40),
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
                            border:
                                Border.all(color: Colors.black), // Black border
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 77, 75, 75)
                                    .withOpacity(0.5),
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
                      ),
                    ),
                    Container(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const MyWidgetHomeApp2(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 40),
                          alignment: Alignment.center,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 35, 90, 241),
                                Color.fromARGB(255, 255, 255, 255),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border:
                                Border.all(color: Colors.black), // Black border
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 77, 75, 75)
                                    .withOpacity(0.5),
                                spreadRadius: 0.5,
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Text(
                            "Candidate List",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'georgia',
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
