import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';

class ShowSnackBar  {

   static void showSnackbarError(BuildContext context, String message, int? seconds, {TextStyle? textStyle, bool? miniPlayerVisibility, Widget? body,}) {
    
    final snackBar = SnackBar(
      backgroundColor: Colors.black,
dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      margin: miniPlayerVisibility == true ? EdgeInsets.only(bottom: 70) : EdgeInsets.only(bottom: 0),
      duration: seconds == null ? Duration(seconds: 5) : Duration(seconds: seconds),
      content: SizedBox(
        height: 40,
        child: Row(
          children: <Widget>[
            Icon(Icons.error_outline, color: Colors.red), // Error icon with red color
            SizedBox(width: 8), // Space between icon and text
            Expanded(child: Text(message, style: TextStyle(color: Colors.red))),
          ],
        ),
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

     static void showSnackbar(BuildContext context, {required String message, int? seconds, TextStyle? textStyle, WidgetRef? ref}) {
      bool miniPlayerVisibility = false;
    if (ref != null) {
     miniPlayerVisibility =  ref.read(miniPlayerVisibilityProvider);
    }
    final snackBar = SnackBar(
      
      behavior: SnackBarBehavior.floating,
      margin: miniPlayerVisibility ? EdgeInsets.only(bottom: 70) : EdgeInsets.only(bottom: 0),
    
       // Set margin to adjust height
      backgroundColor: Colors.black,
      dismissDirection: DismissDirection.horizontal,
      duration: seconds == null ? Duration(seconds: 10) : Duration(seconds: seconds),
      content: SizedBox(
        height: 40,
        child: Row(
          children: <Widget>[
            //Icon(Icons.error_outline, color: Colors.white), // Error icon with red color
            SizedBox(width: 8), // Space between icon and text
            Text(message, style: textStyle ?? TextStyle(color: Colors.white)),
          ],
        ),
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
