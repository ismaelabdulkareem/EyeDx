import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:omvoting/Model/fundusModel.dart';
import 'package:omvoting/View/appBar.dart';
import 'package:omvoting/View/drwaer.dart';
import 'package:omvoting/View/fundusImages.dart';
import 'package:omvoting/View/fundusProfile.dart';
import 'package:omvoting/ViewModel/fundusViewModel.dart';
import 'dart:ui';

class MyWidgetHistory extends StatefulWidget {
  const MyWidgetHistory({super.key});

  @override
  _MyWidgetHistoryState createState() => _MyWidgetHistoryState();
}

class _MyWidgetHistoryState extends State<MyWidgetHistory> {
  final fundusViewModel _viewModel =
      Get.put(fundusViewModel(), permanent: false);

  @override
  void dispose() {
    if (Get.isRegistered<fundusViewModel>()) {
      Get.delete<fundusViewModel>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarClass(
        onSave: () {},
        isSaveEnabled: false,
      ),
      drawer: const MyDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with blur effect
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Image.asset(
              'assets/images/a4.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Optional dark overlay for more readability
          Container(
            color: Colors.black.withOpacity(0), // Adjust opacity as needed
          ),

          // Main content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: Column(
              children: [
                const SizedBox(height: 15),
                Expanded(
                  child: Obx(() {
                    if (_viewModel.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_viewModel.allFundusList.isEmpty) {
                      return const Center(child: Text('No Fundus available'));
                    }

                    return ListView.builder(
                      itemCount: _viewModel.allFundusList.length,
                      itemBuilder: (context, index) {
                        final f = _viewModel.allFundusList[index];
                        return GestureDetector(
                          onTap: () {
                            String docId = f.documentId;
                            HapticFeedback.vibrate();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FundusProfile(documentId: docId),
                              ),
                            );
                          },
                          child: FundusImages(
                            Name: f.name,
                            Orginal: f.orginal,
                            Date: f.date,
                            Result: f.result,
                            Pic: f.img,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
