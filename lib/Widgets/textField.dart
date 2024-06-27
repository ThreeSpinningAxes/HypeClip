import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
// Added prefixIcon parameter

  const MyTextField({
    Key? key,
    this.suffixIcon,
    required this.controller,
    required this.hintText,
    this.obscureText = true, 
    this.validator, // Default to true, can be overridden
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: TextFormField(
        
        validator: widget.validator,
        controller: widget.controller,
        obscureText: widget.obscureText ? _isObscured : false,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(0, 69, 69, 69), width: 2),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          fillColor: Color.fromRGBO(0, 0, 0, 100),
          filled: true,
          hintText: widget.hintText,// Use the prefixIcon if provided
          suffixIcon: widget.obscureText ? IconButton(
            icon: Icon(
              // Toggle the icon based on _isObscured
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: Color.fromARGB(255, 200, 200, 200),
            ),
            onPressed: _togglePasswordVisibility,
          ) : widget.suffixIcon,
          hintStyle: TextStyle(color: Color.fromARGB(255, 150, 150, 150), fontSize: 14),
        ),
      ),
    );
  }
}