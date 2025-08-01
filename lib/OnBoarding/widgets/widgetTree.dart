import 'package:flutter/material.dart';
import 'package:hypeclip/OnBoarding/loginPage.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';


class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          //GoRouter.of(context).go('/home');
          return Container();
        } else {
          //GoRouter.of(context).go('/login');
          return LoginPage();
          
        }
      },
    );
  }
}
