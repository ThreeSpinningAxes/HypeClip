import 'package:flutter/material.dart';

class PasswordStrengthValidation extends StatefulWidget {
  final TextEditingController passwordController;
  const PasswordStrengthValidation({super.key, required this.passwordController});

  @override
  _PasswordStrengthValidationState createState() => _PasswordStrengthValidationState();
}

class _PasswordStrengthValidationState extends State<PasswordStrengthValidation> {
  
  bool passwordStrong = false;

  @override
  void initState() {
    super.initState();
    // Add listener to the password controller
    widget.passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final password = widget.passwordController.text;
    setState(() {
      validations['length'] = password.length >= 8 && password.length <= 20;
      validations['upperCase'] = password.contains(RegExp(r'[A-Z]'));
      validations['specialChar'] = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      validations['number'] = password.contains(RegExp(r'[0-9]'));

      // Set passwordStrong based on all conditions being true
      passwordStrong = validations.values.every((v) => v);
    });
  }

  Map<String, bool> validations = {
    'length': false,
    'upperCase': false,
    'specialChar': false,
    'number': false,
  };

  @override
  void dispose() {
  //   // Remove the listener when the widget is disposed
  widget.passwordController.removeListener(_checkPasswordStrength);
  widget.passwordController.dispose();
  super.dispose();
}

  

  

  @override
  Widget build(BuildContext context) {
    return Column(children: 
    [
     Row(
          children: [
            Icon(validations['length']! ? Icons.check : Icons.close, color: validations['length']! ? Colors.green : Colors.red),
            SizedBox(width: 8), // Add some spacing between the icon and the text
            Text('minimum 8 characters (max 20)', style: TextStyle(color: validations['length']! ? Colors.green : Colors.red)),
          ],
        ),
        Row(
          children: [
            Icon(validations['upperCase']! ? Icons.check : Icons.close, color: validations['upperCase']! ? Colors.green : Colors.red),
            SizedBox(width: 8), // Add some spacing
            Text('1 uppercase letter', style: TextStyle(color: validations['upperCase']! ? Colors.green : Colors.red)),
          ],
        ),
        Row(
          children: [
            Icon(validations['specialChar']! ? Icons.check : Icons.close, color: validations['specialChar']! ? Colors.green : Colors.red),
            SizedBox(width: 8), // Add some spacing
            Text('1 special character', style: TextStyle(color: validations['specialChar']! ? Colors.green : Colors.red)),
          ],
        ),
        Row(
          children: [
            Icon(validations['number']! ? Icons.check : Icons.close, color: validations['number']! ? Colors.green : Colors.red),
            SizedBox(width: 8), // Add some spacing
            Text('1 number', style: TextStyle(color: validations['number']! ? Colors.green : Colors.red)),
          ],
        ),
    ],);
  }
}