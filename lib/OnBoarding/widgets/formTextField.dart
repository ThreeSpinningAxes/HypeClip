import 'package:flutter/material.dart';
class FormTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final bool isPassword;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  const FormTextField({
    super.key,
    this.suffixIcon,
    this.isPassword = false,
    required this.controller,
    required this.hintText,

    this.obscureText = false, 
    this.validator, // Default to true, can be overridden
  });

  @override
  _FormTextFieldState createState() => _FormTextFieldState();
}




class _FormTextFieldState extends State<FormTextField> {
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
    return TextFormField(
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
          hintText: widget.hintText,
          suffixIcon: widget.isPassword ? IconButton(
            icon: Icon(
              // Toggle the icon based on _isObscured
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: Color.fromARGB(255, 200, 200, 200),
            ),
            onPressed: _togglePasswordVisibility,
          ) : widget.suffixIcon,
          hintStyle: TextStyle(color: Color.fromARGB(255, 150, 150, 150), fontSize: 14),
        ),
        
        validator: widget.validator,
        controller: widget.controller,
        obscureText: widget.isPassword || widget.obscureText ? _isObscured : false,
        
      );
  }
}