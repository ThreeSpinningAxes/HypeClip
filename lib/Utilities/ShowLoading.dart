import 'package:flutter/material.dart';

class ShowLoading extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  static OverlayEntry? _currentOverlayEntry;

  const ShowLoading({super.key, required this.isLoading, required this.child, this.message});

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // To minimize the space that the column occupies
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                        value: null,
                      ),
                      if (message != null) // Only show the message if it is not null
                        Padding(
                          padding: const EdgeInsets.only(top: 8), // Add some space between the indicator and the message
                          child: Text(
                            message!,
                            style: TextStyle(color: Colors.white, fontSize: 16), // Adjust text style as needed
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  OverlayEntry createLoadingOverlay(BuildContext context, String? message) {
  return OverlayEntry(
    builder: (context) => Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.white),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
}