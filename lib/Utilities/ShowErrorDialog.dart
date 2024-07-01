import 'package:flutter/material.dart';

class ShowErrorDialog  {

   static void showSnackbar(BuildContext context, String message) {
    
    final snackBar = SnackBar(
      backgroundColor: Colors.black,
      duration: Duration(seconds: 10),
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
}
