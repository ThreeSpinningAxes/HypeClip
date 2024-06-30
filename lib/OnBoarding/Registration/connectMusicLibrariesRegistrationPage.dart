import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/Services/UserService.dart';

class ConnectMusicLibrariesRegistrationPage extends StatefulWidget {
  const ConnectMusicLibrariesRegistrationPage({Key? key}) : super(key: key);

  @override
  _ConnectMusicLibrariesRegistrationPageState createState() =>
      _ConnectMusicLibrariesRegistrationPageState();
}

class _ConnectMusicLibrariesRegistrationPageState
    extends State<ConnectMusicLibrariesRegistrationPage> {

      List musicServiceButtons = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.only(top: 20, left: 35, right: 35, bottom: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Text('Registration Complete!', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 40),
                    Text(
                      'Connect Your Music Libraries to Start Clipping!',
                      style: TextStyle(
                        fontSize: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .fontSize,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 8, 104, 187),
                      ),
                    ),

                    SizedBox(height: 30),
                    if (Userservice().hasMusicService(MusicLibraryService.spotify))
                     
                    ExternalSignInServiceButton(
                        onPressed: () async {
                          await SpotifyService().authorize();
                        },
                        buttonText: 'Connect Spotify',
                        fontSize: 18,
                        icon: SvgPicture.asset(
                          width: 28.0,
                          'assets/Spotify_Icon_RGB_Green.svg',
                          semanticsLabel: 'Spotify logo',
                        ),
                        minimumSize:
                            Size(double.infinity, 55) // Change as needed
                        ),
                    SizedBox(height: 20),
                    ExternalSignInServiceButton(
                        onPressed: () async {
                          Map<String, dynamic>? s = await Userservice().getMusicServiceData(MusicLibraryService.spotify);
                          print(jsonEncode(s));

                          },
                        buttonText: 'Connect Youtube Music',
                        fontSize: 18,
                        icon: SvgPicture.asset(
                          width: 32,
                          'assets/app_icon_music_round_192.svg',
                          semanticsLabel: 'YouTube Music Logo',
                        ),
                        minimumSize:
                            Size(double.infinity, 55) // Change as needed
                        ),
                    SizedBox(height: 20),
                    ExternalSignInServiceButton(
                        onPressed: () {/*googleSignIn.signIn();*/},
                        buttonText: 'Connect SoundCloud',
                        fontSize: 18,
                        icon: SvgPicture.asset(
                          width: 28.0,
                          'assets/Spotify_Icon_RGB_Green.svg',
                          semanticsLabel: 'Spotify logo',
                        ),
                        minimumSize:
                            Size(double.infinity, 55) // Change as needed
                        ),
                    SizedBox(height: 20),
                  ]),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(
                  16.0), // Add padding for better positioning
              child: TextButton(
                onPressed: () {
                  // Pop the current route off the navigation stack
                    Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Ensures the Row only takes as much space as needed
                  children: [
                    Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors
                            .blue, // Change as needed for your app's theme
                        fontSize: 20, // Increased font size
                      ),
                    ),
                    Icon(
                      Icons
                          .arrow_forward, // Arrow icon to the right of the text
                      color: Colors
                          .blue, // Match the text color or adjust as needed
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
