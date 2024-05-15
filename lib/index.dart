import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:omvoting/account.dart';
import 'package:omvoting/view/CandidateDetailsScreen.dart';
import 'package:omvoting/view/home.dart';
import 'package:omvoting/news.dart';
import 'package:omvoting/view/results.dart';
import 'package:omvoting/view/votingDone.dart';

class MyWidgetIndex extends StatefulWidget {
  int i = 0;
  String swch = "default";

  MyWidgetIndex(
    int i, {
    super.key,
  }) {
    this.i = i;
  }

  String docID = "";

  MyWidgetIndex.cons2(
    this.swch,
    String docID, {
    Key? key,
  }) : super(key: key) {
    this.swch = swch;
    this.docID = docID;
  }
  String candidateName = "";
  String candidateParty = "";
  String candidatenumber = "";
  int candidateVote = 0;
  String candidatePic = "";
  String candidateEdu = "";
  String candidateExp = "";
  String candidateDisc = "";

  MyWidgetIndex.cons3(
    this.swch,
    String candidateName,
    String candidateParty,
    String candidatenumber,
    int candidateVote,
    String candidatePic,
    String candidateEdu,
    String candidateExp,
    String candidateDisc, {
    Key? key,
  }) : super(key: key) {
    this.swch = swch;
    this.candidateName = candidateName;
    this.candidateParty = candidateParty;
    this.candidatenumber = candidatenumber;
    this.candidateVote = candidateVote;
    this.candidateEdu = candidateEdu;
    this.candidateEdu = candidateEdu;
    this.candidateExp = candidateExp;
    this.candidateDisc = candidateDisc;
  }

  @override
  State<MyWidgetIndex> createState() => _MyWidgetIndexState(documentId: docID);
}

class _MyWidgetIndexState extends State<MyWidgetIndex> {
  int _currentIndex = 0;
  String documentId;
  _MyWidgetIndexState({required this.documentId});

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Widget> wlist = [];

  @override
  Widget build(BuildContext context) {
    _currentIndex = widget.i;

    widget.i;

    wlist = [
      if (widget.swch == "toVote")
        MyWidgetCandDetail(
          documentId: documentId,
        )
      else if (widget.swch == "default")
        const MyWidgetHome()
      else if (widget.swch == "toDone")
        CandidateVoteDone(
          candidateName: widget.candidateName,
          candidateParty: widget.candidateParty,
          candidatenumber: widget.candidatenumber,
          candidateVote: widget.candidateVote,
          candidatePic: widget.candidatePic,
          candidateEdu: widget.candidateEdu,
          candidateExp: widget.candidateExp,
          candidateDisc: widget.candidateDisc,
        ),
      const MyWidgetNews(),
      const MyWidgetRes(),
      const MyWidgetAcc(),
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        leading: IconButton(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 30, bottom: 30),
          icon: const Icon(Icons.menu_outlined),
          onPressed: () {
            if (scaffoldKey.currentState != null) {
              if (scaffoldKey.currentState!.isDrawerOpen) {
                scaffoldKey.currentState!.closeDrawer();
              } else {
                scaffoldKey.currentState!.openDrawer();
              }
            }
          },
        ),
        //   elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/BarApp2.png'),
                  fit: BoxFit.fill)),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.only(bottom: 30),
          child: Form(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: TextFormField(
                style: const TextStyle(
                  fontFamily: 'georgia',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                decoration: const InputDecoration(
                  filled: true,
                  hintText: 'Search',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                  fillColor: Color.fromARGB(255, 247, 227, 227),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
            ),
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
                widget.i = index;
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
