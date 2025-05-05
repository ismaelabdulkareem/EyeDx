import 'package:flutter/material.dart';
import 'package:omvoting/View/home.dart';

class AppBarClass extends StatelessWidget implements PreferredSizeWidget {
  const AppBarClass({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(25),
        bottomRight: Radius.circular(25),
      ),
      child: Container(
        height: preferredSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topRight,
            colors: [
              Color.fromARGB(255, 221, 220, 220),
              Color.fromARGB(255, 255, 244, 244),
            ],
          ),
        ),
        child: AppBar(
          elevation: 0,
          backgroundColor:
              Colors.transparent, // Make background transparent to see gradient
          toolbarHeight: 130,
          leading: IconButton(
            color: const Color.fromARGB(255, 0, 0, 0),
            padding: const EdgeInsets.only(left: 30, bottom: 15),
            icon: const Icon(Icons.menu_outlined),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Opens the drawer
            },
          ),
          centerTitle: true,
          title: const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              "Fundus Classifer",
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Georgia',
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              padding: const EdgeInsets.only(right: 30, bottom: 15),
              iconColor: const Color.fromARGB(255, 0, 0, 0),
              itemBuilder: (BuildContext context) {
                return [
                  _popupItem("My Account", context),
                  _popupItem("Setting", context),
                  _popupItem("Logout", context),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _popupItem(String title, BuildContext context) {
    return PopupMenuItem<String>(
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeClass()),
          );
        },
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'Georgia',
            color: Color.fromARGB(255, 94, 4, 4),
            fontWeight: FontWeight.w200,
          ),
        ),
      ),
    );
  }
}
