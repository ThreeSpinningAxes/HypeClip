import 'package:flutter/material.dart';

class ShowSnackBar  {

   static void showSnackbarError(BuildContext context, String message, int? seconds) {
    
    final snackBar = SnackBar(
      backgroundColor: Colors.black,
      duration: seconds == null ? Duration(seconds: 10) : Duration(seconds: seconds),
      content: Row(
        children: <Widget>[
          Icon(Icons.error_outline, color: Colors.red), // Error icon with red color
          SizedBox(width: 8), // Space between icon and text
          Expanded(child: Text(message, style: TextStyle(color: Colors.red))),
        ],
      ),
      action: SnackBarAction(
        textColor: Colors.red,
        label: 'OK',
        onPressed: () {
          // Code to execute when the action is pressed
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

     static void showSnackbar(BuildContext context, {required String message, int? seconds, TextStyle? textStyle}) {
    
    final snackBar = SnackBar(
      backgroundColor: Colors.black,
      duration: seconds == null ? Duration(seconds: 10) : Duration(seconds: seconds),
      content: Row(
        children: <Widget>[
          //Icon(Icons.error_outline, color: Colors.white), // Error icon with red color
          SizedBox(width: 8), // Space between icon and text
          Expanded(child: Text(message, style: textStyle ?? TextStyle(color: Colors.white))),
        ],
      ),
      action: SnackBarAction(
        textColor: Colors.white,
        label: 'OK',
        onPressed: () {
          // Code to execute when the action is pressed
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
