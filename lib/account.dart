import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:omvoting/login_page.dart';

class MyWidgetAcc extends StatefulWidget {
  const MyWidgetAcc({super.key});

  @override
  State<MyWidgetAcc> createState() => _MyWidgetAccState();
}

class _MyWidgetAccState extends State<MyWidgetAcc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: ExactAssetImage('assets/images/bg_fliped.png'),
                fit: BoxFit.fill),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 60, right: 60, top: 60),
                child: const Text(
                  'Account',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontFamily: 'georgia',
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 45),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 75),
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
                    Padding(
                      padding: const EdgeInsets.only(right: 50, top: 50),
                      child: IconButton(
                        iconSize: 40,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Color.fromARGB(255, 240, 66, 66)),
                        ),
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const LoginScreenClass(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(right: 55, left: 65),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Text(
                        'Edit Picture',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'georgia',
                          color: Color.fromARGB(255, 5, 3, 116),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 15),
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'georgia',
                            color: Color.fromARGB(255, 5, 3, 116),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 15, bottom: 20),
                margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(
                        255, 201, 197, 197), // Border color
                    width: 0.5,
                    // Border width
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.man_3_outlined),
                          labelText: 'username',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.lock_person_sharp),
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.confirmation_number_outlined),
                          labelText: 'Conifirm Password',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 240, 66, 66),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Submit'),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
