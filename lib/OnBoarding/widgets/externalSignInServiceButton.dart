import "package:flutter/material.dart";

class ExternalSignInServiceButton extends StatefulWidget {
  final String buttonText; //Contents of button, such as text
  final Size? minimumSize; //Minimum size of button
  final Size? maximumSize; //Maximum size of button
  final double? fontSize; //Font size of button text
  final Widget icon; //Icon to be displayed on button
  final void Function()
      onPressed; //Function to be called when button is pressed

  const ExternalSignInServiceButton(
      {super.key,
      required this.buttonText,
      this.minimumSize,
      required this.onPressed, this.maximumSize, required this.icon, this.fontSize});

  @override
  _ExternalSignInServiceButtonState createState() =>
      _ExternalSignInServiceButtonState();
}

class _ExternalSignInServiceButtonState
    extends State<ExternalSignInServiceButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Color.fromRGBO(18, 18, 18, 1)),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        side: WidgetStateProperty.all(BorderSide(
          color: Colors.white,
        )),
        minimumSize: WidgetStateProperty.all(widget.minimumSize),
        maximumSize: WidgetStateProperty.all(widget.maximumSize),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        )),
      ),
      child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: widget.icon, // Google icon, change as needed
                        ),
                        Text(widget.buttonText, style:  TextStyle(fontWeight: FontWeight.bold, fontSize: widget.fontSize),),
                      ],
                    )
    );
  }
}
