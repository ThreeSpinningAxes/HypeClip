import 'package:flutter/material.dart';

class ConnectedAccounts extends StatefulWidget {
  const ConnectedAccounts({Key? key}) : super(key: key);

  @override
  _ConnectedAccountsState createState() => _ConnectedAccountsState();
}

class _ConnectedAccountsState extends State<ConnectedAccounts> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20 ), 
          child: Text(
            'Connected Music Libraries',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}