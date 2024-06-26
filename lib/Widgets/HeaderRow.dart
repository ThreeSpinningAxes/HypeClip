import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HeaderRow extends StatelessWidget {
const HeaderRow(
  { Key? key, required this.header }) : super(key: key);

  final String header;

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20   
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            header,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
        ],
      ),
    );
  }
}
