import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hypeclip/OnBoarding/loginPage.dart';
import 'package:hypeclip/OnBoarding/widgets/widgetTree.dart';
import 'package:hypeclip/firebase_options.dart';
import 'package:hypeclip/pages/home.dart';
import 'package:page_transition/page_transition.dart';

Future main() async {
  //main method is where the root of the application runs
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  //run app takes in a root widget that displays on your device. The root widget is described by a class
}

class MyApp extends StatelessWidget {
  //Stateless widget == no dynamic data, just fixed elements
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //build describes a specific UI and is called everytime a rebuilding of that UI is needed.
    return MaterialApp(
        title: 'HypeClip',
        theme: ThemeData.dark().copyWith(
          primaryColor: Color.fromARGB(255, 8, 104, 187),
        ),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
          splash: Icon(Icons.music_note_rounded),
          nextScreen: WidgetTree(),
          centered: true,
          duration: 2000,
          pageTransitionType: PageTransitionType.fade,
          backgroundColor: Colors.black,
        ));
  }
}
