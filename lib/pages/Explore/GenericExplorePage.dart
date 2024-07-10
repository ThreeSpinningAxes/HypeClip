import 'package:flutter/material.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Pages/Explore/likedSongs.dart';
import 'package:hypeclip/Utilities/StringExtensions.dart';

class GenericExplorePage extends StatefulWidget {
  final MusicLibraryService service;
  const GenericExplorePage({Key? key, required this.service}) : super(key: key);

  @override
  _GenericExplorePageState createState() => _GenericExplorePageState();
}

class _GenericExplorePageState extends State<GenericExplorePage> {
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Explore',
      )),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
        child: Column(children: [
          SizedBox(
            height: 20,
          ),
          SearchBar(
            controller: searchController,
            hintText: 'Search for any song',
            hintStyle: WidgetStateProperty.all(TextStyle(color: Colors.black)),
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
            height: 50,
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
            subtitle: Text('Liked songs on ${widget.service.name.toCapitalized()}', style: TextStyle(fontSize: 14, color: Colors.white)), 
            onTap: () {
              // Add your action for Playlists here
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => LikedSongs()));
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
            subtitle: Text('Saved playlists on ${widget.service.name.toCapitalized()}', style: TextStyle(fontSize: 14, color: Colors.white)), 
            onTap: () {
              // Add your action for Playlists here
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
             subtitle: Text('Recent songs listened toon ${widget.service.name.toCapitalized()}', style: TextStyle(fontSize: 14, color: Colors.white)), 
            onTap: () {
              // Add your action for Playlists here
              print('Playlists tapped');
            },
          ),
        ]),
      ),
    );
  }
}
