import 'package:flutter/material.dart';
import 'package:omvoting/component/candidates.dart';
import 'package:omvoting/component/candidates_app2.dart';
import 'package:omvoting/index.dart';
import 'package:omvoting/model/candList_app2_model.dart';
import 'package:omvoting/view/CandidateDetailsScreen.dart';
import 'package:omvoting/view/CandidateDetailsScreen_app2.dart';
import 'package:omvoting/viewModel/candListApp2_viewModel.dart';

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
        title: const Text('Candidate List'),
        backgroundColor: const Color.fromARGB(255, 191, 206, 245),
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
          ],
        ),
      ),
    );
  }
}
