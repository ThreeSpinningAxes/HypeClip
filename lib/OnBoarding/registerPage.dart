import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hypeclip/OnBoarding/widgets/formTextField.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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

      // Registration successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );

      // This is how we will navigate to another screen
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
    } on FirebaseAuthException catch (e) {
      String message;

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = 'Registration failed. Please try again.';
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
    return SafeArea(
        child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 160),
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
                        suffixIcon: Icons.lock_outline,
                      ),
                      const SizedBox(height: 30),
                      FormTextField(
                        controller: confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true,
                        suffixIcon: Icons.lock_outline,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
              await _register(context);
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  )),
            )));
  }
}
