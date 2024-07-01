import 'package:flutter/material.dart';

class Alerts {
showLoaderDialog(BuildContext context){
    AlertDialog alert=AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(color: Colors.white,),
          Container(margin: EdgeInsets.only(left: 7)),
        ],),
    );
    showDialog(barrierDismissible: false,
      context:context,
      builder:(BuildContext context){
        return alert;
      },
    );
  }
}
