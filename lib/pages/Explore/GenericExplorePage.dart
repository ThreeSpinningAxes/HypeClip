import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Utilities/StringExtensions.dart';

class GenericExplorePage extends StatefulWidget {
  final MusicLibraryService service;
  const GenericExplorePage({super.key, required this.service});

  @override
  _GenericExplorePageState createState() => _GenericExplorePageState();
}

class _GenericExplorePageState extends State<GenericExplorePage> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(children: [
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
      Expanded(
          child: Padding(
        padding: EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            SearchBar(
              
              controller: searchController,
              hintText: 'Search for any song',
              hintStyle:
                  WidgetStateProperty.all(TextStyle(color: Colors.black)),
              leading: Icon(
                Icons.search_outlined,
                color: Colors.black,
              ),
              backgroundColor: WidgetStateProperty.all(Colors.grey.shade200),
              shadowColor: WidgetStateProperty.all(Colors.black),
              constraints: BoxConstraints(minHeight: 50),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    12), // Adjust the corner radius as needed
                side: BorderSide(color: Colors.grey.shade200),
              )),
            ),
            SizedBox(
              height: 40,
            ),
            ListTile(
              leading: Icon(Icons.favorite,
                  size: 42,
                  color: Color.fromARGB(
                      255, 8, 104, 187)), // Adjust color and size as needed
              title: Text('Liked Songs',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white)), // Adjust text style as needed
              subtitle: Text(
                  'Liked songs on ${widget.service.name.toCapitalized()}',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
              onTap: () {
                // Add your action for Playlists here
                context.pushNamed('explore/connectedAccounts/browseMusicPlatform/userLikedSongs');
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
                  'Saved playlists on ${widget.service.name.toCapitalized()}',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
              onTap: () {
                context.pushNamed('explore/connectedAccounts/browseMusicPlatform/userPlaylists');
                print('Playlists tapped');
              },
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.access_time,
                  size: 42,
                  color: Color.fromARGB(
                      255, 8, 104, 187)), // Adjust color and size as needed
              title: Text('Recently Listened To',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.white)), // Adjust text style as needed
              subtitle: Text(
                  'Recent songs listened to on ${widget.service.name.toCapitalized()}',
                  style: TextStyle(fontSize: 14, color: Colors.white)),
              onTap: () {
                // Add your action for Playlists here
                context.pushNamed('explore/connectedAccounts/browseMusicPlatform/userRecentlyPlayedTracks');
                print('recently tapped');
              },
            ),
          ],
        ),
      ))
    ]);
  }
}
