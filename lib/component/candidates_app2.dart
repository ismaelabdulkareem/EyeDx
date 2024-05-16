import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class newCandidateApp2 extends StatelessWidget {
  final String candidateName;
  final String candidateParty;
  final String candidatenumber;

  const newCandidateApp2({
    super.key,
    required this.candidateName,
    required this.candidateParty,
    required this.candidatenumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // my style
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
      margin: const EdgeInsets.only(left: 20, right: 30, top: 5),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 134, 172, 253),
            Color.fromARGB(255, 255, 255, 255),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
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
                          fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    child: Text(
                      'Party : $candidateParty',
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
                            Color.fromARGB(255, 6, 34, 196),
                            Color.fromRGBO(243, 228, 14, 0.004)
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        width: 3,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        candidatenumber,
                        style: const TextStyle(
                            fontFamily: 'georgia',
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Text(
                    'Number',
                    style: TextStyle(fontFamily: 'georgia'),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
