import 'package:flutter/material.dart';
import 'package:omvoting/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      const MaterialApp(
        home: Splash(),
        debugShowCheckedModeBanner: false,
        title: "Voting App",
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e\n$stackTrace');
  }
}
