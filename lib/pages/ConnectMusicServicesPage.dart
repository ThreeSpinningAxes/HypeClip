import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/OnBoarding/UserProfileFireStoreService.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/Services/UserService.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:hypeclip/Utilities/ShowLoading.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class ConnectMusicServicesPage extends ConsumerStatefulWidget {
  const ConnectMusicServicesPage({super.key});

  @override
  _ConnectMusicLibrariesRegistrationPageState createState() =>
      _ConnectMusicLibrariesRegistrationPageState();
}

class _ConnectMusicLibrariesRegistrationPageState
    extends ConsumerState<ConnectMusicServicesPage> {
  bool _isLoading = false;
  Set<MusicLibraryService> musicServices =
      Userservice.getConnectedMusicLibraries();
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(toolbarHeight: 40),
      body: ShowLoading(
        message: "Connecting service...",
        isLoading: _isLoading,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    EdgeInsets.only(top: 20, left: 35, right: 35, bottom: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Text('Registration Complete!', style: Theme.of(context).textTheme.headlineMedium),
        
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
                              setState(() {
                                _isLoading = true;
                              });
                              Map<String, dynamic>? data = await SpotifyService().authorize();
                              if (data !=null && Userservice.hasMusicService(MusicLibraryService.spotify)) {
                                afterSuccessfulConnection(MusicLibraryService.spotify, data!);
                              }
                             
                                setState(() {
                                  _isLoading = false;
                                });
                              
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
          ],
        ),
      ),
    );
  }

  void afterSuccessfulConnection(
      MusicLibraryService service, Map<String, dynamic> data) async {
    setState(() {
      // Change the skip button to next and remove the descriptor

      musicServices.add(service);

      print(Userservice.getConnectedMusicLibraries());
    });
    await UserProfileFireStoreService()
        .addMusicService(FirebaseAuth.instance.currentUser!.uid, service, data);
    if (mounted) {
      ShowSnackBar.showSnackbar(
          context, "Susscessfully added ${service.name}", 3);
    }
  }

  void navigateBackToRoute(BuildContext context) {
    context.pop();
  }
}
