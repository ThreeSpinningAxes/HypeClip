import 'package:flutter/material.dart';

class HeaderRow extends StatelessWidget {
const HeaderRow(
  { super.key, required this.header });

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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
        ],
      ),
    );
  }
}
