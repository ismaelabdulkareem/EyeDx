import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omvoting/View/home.dart';

class AppBarClass extends StatelessWidget implements PreferredSizeWidget {
  final void Function()? onSave; // Make it nullable and optional
  final bool isSaveEnabled;

  const AppBarClass({super.key, this.onSave, required this.isSaveEnabled});

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
              HapticFeedback.vibrate();
              Scaffold.of(context).openDrawer(); // Opens the drawer
            },
          ),
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Eye',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Stack(
                  children: [
                    // Border (stroke) text
                    Text(
                      'Dx',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1
                          ..color = Colors.black,
                      ),
                    ),
                    // Gradient fill
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          colors: [
                            Colors.orange,
                            Color.fromARGB(255, 240, 197, 112),
                          ],
                        ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                      },
                      blendMode: BlendMode.srcIn,
                      child: const Text(
                        'Dx',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .white, // Required but overridden by gradient
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          actions: [
            PopupMenuButton<String>(
              padding: const EdgeInsets.only(right: 30, bottom: 15),
              iconColor: const Color.fromARGB(255, 0, 0, 0),
              itemBuilder: (BuildContext context) {
                return [
                  _popupItem("Refresh", context, true),
                  _popupItem("Save", context, isSaveEnabled),
                  _popupItem("Home", context, true),
                  _popupItem("Logout", context, true),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _popupItem(
      String title, BuildContext context, bool isEnabled) {
    return PopupMenuItem<String>(
      enabled: isEnabled,
      child: TextButton(
        onPressed: isEnabled
            ? () {
                HapticFeedback.vibrate();
                Navigator.of(context).pop();
                if (title == "Save") {
                  onSave?.call();
                } else if (title == "Home") {
                  HapticFeedback.vibrate();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeClass()),
                  );
                } else if (title == "Logout") {
                  HapticFeedback.vibrate();
                  // Implement logout logic
                } else if (title == "Refresh") {
                  HapticFeedback.vibrate();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeClass()),
                  );
                }
              }
            : null,
        child: Text(
          textAlign: TextAlign.right,
          title,
          style: TextStyle(
            fontSize: 14,

            color: isEnabled
                ? const Color.fromARGB(255, 0, 0, 0)
                : const Color.fromARGB(
                    98, 105, 32, 32), // dim color if disabled
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
