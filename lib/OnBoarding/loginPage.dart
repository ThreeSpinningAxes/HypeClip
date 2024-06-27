import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/OnBoarding/widgets/forgotPasswordLink.dart';
import 'package:hypeclip/OnBoarding/widgets/formSubmissionButton.dart';
import 'package:hypeclip/OnBoarding/widgets/formTextField.dart';
import 'package:hypeclip/OnBoarding/widgets/orFormSplit.dart'; // Ensure this custom widget supports `validator`

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final usernameOrEmailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
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
                    controller: usernameOrEmailController,
                    hintText: 'Email or Username',
                    obscureText: false,
                    suffixIcon: Icons.email_outlined,
                    validator: (value) {
                      // Ensure your MyTextField supports this
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email or username';
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
                      onPressed: _loginSubmission,
                      minimumSize: Size(double.infinity, 55)),

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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _loginSubmission() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with the login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing Data')),
      );
    }
  }
}
