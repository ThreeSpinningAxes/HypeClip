import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


class Library extends ConsumerStatefulWidget {
  Library({super.key});

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends ConsumerState<Library> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: SafeArea(child: _buildLibraryUI()),
        ),
      );
    
  }

  Widget _buildLibraryUI() {
    return Column(
      
      children: [

      Padding(
              padding: EdgeInsets.only(top: 0,  bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        ListTile(
          
          leading: Icon(Icons.menu,
              size: 42,
              color: Color.fromARGB(
                  255, 8, 104, 187)), // Adjust color and size as needed
          title: Text('Saved Clips',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white)), // Adjust text style as needed
          subtitle: Text(
              'All your saved clips',
              style: TextStyle(fontSize: 14, color: Colors.white)),
          onTap: () {
            // Add your action for Playlists here
            context.pushNamed('savedClips');
          },
        ),
        SizedBox(height: 20),
        ListTile(
          leading: Icon(Icons.library_music,
              size: 42,
              color: Color.fromARGB(
                  255, 8, 104, 187)), // Adjust color and size as needed
          title: Text('Playlists',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white)), // Adjust text style as needed
          subtitle: Text(
              'Your saved clip playlists',
              style: TextStyle(fontSize: 14, color: Colors.white)),
          onTap: () {
            context.pushNamed('explore/connectedAccounts/browseMusicPlatform/userPlaylists');
          },
        ),
        SizedBox(height: 20),
        // ListTile(
        //   leading: Icon(Icons.access_time,
        //       size: 42,
        //       color: Color.fromARGB(
        //           255, 8, 104, 187)), // Adjust color and size as needed
        //   title: Text('Recently Listened To Clips',
        //       style: TextStyle(
        //           fontSize: 20,
        //           color: Colors.white)), // Adjust text style as needed
        //   subtitle: Text(
        //       'Recent Clips listened to',
        //       style: TextStyle(fontSize: 14, color: Colors.white)),
        //   onTap: () {
        //     // Add your action for Playlists here
        //     context.pushNamed('explore/connectedAccounts/browseMusicPlatform/userRecentlyPlayedTracks');
        //   },
        // ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
            children: [
              Text("Listen Again", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),),
              SizedBox(height: 20),
              
            ],
          ),
        )
      
      ],
              ),
            )
    ]);

  }
  
  
  

}