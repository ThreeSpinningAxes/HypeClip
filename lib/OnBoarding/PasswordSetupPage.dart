import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hypeclip/OnBoarding/handleUserSignIn.dart';
import 'package:hypeclip/OnBoarding/widgets/PasswordStrengthValidation.dart';
import 'package:hypeclip/OnBoarding/widgets/formTextField.dart';
import 'package:hypeclip/OnBoarding/widgets/formSubmissionButton.dart';

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

  Map<String, bool> validations = {
    'length': false,
    'upperCase': false,
    'lowerCase': false,
    'number': false,
    'specialChar': false,
  };

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final password = passwordController.text;
    setState(() {
      validations['length'] = password.length >= 8 && password.length <= 20;
      validations['upperCase'] = password.contains(RegExp(r'[A-Z]'));
      validations['lowerCase'] = password.contains(RegExp(r'[a-z]'));
      validations['number'] = password.contains(RegExp(r'[0-9]'));
      validations['specialChar'] =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  Future<void> _register(BuildContext context) async {
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!validations.values.every((v) => v)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password does not meet all criteria')),
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

      await HandleUserSignIn().addUserData(userCredential.user!, {});

      Navigator.of(context).popUntil((route) => route.isFirst);
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  _buildPasswordValidationChecklist(),
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

  Widget _buildPasswordValidationChecklist() {
    return Column(
      children: [
        Row(
          children: [
            Icon(validations['length']! ? Icons.check : Icons.close,
                color: validations['length']! ? Colors.green : Colors.red),
            SizedBox(width: 8),
            Text('Minimum 8 characters (max 20)',
                style: TextStyle(
                    color: validations['length']! ? Colors.green : Colors.red)),
          ],
        ),
        Row(
          children: [
            Icon(validations['upperCase']! ? Icons.check : Icons.close,
                color: validations['upperCase']! ? Colors.green : Colors.red),
            SizedBox(width: 8),
            Text('1 uppercase letter',
                style: TextStyle(
                    color:
                        validations['upperCase']! ? Colors.green : Colors.red)),
          ],
        ),
        Row(
          children: [
            Icon(validations['lowerCase']! ? Icons.check : Icons.close,
                color: validations['lowerCase']! ? Colors.green : Colors.red),
            SizedBox(width: 8),
            Text('1 lowercase letter',
                style: TextStyle(
                    color:
                        validations['lowerCase']! ? Colors.green : Colors.red)),
          ],
        ),
        Row(
          children: [
            Icon(validations['number']! ? Icons.check : Icons.close,
                color: validations['number']! ? Colors.green : Colors.red),
            SizedBox(width: 8),
            Text('1 number',
                style: TextStyle(
                    color: validations['number']! ? Colors.green : Colors.red)),
          ],
        ),
        Row(
          children: [
            Icon(validations['specialChar']! ? Icons.check : Icons.close,
                color: validations['specialChar']! ? Colors.green : Colors.red),
            SizedBox(width: 8),
            Text('1 special character',
                style: TextStyle(
                    color: validations['specialChar']!
                        ? Colors.green
                        : Colors.red)),
          ],
        ),
      ],
    );
  }
}
