import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:omvoting/index.dart';
import 'package:omvoting/view/home_app2.dart';
import 'package:omvoting/view/index_app2.dart';
import 'package:omvoting/viewModel/candListApp2_viewModel.dart';

class CandidateDelDone extends StatefulWidget {
  final String candidateName;
  final String candidatePic;
  const CandidateDelDone({
    super.key,
    required this.candidateName,
    required this.candidatePic,
  });

  @override
  State<CandidateDelDone> createState() => _CandidateDelDoneState();
}

class _CandidateDelDoneState extends State<CandidateDelDone> {
  final CandView_Model _viewModel3 = CandView_Model();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Deletion'),
        backgroundColor: const Color.fromARGB(255, 191, 206, 245),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
              margin: const EdgeInsets.only(
                  top: 15, bottom: 25, right: 20, left: 20),
              decoration: const BoxDecoration(
                boxShadow: [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(
                            255, 43, 20, 170), // Border color
                        width: 3.0,
                        // Border width
                      ),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(widget.candidatePic),
                        fit: BoxFit
                            .cover, // Adjust this based on your preference
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          child: Text(
                            'Deleting ${widget.candidateName} successfully submitted',
                            style: const TextStyle(
                                fontFamily: 'georgia',
                                fontSize: 14,
                                color: Colors.green),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const SizedBox(
                          child: Text(
                            // 'Candidate Number :  ${widget.candidatenumber} ',
                            'Thank you for your participating',
                            style: TextStyle(
                              fontFamily: 'georgia',
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 35,
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
                child: const Text('Back to candidate list'),
                onPressed: () {
                  setState(() {});
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyWidgetHomeApp2()),
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
