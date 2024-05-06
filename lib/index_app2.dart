import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import 'package:omvoting/view/partieslist_app2.dart';
import 'package:omvoting/view/candidatelist_app2.dart';
//import 'package:votingapp/component/myDrawer.dart';

class MyWidgetIndex_app2 extends StatefulWidget {
  const MyWidgetIndex_app2({super.key});

  @override
  State<MyWidgetIndex_app2> createState() => _MyWidgetHomeState();
}

class _MyWidgetHomeState extends State<MyWidgetIndex_app2> {
  int _currentIndex = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> wlist = const [
    MyWidgetInsertParties(),
    MyWidgetInsertCandidates(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 130,
        leading: IconButton(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 30, bottom: 30),
          icon: const Icon(Icons.menu_outlined),
          onPressed: () {
            if (scaffoldKey.currentState!.isDrawerOpen) {
              scaffoldKey.currentState!.closeDrawer();
              //close drawer, if drawer is open
            } else {
              scaffoldKey.currentState!.openDrawer();
              //open drawer, if drawer is closed
            }
          },
        ),
        //   elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/BarApp.png'),
                  fit: BoxFit.fill)),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.only(bottom: 30),
          child: const Text(
            'List',
            style: TextStyle(color: Colors.white),
          ),
        ),

        actions: [
          PopupMenuButton<String>(
            padding: const EdgeInsets.only(right: 30, bottom: 30),
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
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 35, 132, 243),
              ),
              accountName: const Text(
                "Online Voting Application",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: const Text(
                "Ismael Abdulkareem",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture: Container(
                //   margin: const EdgeInsets.only(right: 75),
                height: 120,
                decoration: const BoxDecoration(
                  border: GradientBoxBorder(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 0, 0),
                        Color.fromRGBO(98, 3, 250, 0.004),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    width: 4,
                  ),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://cdn4.iconfinder.com/data/icons/man-6/48/man-09-512.png'),
                    fit: BoxFit
                        .fitHeight, // Adjust this based on your preference
                  ),
                ),
              ),
            ),
            ListTile(
                leading: const Icon(
                  Icons.people_outline,
                ),
                title: const Text('List of parties'),
                onTap: () {}),
            ListTile(
              leading: const Icon(
                Icons.people_outline_outlined,
              ),
              title: const Text('List of candidates'),
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (BuildContext context) =>
                //         const MyWidgetInsertCandidates(),
                //   ),
                // );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout_outlined,
              ),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const AboutListTile(
              // <-- SEE HERE
              icon: Icon(
                Icons.info,
              ),
              child: Text('About app'),
              applicationIcon: Icon(
                Icons.local_play,
              ),
              applicationName: 'My Cool App',
              applicationVersion: '1.0.25',
              applicationLegalese: '© 2019 Company',
              aboutBoxChildren: [
                ///Content goes here...
              ],
            ),
          ],
        ),
      ),
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
            backgroundColor: const Color.fromARGB(255, 7, 110, 206),
            unselectedIconTheme:
                const IconThemeData(color: Color.fromARGB(255, 113, 185, 243)),
            selectedIconTheme: const IconThemeData(
                color: Color.fromARGB(255, 255, 255, 255), size: 35),
            iconSize: 35,
            selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
            unselectedItemColor: Color.fromARGB(255, 223, 219, 219),
            selectedLabelStyle: TextStyle(fontFamily: 'georgia'),
            unselectedLabelStyle: TextStyle(fontFamily: 'georgia'),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                label: 'Parties List',
                icon: Icon(
                  Icons.people_outline,
                ),
              ),
              BottomNavigationBarItem(
                label: 'Candidates List',
                icon: Icon(
                  Icons.man_2_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
