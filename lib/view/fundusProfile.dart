import 'package:flutter/material.dart';
import 'package:omvoting/Model/fundusModel.dart';
import 'package:omvoting/View/fetchFundusDitail.dart';
import 'package:omvoting/ViewModel/fundusViewModel.dart';
import 'dart:ui';

class FundusProfile extends StatefulWidget {
  final String documentId;

  const FundusProfile({
    super.key,
    required this.documentId,
  });

  @override
  _FundusProfileState createState() =>
      _FundusProfileState(documentId: documentId);
}

class _FundusProfileState extends State<FundusProfile> {
  final fundusViewModel _viewModel = fundusViewModel();
  final String documentId;
  _FundusProfileState({required this.documentId});

  @override
  void initState() {
    super.initState();
    _viewModel.fetchFundusByID(documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                tooltip: 'Back',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 55),
              const Text(
                'Fundus detail',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'georgia',
                  color: Color.fromARGB(255, 7, 1, 90),
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(100, 250, 190, 100),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            // Apply blur
            imageFilter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Image.asset(
              'assets/images/a1.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.4), // optional dark overlay
          ),

          // Main content (Expanded with StreamBuilder)
          Column(
            children: [
              Expanded(
                child: StreamBuilder<List<fundus_Model>>(
                  stream: _viewModel.allFundusList.stream,
                  builder: (context, snapshot) {
                    if (_viewModel.isLoading.value &&
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final List<fundus_Model>? f = snapshot.data;

                    if (f == null || f.isEmpty) {
                      return const Center(child: Text('No fundus available!'));
                    }

                    return ListView.builder(
                      itemCount: f.length,
                      itemBuilder: (context, index) {
                        final fu = f[index];
                        return FetchFundusDitail(
                          documentId: fu.documentId,
                          Name: fu.name,
                          Orginal: fu.orginal,
                          Date: fu.date,
                          Result: fu.result,
                          Pic: fu.img,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
