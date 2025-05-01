import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:omvoting/view/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      const MaterialApp(
        home: HomeClass(),
        debugShowCheckedModeBanner: false,
        title: "Fundus Classify",
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e\n$stackTrace');
  }
}
