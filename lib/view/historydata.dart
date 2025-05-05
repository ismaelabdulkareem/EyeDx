import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class newHistory extends StatelessWidget {
  final String candidateName;
  final String candidateParty;
  final String candidatenumber;
  final String candidateVote;
  final String candidatePic;
  final String candidateEdu;
  final String candidateExp;
  final String candidateDisc;

  const newHistory({
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
      // my style
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      margin: const EdgeInsets.only(left: 30, right: 30, top: 15),
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

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 224, 99, 99), // Border color
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
          SizedBox(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    child: Text(
                      candidateName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontFamily: 'georgia'),
                    ),
                  ),
                  SizedBox(
                    child: Text(
                      'Party : $candidateParty',
                      style: const TextStyle(fontFamily: 'georgia'),
                    ),
                  ),
                  SizedBox(
                    child: Text(
                      'Candidate Number :  $candidatenumber ',
                      style: const TextStyle(fontFamily: 'georgia'),
                    ),
                  ),
                ]),
          ),
          SizedBox(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: 45,
                    width: 45,
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
                ]),
          ),
        ],
      ),
    );
  }
}
