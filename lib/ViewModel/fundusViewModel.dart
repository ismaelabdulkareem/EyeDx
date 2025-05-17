import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:omvoting/Model/fundusModel.dart';

class fundusViewModel extends GetxController {
  RxBool isLoading = false.obs;
  var allFundusList = <fundus_Model>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllFundus();
  }

  Future<void> addFundus(File imageFile, String fundusDate,
      String fundusOrginal, String fundusResult) async {
    try {
      isLoading.value = true;

      String uniqueId = DateTime.now().microsecondsSinceEpoch.toString();

      TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('fundus_images/$uniqueId.jpg')
          .putFile(imageFile);

      String downloadImageUrl = await uploadTask.ref.getDownloadURL();

      fundus_Model fundus = fundus_Model(
        uniqueId,
        img: downloadImageUrl,
        name: '$uniqueId.jpg',
        date: fundusDate,
        orginal: fundusOrginal,
        result: fundusResult,
      );

      await FirebaseFirestore.instance
          .collection("fundus")
          .doc(uniqueId)
          .set(fundus.toMap());

      isLoading.value = false;

      // Fluttertoast.showToast(
      //   msg: "Information Inserted Successfully",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.TOP,
      //   timeInSecForIosWeb: 5,
      //   backgroundColor:
      //       const Color.fromARGB(255, 39, 250, 92).withOpacity(0.7),
      //   textColor: const Color.fromARGB(255, 0, 0, 0),
      //   fontSize: 16.0,
      // );
    } catch (error) {
      isLoading.value = false;
      String errorMessage = 'Failed to add the Fundus image';

      if (error is FirebaseException) {
        errorMessage = error.message ?? 'Unknown Firebase error occurred';
      } else {
        errorMessage = error.toString();
      }

      Get.snackbar(
        'Adding Fundus',
        errorMessage,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> uploadImageAndSaveInfo(File imageFile, String fundusName,
      String fundusDate, String fundusOrginal, String fundusResult) async {
    if (imageFile == null || !await imageFile.exists()) {
      Fluttertoast.showToast(msg: "Image file is invalid.");
      return;
    }

    final imageRef = FirebaseStorage.instance
        .ref("fundus_images/${DateTime.now().millisecondsSinceEpoch}.jpg");

    try {
      final uploadTask = imageRef.putFile(imageFile);
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadURL = await snapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance.collection('fundus').add({
          'fImg': downloadURL,
          'fName': fundusName,
          'fDate': fundusDate,
          'fOrginal': fundusOrginal,
          'fResult': fundusResult
        });

        Fluttertoast.showToast(msg: "Upload and save successful!");
      } else {
        Fluttertoast.showToast(msg: "Image upload failed.");
      }
    } catch (e) {
      debugPrint("Firebase error: $e");
      Fluttertoast.showToast(
        msg: "Error uploading/saving image: $e",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  void fetchAllFundus() {
    isLoading.value = true;

    FirebaseFirestore.instance
        .collection("fundus")
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      allFundusList.value = snapshot.docs.map((doc) {
        return fundus_Model(
          doc.id,
          img: doc['fImg'],
          name: doc['fName'],
          date: doc['fDate'],
          orginal: doc['fOrginal'],
          result: doc['fResult'],
        );
      }).toList();
      isLoading.value = false;
    });
  }

  void fetchFundusByID(String cNo) async {
    isLoading.value = true;
    allFundusList.clear();

    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection("fundus").doc(cNo).get();

      if (doc.exists) {
        allFundusList.add(
          fundus_Model(
            doc.id,
            img: doc['fImg'],
            name: doc['fName'],
            date: doc['fDate'],
            orginal: doc['fOrginal'],
            result: doc['fResult'],
          ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error fetching fundus by ID: $e",
        toastLength: Toast.LENGTH_LONG,
      );
    }

    isLoading.value = false;
  }

  void deleteFundus1(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('fundus').doc(docId).delete();

      Fluttertoast.showToast(
        msg: 'Fundus Deleted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 45, 189, 17),
        textColor: const Color.fromARGB(255, 0, 0, 0),
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error Deleting document : $e',
      );
    }
  }

  Future<void> deleteFundus2(String documentId, String pic) async {
    try {
      await FirebaseFirestore.instance
          .collection('fundus')
          .doc(documentId)
          .delete();
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<void> deleteFundus(String documentId, String imageUrl) async {
    try {
      // Get the reference to the image in Firebase Storage
      Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);

      // Delete the image from Firebase Storage
      await imageRef.delete();

      // Delete the corresponding Firestore document
      await FirebaseFirestore.instance
          .collection('fundus')
          .doc(documentId)
          .delete();

      print('Document and image deleted successfully');
    } catch (e) {
      print('Error deleting document or image: $e');
    }
  }
}
