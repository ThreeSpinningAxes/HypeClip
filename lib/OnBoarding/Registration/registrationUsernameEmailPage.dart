import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hypeclip/OnBoarding/Registration/connectMusicLibrariesRegistrationPage.dart';
import 'package:hypeclip/OnBoarding/registration/PasswordSetupPage.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/OnBoarding/widgets/formTextField.dart';
import 'package:hypeclip/OnBoarding/widgets/orFormSplit.dart';
import 'package:hypeclip/Utilities/ShowLoading.dart';
import '../LoginPage.dart';

class RegistrationUsernameEmailPage extends StatefulWidget {
  @override
  _RegistrationUsernameEmailPageState createState() =>
      _RegistrationUsernameEmailPageState();
}

class _RegistrationUsernameEmailPageState
    extends State<RegistrationUsernameEmailPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  String? emailErrorMessage;
  String? usernameErrorMessage;

  Map<String, bool> validations = {
    'usernameLength': false,
    'usernameAlphanumeric': false,
    'emailValid': false,
  };

  var _isLoading = false;

  void _validateUsername() {
    final username = usernameController.text;
    setState(() {
      validations['usernameLength'] = username.length >= 3;
      validations['usernameAlphanumeric'] =
          RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username);
    });
  }

  void _validateEmail() {
    final email = emailController.text;
    setState(() {
      validations['emailValid'] = RegExp(
              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
          .hasMatch(email);
    });
  }

  Future<void> _checkUsernameAndEmail() async {
    setState(() {
      emailErrorMessage = null;
      usernameErrorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Attempt to create a user with a dummy password to check email existence
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: 'dummyPassword123',
        );

        // If user creation succeeds, delete the user immediately
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.delete();
        }

        // Email is available, now check if username is available
        bool isUsernameTaken = await isUsernameInUse(usernameController.text);
        if (isUsernameTaken) {
          setState(() {
            usernameErrorMessage = 'Username is already taken';
            _formKey.currentState!.validate();
            _isLoading = false;
          });
          return;
        }

        // Email and username are available, navigate to the next page
        setState(() {
          _isLoading = false;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordSetupPage(
              username: usernameController.text,
              email: emailController.text,
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          setState(() {
            emailErrorMessage = 'Email is already in use';
            _formKey.currentState!.validate();
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('An error occurred: ${e.message}'),
                duration: Duration(seconds: 3),
              ),
            );
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${e.toString()}'),
              duration: Duration(seconds: 3),
            ),
          );
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill out all fields correctly'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> isUsernameInUse(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_validateUsername);
    emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowLoading(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      FormTextField(
                        controller: usernameController,
                        hintText: 'Username',
                        obscureText: false,
                        suffixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          } else if (value.length < 3) {
                            return 'Username must be at least 3 characters long';
                          } else if (!RegExp(r'^[a-zA-Z0-9]+$')
                              .hasMatch(value)) {
                            return 'Username can only contain letters and numbers';
                          } else if (usernameErrorMessage != null) {
                            return usernameErrorMessage;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildUsernameValidationChecklist(),
                      const SizedBox(height: 20),
                      FormTextField(
                        controller: emailController,
                        hintText: 'Email',
                        obscureText: false,
                        suffixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          } else if (!RegExp(
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          } else if (emailErrorMessage != null) {
                            return emailErrorMessage;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _checkUsernameAndEmail,
                        child: const Text('Next'),
                      ),
                      SizedBox(height: 30),
                      OrFormSplit(),
                      SizedBox(height: 30),
                      ExternalSignInServiceButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          UserCredential? userCred =
                              await Auth().signInWithGoogle(context);
                          if (userCred != null) {
                            if (userCred.additionalUserInfo!.isNewUser) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ConnectMusicLibrariesRegistrationPage()),
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        buttonText: 'Continue with Google',
                        icon: SvgPicture.asset(
                          'assets/android_dark_rd_na.svg',
                          semanticsLabel: 'My SVG Image',
                        ),
                        minimumSize:
                            Size(double.infinity, 55), // Change as needed
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameValidationChecklist() {
    return Column(
      children: [
        Row(
          children: [
            Icon(validations['usernameLength']! ? Icons.check : Icons.close,
                color:
                    validations['usernameLength']! ? Colors.green : Colors.red),
            SizedBox(width: 8),
            Text('At least 3 characters',
                style: TextStyle(
                    color: validations['usernameLength']!
                        ? Colors.green
                        : Colors.red)),
          ],
        ),
        Row(
          children: [
            Icon(
                validations['usernameAlphanumeric']!
                    ? Icons.check
                    : Icons.close,
                color: validations['usernameAlphanumeric']!
                    ? Colors.green
                    : Colors.red),
            SizedBox(width: 8),
            Text('Only letters and numbers',
                style: TextStyle(
                    color: validations['usernameAlphanumeric']!
                        ? Colors.green
                        : Colors.red)),
          ],
        ),
      ],
    );
  }
}
