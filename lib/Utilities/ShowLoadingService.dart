import 'package:flutter/material.dart';

class ShowLoadingService {
  static OverlayEntry? _currentOverlayEntry;

  static void showOverlay(BuildContext context, String? message) {
    if (_currentOverlayEntry != null) return; // Prevent duplicate overlays

    _currentOverlayEntry = createLoadingOverlay(context, message);
    Overlay.of(context).insert(_currentOverlayEntry!);
  }

  static void hideOverlay() {
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }
  
  static OverlayEntry createLoadingOverlay(BuildContext context, String? message) {
  return OverlayEntry(
    builder: (context) => Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 200, // Width of the box
            height: 200, // Height of the box
            padding: EdgeInsets.all(20), // Padding inside the box
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Semi-transparent black background
              borderRadius: BorderRadius.circular(10), // Rounded corners
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, // To wrap the content in the column
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
    ),
  );
}
}