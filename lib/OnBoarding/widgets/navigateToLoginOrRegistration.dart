import 'package:flutter/material.dart';
import 'package:hypeclip/OnBoarding/loginPage.dart';
import 'package:hypeclip/OnBoarding/registerPage.dart';

class NavigateToLoginOrRegistration extends StatelessWidget {
  final bool currentPageIsLogin;
  const NavigateToLoginOrRegistration(
      {Key? key, required this.currentPageIsLogin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
          onTap: () => {
                if (currentPageIsLogin)
                  {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return RegisterPage();
                    }))
                  }
                else
                  {
                    Navigator.pop(context,
                        MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }))
                  }
              },
          child: Text(
            currentPageIsLogin
                ? "Dont have a account? Sign up"
                : "Already have a account? Login",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ))
    ]);
  }
}
