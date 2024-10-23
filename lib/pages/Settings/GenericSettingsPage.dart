import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GenericSettingsPage extends StatelessWidget {

final String title;
final Widget child;

const GenericSettingsPage({
  super.key,
  required this.title,
  required this.child,
});
  @override
  Widget build(BuildContext context){
   
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white, fontSize: 24),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.mounted) {
              context.pop();
            }
            
          },
        ),

      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: child,
      ),
    );
  }
}