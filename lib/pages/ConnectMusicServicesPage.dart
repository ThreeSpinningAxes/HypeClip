import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/Services/UserService.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';

class ConnectMusicServicesPage extends StatefulWidget {
  final Function? onConnectedCallback;

  const ConnectMusicServicesPage({super.key, this.onConnectedCallback});

  @override
  _ConnectMusicLibrariesRegistrationPageState createState() =>
      _ConnectMusicLibrariesRegistrationPageState();
}

class _ConnectMusicLibrariesRegistrationPageState
    extends State<ConnectMusicServicesPage> {
  Set musicServices = Userservice.user.connectedMusicLibraries.keys.toSet();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => navigateBackToRoute(context),
          ),),
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
                    if (!musicServices.contains(MusicLibraryService.spotify))
                      ExternalSignInServiceButton(
                          onPressed: () async {
                            await SpotifyService().authorize();
                            if (Userservice.hasMusicService(
                                MusicLibraryService.spotify)) {
                              afterSuccessfulConnection(
                                  MusicLibraryService.spotify);
                                  
                            }
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
                    if (!musicServices
                        .contains(MusicLibraryService.youtubeMusic))
                      ExternalSignInServiceButton(
                          onPressed: () async {
                            Map<String, dynamic>? s =
                                await Userservice.getMusicServiceData(
                                    MusicLibraryService.spotify);
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
                    if (!musicServices.contains(MusicLibraryService.soundCloud))
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
        ]),
      ),
    );
  }

  void afterSuccessfulConnection(MusicLibraryService service) {
    setState(() {
      // Change the skip button to next and remove the descriptor

      musicServices.add(service);
      ShowSnackBar.showSnackbar(
          context, "Susscessfully added ${service.name}", 3);
    });
     widget.onConnectedCallback?.call();
  }

    void navigateBackToRoute(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // Fallback to popping the current route if no route name is provided
    }
  }
}
