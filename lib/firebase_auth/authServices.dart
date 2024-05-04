import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ignore: camel_case_types
class firebaseAuthServices {
  final _auth = FirebaseAuth.instance;
  Future<User?> signUp(String email, String password) async {
    try {
      final cr = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cr.user;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'sign_up_error',
        message: 'Failed to sign up. Please try again later.',
      );
    }
  }

  Future<User?> sighIn(String email, String password) async {
    try {
      final cr = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cr.user;
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red.withOpacity(0.7),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    return null;
  }
}
