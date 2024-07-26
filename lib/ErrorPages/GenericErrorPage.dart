import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class GenericErrorPage extends StatelessWidget {
  final String? errorHeader;
  final String? errorDescription;
  final String? buttonText;
  final VoidCallback? buttonAction;

  const GenericErrorPage({
    super.key,
    this.errorHeader,
    this.errorDescription,
    this.buttonText,
    this.buttonAction,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (context.canPop())
          Align(
            alignment: Alignment.topLeft,
            heightFactor: 1,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                context.pop();
              },
            ),
          ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons
                    .error_outline, // Use the error_outline icon or any other appropriate icon
                size: MediaQuery.of(context).size.width *
                    0.3, // Adjust the size as needed
                color: Colors.red, // Optional: Adjust the color as needed
              ),
              const SizedBox(height: 20),
              if (errorHeader != null)
                Text(
                  errorHeader!,
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              if (errorHeader != null) const SizedBox(height: 20),
              if (errorDescription != null)
                Text(
                  errorDescription!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              if (errorDescription != null) const SizedBox(height: 20),
              if (buttonText != null && buttonAction != null)
                ElevatedButton(
                  onPressed: buttonAction,
                  child: Text(buttonText!),
                ),
            ],
          ),
        )
      ],
    );
  }
}
