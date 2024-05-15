import 'package:flutter/material.dart';
import 'package:omvoting/component/cand_del.dart';
import 'package:omvoting/component/cand_vote.dart';
import 'package:omvoting/model/candList_app2_model.dart';
import 'package:omvoting/viewModel/candListApp2_viewModel.dart';

class MyWidgetCandDetailApp2 extends StatefulWidget {
  final String documentId;

  const MyWidgetCandDetailApp2({
    super.key,
    required this.documentId,
  });

  @override
  _MyWidgetCandDetailApp2State createState() =>
      _MyWidgetCandDetailApp2State(documentId: documentId);
}

class _MyWidgetCandDetailApp2State extends State<MyWidgetCandDetailApp2> {
  final CandView_Model _viewModel1 = CandView_Model();
  final String documentId;
  _MyWidgetCandDetailApp2State({required this.documentId});

  @override
  void initState() {
    super.initState();
    _viewModel1.fetchCandidateByNo(documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate List'),
        backgroundColor: const Color.fromARGB(255, 191, 206, 245),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<CandListApp2_Model>>(
              stream: _viewModel1.allCandList.stream,
              builder: (context, snapshot) {
                if (_viewModel1.isLoading.value &&
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

                    return CandidateDitailDel(
                      candidateName: candidate.candName,
                      candidateParty: candidate.candPart,
                      candidatenumber: candidate.candNo,
                      candidateVote: candidate.candVotes,
                      candidatePic: candidate.candImg,
                      candidateEdu: candidate.candEdu,
                      candidateExp: candidate.candEdu,
                      candidateDisc: candidate.candDisc,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
