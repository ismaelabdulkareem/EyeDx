import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class CandidateDitailVote extends StatelessWidget {
  final String candidateName;
  final String candidateParty;
  final String candidatenumber;
  final String candidateVote;
  final String candidatePic;
  final String candidateEdu;
  final String candidateExp;
  final String candidateDisc;

  const CandidateDitailVote({
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
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
            margin:
                const EdgeInsets.only(top: 15, bottom: 25, right: 20, left: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 228, 225, 225),
                  Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 77, 75, 75).withOpacity(0.5),
                  spreadRadius: 0.5,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
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
                          255, 224, 99, 99), // Border color
                      width: 3.0,
                      // Border width
                    ),
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(candidatePic),
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
                          candidateName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'georgia',
                              fontSize: 26),
                        ),
                      ),
                      SizedBox(
                        child: Text(
                          candidateParty,
                          style: const TextStyle(
                              fontFamily: 'georgia', fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        child: Text(
                          'Candidate Number :  $candidatenumber ',
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
                                Color.fromARGB(255, 255, 0, 0),
                                Color.fromRGBO(243, 228, 14, 0.004)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            width: 3,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            candidateVote,
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
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                child: Text(
                                  'Certification',
                                  style: TextStyle(
                                      fontFamily: 'georgia',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                child: Text(
                                  ' | ',
                                  style: TextStyle(
                                      fontFamily: 'georgia',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                child: Text(
                                  candidateEdu,
                                  style: const TextStyle(
                                    fontFamily: 'georgia',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                child: Text(
                                  'Expereince',
                                  style: TextStyle(
                                      fontFamily: 'georgia',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                child: Text(
                                  ' | ',
                                  style: TextStyle(
                                      fontFamily: 'georgia',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                child: Text(
                                  candidateExp,
                                  style: const TextStyle(fontFamily: 'georgia'),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                child: Text(
                                  'Plan',
                                  style: TextStyle(
                                      fontFamily: 'georgia',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(
                                child: Text(
                                  ' | ',
                                  style: TextStyle(
                                      fontFamily: 'georgia',
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                child: Text(
                                  candidateDisc,
                                  style: const TextStyle(fontFamily: 'georgia'),
                                ),
                              ),
                            ],
                          ),
                        ],
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
              child: const Text('Submit Vote'),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
