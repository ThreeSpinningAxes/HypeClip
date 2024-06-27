import "package:flutter/material.dart";

class OrFormSplit extends StatelessWidget {
  final String splitText;
  const OrFormSplit({super.key, this.splitText = 'or'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Divider(
            color: Colors.white,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(splitText,
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        Expanded(
          child: Divider(
            color: Colors.white,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
