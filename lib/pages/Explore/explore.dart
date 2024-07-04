import 'package:flutter/material.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/OnBoarding/UserProfileFireStoreService.dart';
import 'package:hypeclip/Pages/Explore/noConnectedAccounts.dart';
import 'package:hypeclip/Services/UserService.dart';
import 'package:hypeclip/Widgets/ConnectedAccounts.dart';

class Explore extends StatefulWidget {
  Explore({super.key});

  
  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  Set<MusicLibraryService> connectedMusicLibraries = Userservice.getConnectedMusicLibraries();
  Widget page = Container();
  @override
  initState() {
    super.initState();
    connectedMusicLibraries.isEmpty ? page = NoConnectedAccounts(onConnectedCallback: updateMusicServices) : page = ConnectedAccounts();
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              page,
            ],
          ),
        ),
      ),
    );
  }

  void updateMusicServices() {
    setState(() {
      connectedMusicLibraries = Userservice.getConnectedMusicLibraries();
      connectedMusicLibraries.isEmpty ? page = NoConnectedAccounts() : page = ConnectedAccounts();
    });
  }
}
