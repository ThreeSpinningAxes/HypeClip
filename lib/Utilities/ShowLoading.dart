import 'package:flutter/material.dart';

class ShowLoading extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const ShowLoading({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child, // Always show the child widget
        if (isLoading) // Conditionally show the loading overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: Container(
                color: Colors.black, // You can adjust the overlay color
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}