import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final Icon? suffixIcon; // Define the prefixIcon parameter


  const MyTextField({
    Key? key,
    this.suffixIcon, // Add the prefixIcon parameter to the constructor
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
              borderRadius: BorderRadius.all(Radius.circular(16))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
                borderRadius: BorderRadius.all(Radius.circular(16))),
            fillColor: Color.fromRGBO(0,0,0,100),
            filled: true,
            hintText: hintText,
            suffixIcon: suffixIcon,
            
            
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
    ));
  }
}