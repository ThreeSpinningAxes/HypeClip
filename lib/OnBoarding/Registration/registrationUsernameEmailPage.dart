import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hypeclip/OnBoarding/Registration/connectMusicLibrariesRegistrationPage.dart';
import 'package:hypeclip/OnBoarding/registration/PasswordSetupPage.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/OnBoarding/widgets/formTextField.dart';
import 'package:hypeclip/OnBoarding/widgets/orFormSplit.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:hypeclip/Utilities/ShowLoading.dart';
import '../LoginPage.dart'; // Import the LoginPage

class RegistrationUsernameEmailPage extends StatefulWidget {
  @override
  _RegistrationUsernameEmailPageState createState() => _RegistrationUsernameEmailPageState();
}

class _RegistrationUsernameEmailPageState extends State<RegistrationUsernameEmailPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

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
      validations['emailValid'] =
          RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$').hasMatch(email);
    });
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
                child: Column(
                  children: [
                    const SizedBox(height: 10), // Reduced from 20 to 10
                    FormTextField(
                      controller: usernameController,
                      hintText: 'Username',
                      obscureText: false,
                      suffixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),
                    _buildUsernameValidationChecklist(),
                    const SizedBox(height: 20),
                    FormTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                      suffixIcon: Icons.email_outlined,
                    ),
                    if (!validations['emailValid']! &&
                        emailController.text.isNotEmpty)
                        
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
      
                        child: Row(
                          children: [
                            Text('Please enter a valid email address',
                            style: TextStyle(color: Colors.red),
                            )
                          ]
                          ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (validations.values.every((v) => v)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PasswordSetupPage(
                                username: usernameController.text,
                                email: emailController.text,
                              ),
                            ),
                          );
                        } else {
                         
                            ShowSnackBar.showSnackbarError(
                              context,
                              'Please fill out all fields correctly',10
                              
                          );
                        }
                      },
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
                          UserCredential? userCred = await Auth().signInWithGoogle(context);
                          if (userCred != null) {
                            if (userCred.additionalUserInfo!.isNewUser) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ConnectMusicLibrariesRegistrationPage()),
                            );
                            }
                            else {
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
                        minimumSize: Size(double.infinity, 55) // Change as needed
                        ),
                  ],
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
