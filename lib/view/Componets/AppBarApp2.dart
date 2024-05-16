import 'package:flutter/material.dart';

class AppBarApp2 extends StatelessWidget {
  const AppBarApp2({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Row(
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
      backgroundColor: const Color.fromARGB(255, 191, 206, 245),
    );
  }
}
