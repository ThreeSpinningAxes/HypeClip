import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/OnBoarding/widgets/formSubmissionButton.dart';

class NoConnectedAccounts extends StatelessWidget {
  const NoConnectedAccounts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons
              .error_outline, // Use the error_outline icon or any other appropriate icon
            size: MediaQuery.of(context).size.width * 0.3, // Adjust the size as needed
          color: Colors.red,
           // Optional: Adjust the color as needed
        ),
        SizedBox(height: 20),
        Text('No Connected Music Libraries',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
            softWrap: true,),
        SizedBox(height: 20),
        Text(
          'You must connect at least one music service account to create clips.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        FormSubmissionButton(
            buttonContents: Text(
              "Connect your Music Libraries",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () =>
                {context.goNamed('explore/connectMusicServicesPage')})
      ],
    );
  }
}
