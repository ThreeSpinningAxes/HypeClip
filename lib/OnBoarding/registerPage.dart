import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/OnBoarding/widgets/formTextField.dart';
import 'package:hypeclip/OnBoarding/widgets/orFormSplit.dart';
import 'LoginPage.dart'; // Import the LoginPage
import 'PasswordSetupPage.dart'; // Import the PasswordSetupPage

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Map<String, bool> validations = {
    'usernameLength': false,
    'usernameAlphanumeric': false,
    'emailValid': false,
  };

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
          RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
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
    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  if (validations['emailValid']! &&
                      emailController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please enter a valid email address',
                        style: TextStyle(color: Colors.red),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please fill out all fields correctly.')),
                        );
                      }
                    },
                    child: const Text('Next'),
                  ),
                  SizedBox(height: 30),

                  OrFormSplit(),

                  SizedBox(height: 30),

                  ExternalSignInServiceButton(
                      onPressed: () {/*googleSignIn.signIn();*/},
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
