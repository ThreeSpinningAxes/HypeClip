import 'package:flutter/material.dart';
import 'package:hypeclip/Widgets/HeaderRow.dart';
class Library extends StatelessWidget {
  
const Library({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return SafeArea(
       child: Center(
         child: ListView(
           children: [
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 HeaderRow(header: 'Library'),
               ],)
           ],
         ),
       ),
     );
  
  }

}