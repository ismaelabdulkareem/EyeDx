import 'package:flutter/material.dart';
import 'package:omvoting/account.dart';
import 'package:omvoting/view/home.dart';
import 'package:omvoting/news.dart';
import 'package:omvoting/view/results.dart';

class MyWidgetIndex extends StatefulWidget {
  const MyWidgetIndex({
    super.key,
  });

  @override
  State<MyWidgetIndex> createState() => _MyWidgetHomeState();
}

class _MyWidgetHomeState extends State<MyWidgetIndex> {
  int _currentIndex = 0;

  List<Widget> wlist = const [
    MyWidgetHome(),
    MyWidgetNews(),
    MyWidgetRes(),
    MyWidgetAcc(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: wlist,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(),
        height: 75,
        padding: const EdgeInsets.only(bottom: 6, left: 10, right: 10),
        child: ClipRRect(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: const Color.fromARGB(255, 240, 88, 88),
            unselectedIconTheme:
                const IconThemeData(color: Color.fromARGB(255, 248, 191, 191)),
            selectedIconTheme: const IconThemeData(
                color: Color.fromARGB(255, 0, 0, 0), size: 35),
            iconSize: 35,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                label: 'Home',
                icon: Icon(
                  Icons.home_outlined,
                ),
              ),
              BottomNavigationBarItem(
                label: 'News',
                icon: Icon(
                  Icons.newspaper_outlined,
                ),
              ),
              BottomNavigationBarItem(
                label: 'Search',
                icon: ImageIcon(AssetImage('assets/images/resultIcon.png')),
              ),
              BottomNavigationBarItem(
                label: 'Setting',
                icon: Icon(
                  Icons.account_box_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
