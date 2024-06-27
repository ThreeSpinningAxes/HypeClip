import "package:flutter/material.dart";

class FormSubmissionButton extends StatelessWidget {
  final Widget buttonContents; //Contents of button, such as text
  final WidgetStateProperty<Size?>? minimumSize; //Minimum size of button
  final WidgetStateProperty<Size?>? maximumSize; //Maximum size of button
  final void Function()? onPressed; //Function to be called when button is pressed

  const FormSubmissionButton({super.key, required this.buttonContents, this.minimumSize, required this.onPressed, this.maximumSize});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        alignment: Alignment.center,
        minimumSize: minimumSize,
        backgroundColor: WidgetStateProperty.all(Colors.black),
        foregroundColor:
            WidgetStateProperty.all(Color.fromARGB(255, 8, 104, 187)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        )),
      ),
      onPressed: onPressed,
      child: buttonContents,
    );
  }
}
