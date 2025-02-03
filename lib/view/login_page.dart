import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:omvoting/view/home.dart';

class LoginScreenClass extends StatefulWidget {
  const LoginScreenClass({super.key});

  @override
  State<LoginScreenClass> createState() => _LoginScreenClassState();
}

class _LoginScreenClassState extends State<LoginScreenClass> {
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
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => HomeClass(),
                        ),
                      );
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
              onPressed: () {},
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
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
}
