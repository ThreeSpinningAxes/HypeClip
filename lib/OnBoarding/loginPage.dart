import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/OnBoarding/widgets/forgotPasswordLink.dart';
import 'package:hypeclip/OnBoarding/widgets/formSubmissionButton.dart';
import 'package:hypeclip/OnBoarding/widgets/formTextField.dart';
import 'package:hypeclip/OnBoarding/widgets/navigateToLoginOrRegistration.dart';
import 'package:hypeclip/OnBoarding/widgets/orFormSplit.dart'; // Ensure this custom widget supports `validator`
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hypeclip/Services/UserService.dart';
import 'package:hypeclip/Utilities/ShowLoading.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;

  final GoogleSignIn googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return ShowLoading(
      isLoading: _isLoading,
      child: Scaffold(
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
                    const SizedBox(height: 100),
                    Center(
                        child: Text("Log in to HypeClip",
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 8, 104, 187)))),
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
                        buttonContents: Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            signInWithEmailAndPassword();
                          }
                        },
                        minimumSize: Size(double.infinity, 55)),

                    SizedBox(height: 30),

                    OrFormSplit(),

                    SizedBox(height: 30),

                    ExternalSignInServiceButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          UserCredential? userCredential = await Auth().signInWithGoogle(context);
                          if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          if (userCredential != null) {
                              if (userCredential.additionalUserInfo!.isNewUser) {
                                GoRouter.of(context).goNamed('register/connectMusicServices');
                              }
                              else {
                                GoRouter.of(context).go('/auth');
                              }
                            }

                        },
                        buttonText: 'Continue with Google',
                        icon: SvgPicture.asset(
                          'assets/android_dark_rd_na.svg',
                          semanticsLabel: 'My SVG Image',
                        ),
                        minimumSize:
                            Size(double.infinity, 55) // Change as needed
                        ),
                    SizedBox(height: 20),
                    NavigateToLoginOrRegistration(),
                  ],
                ),
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
      Userservice.setUser(
          FirebaseAuth.instance.currentUser!.uid,
          FirebaseAuth.instance.currentUser!.displayName ?? '',
          FirebaseAuth.instance.currentUser!.email ?? '',
          true);
      await Userservice.fetchAndStoreConnectedMusicLibrariesFromFireStore();
      
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
    } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message??'An error occurred. Please try again.')),
      );
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }
}
