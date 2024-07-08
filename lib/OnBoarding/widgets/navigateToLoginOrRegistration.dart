import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigateToLoginOrRegistration extends StatelessWidget {
  const NavigateToLoginOrRegistration({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      GestureDetector(
          onTap: () => 
               GoRouter.of(context).go('/auth/register'),
              
          child: Text(
            "Dont have a account? Sign up",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ))
    ]);
  }
}
