import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';
import 'package:hypeclip/OnBoarding/widgets/PasswordStrengthValidation.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/OnBoarding/widgets/formTextField.dart';
import 'package:hypeclip/OnBoarding/widgets/navigateToLoginOrRegistration.dart';
import 'package:hypeclip/OnBoarding/widgets/orFormSplit.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  //Regex to tet if password strength is met.

  //validation for password

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _register(BuildContext context) async {
    final String username = usernameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      // Show error message if passwords do not match
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      

      // Update the user profile with the username
      await userCredential.user?.updateDisplayName(username);
      Navigator.of(context).popUntil((route) => route.isFirst);
      

      // Registration successful
      

      

      // This is how we will navigate to another screen
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    } on FirebaseAuthException catch (e) {
      String message;

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = e.code + 'Registration failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Center(
            child: Column(
          children: [
            const SizedBox(height: 30),
            FormTextField(
              controller: usernameController,
              hintText: 'Username',
              obscureText: false,
              suffixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 30),
            FormTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
              suffixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 30),
            FormTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
              isPassword: true,
            ),
            SizedBox(height: 20),
            PasswordStrengthValidation(passwordController: passwordController),
            const SizedBox(height: 20),
            FormTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm Password',
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await _register(context);
              },
              child: const Text('Register'),
            ),
            SizedBox(height: 30),
            OrFormSplit(),
            SizedBox(height: 30),
            ExternalSignInServiceButton(
                onPressed: () => {},
                buttonText: 'Continue with Google',
                icon: SvgPicture.asset(
                  'assets/android_dark_rd_na.svg',
                  semanticsLabel: 'My SVG Image',
                ),
                minimumSize: Size(double.infinity, 55) // Change as needed
                ),
            SizedBox(height: 20),
            NavigateToLoginOrRegistration(currentPageIsLogin: false),
          ],
        )),
      ))),
    );
  }
}
