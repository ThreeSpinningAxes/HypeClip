import 'package:flutter/material.dart';
import 'package:hypeclip/Widgets/textField.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

final usernameOrEmailController = TextEditingController();
final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
            child: Column(
      children: [
        const SizedBox(height: 160),
        //const Icon(Icons.account_circle_outlined, size: 50),
        const SizedBox(height: 30),
        MyTextField(controller: usernameOrEmailController, hintText: 'Email or Username', obscureText: false, suffixIcon: Icon(Icons.email_outlined),),
        SizedBox(height: 30),
        MyTextField(controller: passwordController, hintText: 'Password', obscureText: true, suffixIcon: Icon(Icons.password_outlined),),
        SizedBox(height: 15),
         // forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35 + 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14, decoration: TextDecoration.underline,decorationStyle: TextDecorationStyle.solid, // Specify the style of the underline
    decorationThickness: 1.0),
                    ),
                  ],
                ),
              ),
        SizedBox(height: 30),
        ElevatedButton(
          
          
          onPressed: () {
            // Validate the form
            // If the form is valid, display a snackbar. In the real world,
            // you'd often call a server or save the information in a database.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Processing Data')),
            );
          },
          child: const Text('Login'),
        ),

          
        
      ],
    )
    )
    );
  }
}
