import 'package:flutter/material.dart';
import 'package:omvoting/View/history.dart';
import 'package:omvoting/View/home.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.65, // Smaller width (65% of screen)
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 158, 156, 156),
            Color.fromARGB(255, 250, 236, 236),
          ],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 60),
            ListTile(
              leading: const Icon(Icons.save_outlined, color: Colors.black),
              title: const Text('Save the result',
                  style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(
                thickness: 0.5, color: Color.fromARGB(66, 61, 61, 61)),
            ListTile(
              leading: const Icon(Icons.history_sharp, color: Colors.black),
              title:
                  const Text('History', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyWidgetHistory()),
                );
              },
            ),
            const Divider(
                thickness: 0.5, color: Color.fromARGB(66, 61, 61, 61)),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: Colors.black),
              title: const Text('Home', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeClass()),
                );
              },
            ),
            const Divider(
                thickness: 0.5, color: Color.fromARGB(66, 61, 61, 61)),
            ListTile(
              leading: const Icon(Icons.logout_outlined, color: Colors.black),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
