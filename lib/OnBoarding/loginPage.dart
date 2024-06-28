import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/OnBoarding/widgets/forgotPasswordLink.dart';
import 'package:hypeclip/OnBoarding/widgets/formSubmissionButton.dart';
import 'package:hypeclip/OnBoarding/widgets/formTextField.dart';
import 'package:hypeclip/OnBoarding/widgets/navigateToLoginOrRegistration.dart';
import 'package:hypeclip/OnBoarding/widgets/orFormSplit.dart'; // Ensure this custom widget supports `validator`
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            // Step 3
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 160),
                  const SizedBox(height: 30),
                  FormTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    suffixIcon: Icons.email_outlined,
                    validator: (value) {
                      // Ensure your MyTextField supports this
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  FormTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    isPassword: true,
                    suffixIcon: Icons.password_outlined,
                    validator: (value) {
                      // Ensure your MyTextField supports this
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  // Forgot password?
                  ForgotPasswordLink(
                      passwordResetPage:
                          Container()), //replace with password reset page widget
                  SizedBox(height: 30),
                  FormSubmissionButton(
                      buttonContents: Text('Login'),
                      onPressed: signInWithEmailAndPassword,
                      minimumSize: Size(double.infinity, 55)),

                  SizedBox(height: 30),

                  OrFormSplit(),

                  SizedBox(height: 30),

                  ExternalSignInServiceButton(
                      onPressed: ()  {/*googleSignIn.signIn();*/},
                      buttonText: 'Continue with Google',
                      icon: SvgPicture.asset(
                        'assets/android_dark_rd_na.svg',
                        semanticsLabel: 'My SVG Image',
                      ),
                      minimumSize: Size(double.infinity, 55) // Change as needed
                      ),
                  SizedBox(height: 20),
                  NavigateToLoginOrRegistration(currentPageIsLogin: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      String message;

      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else {
        message = e.code;
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

  Future<void> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;
    
    // Use the user object for further operations or navigate to a new screen.
  } catch (e) {
    print(e.toString());
  }
}


}
