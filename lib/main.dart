import 'package:flutter/material.dart';
import 'package:hypeclip/pages/home.dart';
import 'pages/library.dart';

void main() { //main method is where the root of the application runs
  runApp(const MyApp()); //run app takes in a root widget that displays on your device. The root widget is described by a class
}

class MyApp extends StatelessWidget { //Stateless widget == no dynamic data, just fixed elements
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) { //build describes a specific UI and is called everytime a rebuilding of that UI is needed.
    return MaterialApp(
      title: 'HypeClip',
      theme: ThemeData.dark().copyWith(
        primaryColor: Color.fromARGB(255, 8, 104, 187),
      ),
      
      home: const Home(),
    );
  }
}
