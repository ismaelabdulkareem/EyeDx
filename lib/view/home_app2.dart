import 'package:flutter/material.dart';
import 'package:omvoting/component/candidates.dart';
import 'package:omvoting/component/candidates_app2.dart';
import 'package:omvoting/index.dart';
import 'package:omvoting/model/candList_app2_model.dart';
import 'package:omvoting/view/CandidateDetailsScreen.dart';
import 'package:omvoting/view/CandidateDetailsScreen_app2.dart';
import 'package:omvoting/view/Componets/AppBarApp2.dart';
import 'package:omvoting/view/index_app2.dart';
import 'package:omvoting/viewModel/candListApp2_viewModel.dart';
import 'package:omvoting/view/Componets/AppBarApp2.dart';

class MyWidgetHomeApp2 extends StatefulWidget {
  const MyWidgetHomeApp2({super.key});

  @override
  _MyWidgetHomeApp2State createState() => _MyWidgetHomeApp2State();
}

class _MyWidgetHomeApp2State extends State<MyWidgetHomeApp2> {
  final CandView_Model _viewModel = CandView_Model();

  @override
  void initState() {
    super.initState();
    _viewModel.fetchAllCand();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 20), // Adjust left padding as needed
          child: Row(
            children: [
              Icon(Icons.account_box),
              SizedBox(width: 8),
              Text(
                'Candidate List',
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
        backgroundColor: const Color.fromARGB(255, 191, 206, 245),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20), // Adjust horizontal padding as needed
            child: IconButton(
              icon:
                  const Icon(Icons.add_outlined), // Your additional button icon
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: StreamBuilder<List<CandListApp2_Model>>(
                stream: _viewModel.allCandList.stream,
                builder: (context, snapshot) {
                  if (_viewModel.isLoading.value &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final List<CandListApp2_Model>? candidates = snapshot.data;

                  if (candidates == null || candidates.isEmpty) {
                    return const Center(child: Text('No candidates available'));
                  }

                  return ListView.builder(
                    itemCount: candidates.length,
                    itemBuilder: (context, index) {
                      final candidate = candidates[index];
                      return GestureDetector(
                        onTap: () {
                          String docId = candidate.candNo;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyWidgetCandDetailApp2(
                                documentId: docId,
                              ),
                              //MyWidgetCandDetail(documentId: docId),
                            ),
                          );
                        },
                        child: newCandidateApp2(
                          candidateName: candidate.candName,
                          candidateParty: candidate.candPart,
                          candidatenumber: candidate.candNo,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
