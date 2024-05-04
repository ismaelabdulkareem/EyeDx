import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:omvoting/component/cand_vote.dart';
import 'package:omvoting/component/candidates.dart';
import 'package:omvoting/model/candList_app2_model.dart';
import 'package:omvoting/viewModel/candListApp2_viewModel.dart';

class MyWidgetCandDetail extends StatefulWidget {
  final String documentId;

  const MyWidgetCandDetail({
    super.key,
    required this.documentId,
  });

  @override
  _MyWidgetCandDetailState createState() =>
      _MyWidgetCandDetailState(documentId: documentId);
}

class _MyWidgetCandDetailState extends State<MyWidgetCandDetail> {
  final CandView_Model _viewModel1 = CandView_Model();
  final String documentId;
  _MyWidgetCandDetailState({required this.documentId});

  @override
  void initState() {
    super.initState();
    _viewModel1.fetchCandidateByNo(documentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 140,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/BarApp2.png'),
                  fit: BoxFit.fill)),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.only(bottom: 30),
          child: const Text(
            'Candiadate Ditails',
            style: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            padding: EdgeInsets.only(right: 30, bottom: 30),
            iconColor: Colors.white,
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'georgia',
                        color: Color.fromARGB(255, 94, 4, 4),
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'option2',
                  child: Text('Option 2'),
                ),
                const PopupMenuItem<String>(
                  value: 'option3',
                  child: Text('Option 3'),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
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

                    return CandidateDitailVote(
                      candidateName: candidate.candName,
                      candidateParty: candidate.candPart,
                      candidatenumber: candidate.candNo,
                      candidateVote: candidate.candVotes.toString(),
                      candidatePic: candidate.candImg,
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
