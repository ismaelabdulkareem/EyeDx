import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:omvoting/index.dart';
import 'package:omvoting/view/DelDone.dart';
import 'package:omvoting/view/votingDone.dart';
import 'package:omvoting/viewModel/candListApp2_viewModel.dart';

class CandidateDitailDel extends StatefulWidget {
  final String candidateName;
  final String candidateParty;
  final String candidatenumber;
  final int candidateVote;
  final String candidatePic;
  final String candidateEdu;
  final String candidateExp;
  final String candidateDisc;

  const CandidateDitailDel({
    super.key,
    required this.candidateName,
    required this.candidateParty,
    required this.candidatenumber,
    required this.candidateVote,
    required this.candidatePic,
    required this.candidateEdu,
    required this.candidateExp,
    required this.candidateDisc,
  });

  @override
  State<CandidateDitailDel> createState() => _CandidateDitailDelState();
}

class _CandidateDitailDelState extends State<CandidateDitailDel> {
  final CandView_Model _viewModel3 = CandView_Model();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
            margin:
                const EdgeInsets.only(top: 15, bottom: 25, right: 20, left: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 207, 217, 240),
                  Color.fromARGB(255, 248, 241, 241),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromARGB(255, 11, 53, 194), // Border color
                      width: 3.0,
                      // Border width
                    ),
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: NetworkImage(widget.candidatePic),
                      fit: BoxFit.cover, // Adjust this based on your preference
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        child: Text(
                          widget.candidateName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'georgia',
                              fontSize: 26),
                        ),
                      ),
                      SizedBox(
                        child: Text(
                          widget.candidateParty,
                          style: const TextStyle(
                              fontFamily: 'georgia', fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        child: Text(
                          'Candidate Number :  ${widget.candidatenumber} ',
                          style: const TextStyle(fontFamily: 'georgia'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: 55,
                        width: 55,
                        decoration: const BoxDecoration(
                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(255, 77, 16, 243),
                                Color.fromRGBO(243, 228, 14, 0.004)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${widget.candidateVote}',
                            style: const TextStyle(
                                fontFamily: 'georgia',
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const Text(
                        'Votes',
                        style: TextStyle(fontFamily: 'georgia'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 240, 66, 66),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Candidate'),
              onPressed: () {
                // _viewModel3.isLoading.value = true;
                _viewModel3.deletecandidate(widget.candidatenumber);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CandidateDelDone(
                            candidateName: widget.candidateName,
                            candidatePic: widget.candidatePic,
                          )),
                );
// CandidateVoteDone(
//                             candidateName: widget.candidateName,
//                             candidateParty: widget.candidateParty,
//                             candidatenumber: widget.candidatenumber,
//                             candidateVote: widget.candidateVote + 1,
//                             candidatePic: widget.candidatePic,
//                             candidateEdu: widget.candidateEdu,
//                             candidateExp: widget.candidateExp,
//                             candidateDisc: widget.candidateDisc,
//                           )
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
