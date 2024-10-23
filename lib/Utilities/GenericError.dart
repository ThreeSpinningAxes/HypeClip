import 'package:flutter/material.dart';

class GenericError extends StatelessWidget {

  final String? title;

  final String? description;

  Widget? child;

  
GenericError({ super.key,  this.title, this.description, this.child});

  @override
  Widget build(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: MediaQuery.of(context).size.width * 0.3,
          color: Colors.red,
        ),
        SizedBox(height: 20),
        Text(title ?? 'An Error Occurred',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            softWrap: true,),
        SizedBox(height: 20),
        Text(
          description ?? 'An error occurred while trying to load the page. Please try again later.',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
          softWrap: true,
          
        ),
        SizedBox(height: 20),
        child ?? Container(),
      ],
    );
  }
}