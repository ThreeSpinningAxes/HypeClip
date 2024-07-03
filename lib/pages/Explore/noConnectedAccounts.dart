import 'package:flutter/material.dart';
import 'package:hypeclip/OnBoarding/widgets/formSubmissionButton.dart';
import 'package:hypeclip/Pages/ConnectMusicServicesPage.dart';

class NoConnectedAccounts extends StatelessWidget {
  final Function? onConnectedCallback;
  const NoConnectedAccounts({super.key, this.onConnectedCallback});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline, // Use the error_outline icon or any other appropriate icon
              size: 60, // Adjust the size as needed
              color: Colors.red, // Optional: Adjust the color as needed
            ),
            SizedBox(height: 20),
            Text(
              'No Connected Music Libraries',
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center
            ),
            SizedBox(height: 20),
            Text(
              'You must connect at least one music service account to create clips.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            FormSubmissionButton(
              buttonContents: 
              Text("Connect your Music Libraries", 
                style: TextStyle(color: Colors.white, ),), 
                onPressed: () => {
                  Navigator.push(context, MaterialPageRoute
                  (builder: (context) => ConnectMusicServicesPage(onConnectedCallback: onConnectedCallback,)))
      
            })
          ],
        ),
      ),
    );
  }
}