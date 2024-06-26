import 'package:flutter/material.dart';
import 'package:hypeclip/Widgets/ConnectedAccounts.dart';
import 'package:hypeclip/Widgets/HeaderRow.dart';

class Explore extends StatelessWidget {

const Explore({ super.key });

  @override
  Widget build(BuildContext context){
   return SafeArea(
       child: Center(
         child: ListView(
           children: [
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 HeaderRow(header: 'Explore'), 
               ],),
               ConnectedAccounts()
           ],
         ),
       ),
     );
}}