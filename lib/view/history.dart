import 'package:flutter/material.dart';
import 'package:omvoting/View/appBar.dart';
import 'package:omvoting/View/drwaer.dart';

class MyWidgetHistory extends StatefulWidget {
  const MyWidgetHistory({super.key});

  @override
  _MyWidgetHistoryState createState() => _MyWidgetHistoryState();
}

class _MyWidgetHistoryState extends State<MyWidgetHistory> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarClass(),
      drawer: const MyDrawer(),
      body: Container(
        width: double.infinity,
        child: const Column(
          children: [
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
