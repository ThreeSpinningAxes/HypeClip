import 'package:flutter/material.dart';

class ConnectedAccounts extends StatefulWidget {
  const ConnectedAccounts({super.key});

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
            style: Theme.of(context).textTheme.headlineSmall
          ),
        ),
      ],
    );
  }
}