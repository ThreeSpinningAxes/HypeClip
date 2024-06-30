import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hypeclip/OnBoarding/Registration/connectMusicLibrariesRegistrationPage.dart';
import 'package:hypeclip/OnBoarding/handleUserSignIn.dart';
import 'package:hypeclip/OnBoarding/widgets/PasswordStrengthValidation.dart';
import 'package:hypeclip/OnBoarding/widgets/formTextField.dart';
import 'package:hypeclip/OnBoarding/widgets/formSubmissionButton.dart';
import 'package:hypeclip/Services/UserService.dart';

class PasswordSetupPage extends StatefulWidget {
  final String username;
  final String email;

  PasswordSetupPage({required this.username, required this.email, super.key});

  @override
  _PasswordSetupPageState createState() => _PasswordSetupPageState();
}

class _PasswordSetupPageState extends State<PasswordSetupPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<void> _register(BuildContext context) async {
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(widget.username);

      await UserProfileService().addUserData(userCredential.user!, {
        'username': widget.username,
      });
      Userservice().setUser(FirebaseAuth.instance.currentUser!.uid,
          FirebaseAuth.instance.currentUser!.displayName ?? '',
          FirebaseAuth.instance.currentUser!.email ?? '',
          true);

      //Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConnectMusicLibrariesRegistrationPage()
            ),
        );
    
    } on FirebaseAuthException catch (e) {
      String message;

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = '${e.code}Registration failed. Please try again.';
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
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  FormTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    isPassword: true,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: PasswordStrengthValidation(
                        passwordController: passwordController),
                  ),
                  const SizedBox(height: 20),
                  FormTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  FormSubmissionButton(
                    buttonContents: Text('Register'),
                    onPressed: () async {
                      await _register(context);
                    },
                    minimumSize: Size(double.infinity, 55),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
