import 'package:flutter/material.dart';
import 'package:omvoting/component/candidates.dart';
import 'package:omvoting/model/candList_app2_model.dart';
import 'package:omvoting/view/CandidateDetailsScreen.dart';
import 'package:omvoting/viewModel/candListApp2_viewModel.dart';

class MyWidgetHome extends StatefulWidget {
  const MyWidgetHome({super.key});

  @override
  _MyWidgetHomeState createState() => _MyWidgetHomeState();
}

class _MyWidgetHomeState extends State<MyWidgetHome> {
  final CandView_Model _viewModel = CandView_Model();

  @override
  void initState() {
    super.initState();
    _viewModel.fetchAllCand();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          String documentId = candidate.candNo;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MyWidgetCandDetail(documentId: documentId),
                            ),
                          );
                        },
                        child: newCandidate(
                          candidateName: candidate.candName,
                          candidateParty: candidate.candPart,
                          candidatenumber: candidate.candNo,
                          candidateVote: candidate.candVotes.toString(),
                          candidatePic: candidate.candImg,
                          candidateEdu: candidate.candEdu,
                          candidateExp: candidate.candEdu,
                          candidateDisc: candidate.candDisc,
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
