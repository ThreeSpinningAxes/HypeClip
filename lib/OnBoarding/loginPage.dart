import 'package:flutter/material.dart';
import 'package:hypeclip/Widgets/textField.dart'; // Ensure this custom widget supports `validator`

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Step 2
  final usernameOrEmailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Form(
          // Step 3
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 160),
              const SizedBox(height: 30),
              MyTextField(
                controller: usernameOrEmailController,
                hintText: 'Email or Username',
                obscureText: false,
                suffixIcon: Icon(Icons.email_outlined),
                validator: (value) {
                  // Ensure your MyTextField supports this
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email or username';
                  }

                  return null;
                },
              ),
              SizedBox(height: 30),
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
                suffixIcon: Icon(Icons.password_outlined),
                validator: (value) {
                  // Ensure your MyTextField supports this
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              // Forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35 + 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Color.fromARGB(255, 150, 150, 150),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.solid,
                        decorationThickness: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: ElevatedButton(
                  style: ButtonStyle(
                    alignment: Alignment.center,
                    minimumSize:
                        WidgetStateProperty.all(Size(double.infinity, 57)),
                    backgroundColor: WidgetStateProperty.all(
                        Colors.black),
                    foregroundColor: WidgetStateProperty.all(Color.fromARGB(255, 8, 104, 187)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    )),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Form is valid, proceed with the login
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')),
                      );
                    }
                  },
                  child: Text('Login'),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 35),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 35),
                child: ElevatedButton(
                  onPressed: () => {
                    
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Color.fromRGBO(18, 18, 18, 1)),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    side: WidgetStateProperty.all(BorderSide(color: Colors.white,)),
                    minimumSize:
                        WidgetStateProperty.all(Size(double.infinity, 57)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    )),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset('assets/googleicondark.png'), // Google icon, change as needed
                      ),
                      Text('Continue with Google', style:  TextStyle(fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
