import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';

class GenericErrorPage extends StatelessWidget {
  const GenericErrorPage({
    super.key,
    this.errorHeader,
    this.errorDescription,
    this.buttonText,
    this.buttonAction,
    this.padding
  });

  final VoidCallback? buttonAction;
  final String? buttonText;
  final String? errorDescription;
  final String? errorHeader;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: Stack(
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
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
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
                        softWrap: true,
                      ),
                    if (errorDescription != null) const SizedBox(height: 20),
                    if (buttonText != null && buttonAction != null)
                      ElevatedButton(
                        onPressed: buttonAction,
                        style: ButtonStyle(
                          alignment: Alignment.center,
                          
                          backgroundColor: WidgetStateProperty.all(
                              Color.fromARGB(255, 8, 104, 187)),
                          foregroundColor: WidgetStateProperty.all(Colors.black),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          )),
                        ),
                        child: Text(buttonText!, softWrap: true, style: TextStyle(color: Colors.white),),
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


}
