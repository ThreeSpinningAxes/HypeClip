import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/AppleMusicService.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/OnBoarding/UserProfileFireStoreService.dart';
import 'package:hypeclip/OnBoarding/widgets/externalSignInServiceButton.dart';
import 'package:hypeclip/Services/UserProfileService.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:hypeclip/Utilities/ShowLoading.dart';

class ConnectMusicServicesPage extends ConsumerStatefulWidget {
  const ConnectMusicServicesPage({super.key, this.showBackButton, this.showContinue, this.showDescription});

  final bool? showBackButton;
  final bool? showContinue;
  final bool? showDescription;

  @override
  _ConnectMusicLibrariesRegistrationPageState createState() =>
      _ConnectMusicLibrariesRegistrationPageState();
}

class _ConnectMusicLibrariesRegistrationPageState
    extends ConsumerState<ConnectMusicServicesPage> {
  Set<MusicLibraryService> musicServices =
      UserProfileService.getConnectedMusicLibraries();

  String nextText = 'Skip';
  String nextTextDescriptor =
      'You can always connect your music libraries later in settings.';

  bool _isLoading = false;

  void afterSuccessfulConnection(
      MusicLibraryService service, Map<String, dynamic> data) async {
    setState(() {
      // Change the skip button to next and remove the descriptor
      if (nextText.startsWith("S")) {
        nextText = "Continue";
        nextTextDescriptor = '';
      }
      musicServices.add(service);

      print(UserProfileService.getConnectedMusicLibraries());
    });
    await UserProfileFireStoreService()
        .addMusicService(FirebaseAuth.instance.currentUser!.uid, service, data);
    if (mounted) {
      ShowSnackBar.showSnackbar(
          context, message: "Susscessfully added ${service.name}", seconds: 3);
    }
  }

  void navigateBackToRoute(BuildContext context) {
    context.pop();
  }

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
      appBar: AppBar(toolbarHeight: 40, automaticallyImplyLeading: widget.showBackButton ?? true), 
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
                              if (data !=null && UserProfileService.hasMusicService(MusicLibraryService.spotify)) {
                                afterSuccessfulConnection(MusicLibraryService.spotify, data);
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
                                  await UserProfileService.getMusicServiceData(
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
                      if (!musicServices.contains(MusicLibraryService.appleMusic))   
                      ExternalSignInServiceButton(
                          onPressed: () async {
                            Map<String, dynamic>? data = await AppleMusicService().authorize();
                            if (data != null && UserProfileService.hasMusicService(MusicLibraryService.appleMusic)) {
                              
                              afterSuccessfulConnection(MusicLibraryService.spotify, data);
                              
                            }
                          },
                          buttonText: 'Connect Apple Music',
                          fontSize: 18,
                          icon: SvgPicture.asset(
                            width: 32,
                            'assets/appleMusicLogo/standard.svg',
                            semanticsLabel: 'Apple Music Logo',
                          ),
                          minimumSize:
                              Size(double.infinity, 55) // Change as needed
                          ),
                    if (widget.showDescription ?? false) 
                    SizedBox(height: 20,),
                    if (widget.showDescription ?? false)                    
                    Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          nextTextDescriptor,
                          style: TextStyle(
                            color: Colors.white, // Change as needed for your app's theme
                            fontSize: 14,
                            
                          ),
                          softWrap: true,
                          overflow: TextOverflow.clip,
                        ),
                      ),)
                      
                    ],
                  )
                    ]),

              ),
            ),
            if (widget.showContinue ?? false)
                      Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(
                  16.0), // Add padding for better positioning
              child: TextButton(
                onPressed: () {
                 GoRouter.of(context).go('/auth');
                  
                },
                child: Stack(alignment: Alignment.bottomRight, children: [
                  Row(
                    mainAxisSize: MainAxisSize
                        .min, // Ensures the Row only takes as much space as needed
                    children: [
                      Text(
                        nextText,
                        style: TextStyle(
                          color: Colors
                              .blue, // Change as needed for your app's theme
                          fontSize: 20, // Increased font size
                        ),
                      ),
                      SizedBox(width: 5), // Space between text and icon
                      Icon(
                        Icons
                            .arrow_forward, // Arrow icon to the right of the text
                        color: Colors
                            .blue, // Match the text color or adjust as needed
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                ]),
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
