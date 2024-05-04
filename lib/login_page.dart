import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:omvoting/component/candidates.dart';
import 'package:omvoting/component/textfiled.dart';
import 'package:omvoting/firebase_auth/authServices.dart';
import 'package:omvoting/index.dart';
import 'package:omvoting/index_app2.dart';

import 'package:omvoting/firebase_auth/register_page.dart';

class LoginScreenClass extends StatefulWidget {
  const LoginScreenClass({super.key});

  @override
  State<LoginScreenClass> createState() => _LoginScreenClassState();
}

class _LoginScreenClassState extends State<LoginScreenClass> {
  final firebaseAuthServices _authe = firebaseAuthServices();
  String _user_name = 'w';
  String _password = "w";
  String msgAlert = '';

  final _user_controller = TextEditingController();
  final _pass_controller = TextEditingController();

  GlobalKey<FormState> user_key = GlobalKey<FormState>();
  GlobalKey<FormState> pass_key = GlobalKey<FormState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _user_controller.dispose();
    _pass_controller.dispose();
    super.dispose();
  }

  // ignore: unused_field
  late Timer _timer;

  void _showMessage(String message) {
    setState(() {
      msgAlert = message;
    });

    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        msgAlert = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 240,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/loginBar.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 45),
            child: Center(
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: 35,
                  fontFamily: 'georgia',
                  color: Color.fromARGB(255, 37, 36, 36),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  myTextFiled(
                    myHit: 'Username or Email',
                    MyPrefIcon: const Icon(Icons.person),
                    myController: _user_controller,
                    myObscureText: false,
                    myValidator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username or email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  myTextFiled(
                    myController: _pass_controller,
                    myObscureText: true,
                    myHit: 'Password',
                    MyPrefIcon: const Icon(Icons.lock),
                    myValidator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // if (_formKey.currentState!.validate()) {
                      //sign_In();

                      // String username = _user_controller.text;
                      // String password = _pass_controller.text;
                      // if (username == 'w' && password == 'w') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const MyWidgetIndex(),
                        ),
                      );
                      // } else {
                      //   setState(() {
                      //     _showMessage('Incorrect username or password');
                      //   });
                      // }
                      // }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'georgia',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              child: Text(
                msgAlert,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'georgia',
                  color: Color.fromARGB(255, 228, 27, 27),
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 45),
            child: Center(
              child: Text(
                "Do not have an account? Sign up here",
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'georgia',
                  color: Color.fromARGB(255, 37, 36, 36),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
            child: ElevatedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 230, 45, 45),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const MyWidgetReg(),
                  ),
                );
              },
              child: const Text(
                'Register',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'georgia',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const MyWidgetIndex_app2(),
                ),
              );
            },
            child: const Text(
              "Admin Page",
              style: TextStyle(
                fontFamily: 'georgia',
                color: Color.fromARGB(255, 64, 8, 128),
                fontWeight: FontWeight.w200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  void sign_In() async {
    String email = _user_controller.text;
    String pass = _pass_controller.text;

    try {
      final user = await _authe.sighIn(email, pass);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const MyWidgetIndex(),
          ),
        );
      } else {
        _showMessage('Incorrect username or password');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to login user:\n $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
