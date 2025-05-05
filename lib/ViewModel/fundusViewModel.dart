import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:omvoting/Model/fundusModel.dart';

class fundusViewModel extends GetxController {
  RxBool isLoading = false.obs;
  var allPartyList = <fundus_Model>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> addFundus(File imageFile, String fundusName, String fundusDate,
      String fundusOrginal, String fundusResult) async {
    try {
      isLoading.value = true;

      String uniqueId = DateTime.now().microsecondsSinceEpoch.toString();

      TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('images/$uniqueId.jpg')
          .putFile(imageFile);

      String downloadImageUrl = await uploadTask.ref.getDownloadURL();

      fundus_Model fundus = fundus_Model(
        img: downloadImageUrl,
        name: fundusName,
        date: fundusDate,
        orginal: fundusOrginal,
        result: fundusResult,
      );

      await FirebaseFirestore.instance
          .collection("fundus")
          .doc(uniqueId)
          .set(fundus.toMap());

      isLoading.value = false;

      Fluttertoast.showToast(
        msg: "Information Inserted Successfully",
        toastLength:
            Toast.LENGTH_SHORT, // Duration for which the toast is shown
        gravity: ToastGravity.TOP, // Toast position
        timeInSecForIosWeb: 5, // Time in seconds for iOS
        backgroundColor: const Color.fromARGB(255, 39, 250, 92)
            .withOpacity(0.7), // Background color of the toast
        textColor: Colors.white, // Text color of the toast
        fontSize: 16.0, // Font size of the toast message
      );
    } catch (error) {
      isLoading.value = false;
      String errorMessage = 'Failed to add party';
      if (error is FirebaseException) {
        errorMessage = error.message ?? 'Unknown error occurred';
      }
      Get.snackbar('Adding Party', errorMessage,
          backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
