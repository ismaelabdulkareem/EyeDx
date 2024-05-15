import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:omvoting/model/partieslist_app2_model.dart';

class PartyViewModel extends GetxController {
  RxBool isLoading = false.obs;
  var allPartyList = <PartiesListApp2Model>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllParty();
  }

  void fetchAllParty() async {
    isLoading.value = true;
    allPartyList.clear();
    await FirebaseFirestore.instance
        .collection("party")
        .get()
        .then((QuerySnapshot snapshot) {
      for (var u in snapshot.docs) {
        allPartyList.add(
          PartiesListApp2Model(
            partyName: u['pName'],
            partyId: u['pId'],
            image: u['pImage'],
            partyVotes: u['pVotes'],
            partyColor: u['pColor'],
          ),
        );
      }

      isLoading.value = false;
    });
  }

  Future<void> addParty(File imageFile, String partName, String partNo,
      int partyVotes, Color partyColor) async {
    try {
      isLoading.value = true;

      String uniqueId = DateTime.now().microsecondsSinceEpoch.toString();

      TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('images/$uniqueId.jpg')
          .putFile(imageFile);

      String downloadImageUrl = await uploadTask.ref.getDownloadURL();
      // Convert partyColor to hexadecimal string
      String colorHexString =
          partyColor.value.toRadixString(16).padLeft(8, '0');

      PartiesListApp2Model party = PartiesListApp2Model(
        partyName: partName,
        partyId: partNo,
        image: downloadImageUrl,
        partyVotes: partyVotes,
        partyColor: colorHexString,
      );

      await FirebaseFirestore.instance
          .collection("party")
          .doc(uniqueId)
          .set(party.toMap());

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
