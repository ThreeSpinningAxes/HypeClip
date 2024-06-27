import "package:flutter/material.dart";

class ForgotPasswordLink extends StatelessWidget {
  final Widget passwordResetPage;
  const ForgotPasswordLink({super.key, required this.passwordResetPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            // Navigate to the password reset page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => passwordResetPage), // Replace PasswordResetPage with your actual password reset page widget
            );
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: Color.fromARGB(255, 150, 150, 150),
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
              decorationThickness: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}