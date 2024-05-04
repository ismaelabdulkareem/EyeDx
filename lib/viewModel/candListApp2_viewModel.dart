import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:omvoting/model/candList_app2_model.dart';

class CandView_Model extends GetxController {
  RxBool isLoading = false.obs;
  var allCandList = <CandListApp2_Model>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCand();
  }

  void fetchAllCand() async {
    isLoading.value = true;
    allCandList.clear();
    await FirebaseFirestore.instance
        .collection("candidate")
        .get()
        .then((QuerySnapshot snapshot) {
      for (var u in snapshot.docs) {
        allCandList.add(
          CandListApp2_Model(
            candImg: u['cImg'],
            candName: u['cName'],
            candNo: u['cNo'],
            candPart: u['cPart'],
            candEdu: u['cEdu'],
            candExp: u['cExp'],
            candDisc: u['cDisc'],
            candVotes: u['cVotes'],
          ),
        );
      }
      isLoading.value = false;
    });
  }

  void fetchCandidateByNo(String cNo) async {
    isLoading.value = true;
    allCandList.clear();

    await FirebaseFirestore.instance
        .collection("candidate")
        .where("cNo", isEqualTo: cNo)
        .get()
        .then((QuerySnapshot snapshot) {
      for (var u in snapshot.docs) {
        allCandList.add(
          CandListApp2_Model(
            candImg: u['cImg'],
            candName: u['cName'],
            candNo: u['cNo'],
            candPart: u['cPart'],
            candEdu: u['cEdu'],
            candExp: u['cExp'],
            candDisc: u['cDisc'],
            candVotes: u['cVotes'],
          ),
        );
      }
      isLoading.value = false;
    });
  }

  Future<void> fetchOneRow(String documentId) async {
    if (documentId.isEmpty) {
      throw ArgumentError('Document ID cannot be null or empty');
    }

    isLoading.value = true;
    allCandList.clear();

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("candidate")
          .doc(documentId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        allCandList.add(
          CandListApp2_Model(
            candImg: data['cImg'] ?? '',
            candName: data['cName'] ?? '',
            candNo: data['cNo'] ?? '',
            candPart: data['cPart'] ?? '',
            candEdu: data['cEdu'] ?? '',
            candExp: data['cExp'] ?? '',
            candDisc: data['cDisc'] ?? '',
            candVotes:
                data['cVotes'] ?? 100, // default value if cVotes is missing
          ),
        );
      } else {
        print('Document with ID $documentId does not exist');
      }
    } catch (e) {
      print('Error fetching document: $e');
      // Handle error gracefully, e.g., show a message to the user
    }

    isLoading.value = false;
  }

  Future<void> addCandidate(File imagefileCand, String candName, String candNo,
      String candPart, String candEdu, String candExp, String candDisc) async {
    try {
      isLoading.value = true;

      String uniqueId = DateTime.now().microsecondsSinceEpoch.toString();

      TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('images/$uniqueId.jpg')
          .putFile(imagefileCand);

      String downloadImageUrl = await uploadTask.ref.getDownloadURL();

      CandListApp2_Model candi = CandListApp2_Model(
        candImg: downloadImageUrl,
        candName: candName,
        candNo: candNo,
        candPart: candPart,
        candEdu: candEdu,
        candExp: candExp,
        candDisc: candDisc,
        candVotes: 100,
      );

      await FirebaseFirestore.instance
          .collection("candidate")
          .doc(uniqueId)
          .set(candi.toMap());

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
      String errorMessage = 'Failed to add Candidate';
      if (error is FirebaseException) {
        errorMessage = error.message ?? 'Unknown error occurred';
      }
      Get.snackbar('Adding candidate', errorMessage,
          backgroundColor: Colors.red, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
