import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Entities/Playlist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/Pages/Explore/TrackList.dart';

class UserPlaylistsPage extends StatefulWidget {
  final MusicLibraryService service = MusicLibraryService.spotify;
  const UserPlaylistsPage({super.key});

  @override
  _UserPlaylistsPageState createState() => _UserPlaylistsPageState();
}

class _UserPlaylistsPageState extends State<UserPlaylistsPage>
    with AutomaticKeepAliveClientMixin {
  int offset = 0;
  late MusicServiceHandler musicServiceHandler;
  Future<List<Playlist>>? playlists;
  List<Playlist> filteredPlaylists = [];
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
    musicServiceHandler = MusicServiceHandler(service: widget.service);
    playlists = loadPlaylists();
    search.addListener(() {
      updateSearchQuery(search.text);
    });
  }

  Future<List<Playlist>> loadPlaylists() async {
    int offset = 0;
    List<Playlist> playlists = [];
    while (true) {
      List<Playlist>? fetchedPlaylists = await musicServiceHandler.getUserPlaylists(50, offset);
      if (fetchedPlaylists != null && fetchedPlaylists.isNotEmpty) {
        playlists.addAll(fetchedPlaylists);
        filteredPlaylists.addAll(fetchedPlaylists);
        if (fetchedPlaylists.length < 50) {
          break;
        }
        offset += fetchedPlaylists.length;
      } else {
        break;
      }
    }
    return playlists; // Return the list of all fetched songs
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      if (newQuery.isNotEmpty) {
        playlists!.then((playlist) {
          //print(songs.length);
          filteredPlaylists = playlist.where((playlist) {
            return playlist.name
                .toString()
                .toLowerCase()
                .contains(search.text.toLowerCase());
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        FutureBuilder<List<dynamic>>(
          future: playlists, // The future you want to wait for
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading indicator while waiting for the future to complete
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.white,
              ));
            } else if (snapshot.hasError) {
              // Handle any errors that occur during the future execution
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              // Once data is fetched, build the entire page content
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    if (snapshot.data!.isEmpty)
                      
                        ListTile(
                      title: Text('No Playlists found',
                          style: TextStyle(fontSize: 22, color: Colors.white)),
                     
                         
                    ),
                      
                    if (snapshot.data!.isNotEmpty)
                    ListTile(
                      title: Text('Your Saved Playlists',
                          style: TextStyle(fontSize: 22, color: Colors.white)),
                      subtitle: Text('${snapshot.data!.length} playlists',
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                    SizedBox(height: 15),
                    // Your SearchBar widget here
                    // Assuming SearchBar doesn't depend on the fetched data
                    
                    if (snapshot.data!.isNotEmpty)
                      SearchBar(
                        controller: search,
                        hintText: 'Search',
                        hintStyle: WidgetStateProperty.all(
                            TextStyle(color: Colors.black)),
                        leading:
                            Icon(Icons.search_outlined, color: Colors.black),
                        backgroundColor:
                            WidgetStateProperty.all(Colors.grey.shade200),
                        shadowColor: WidgetStateProperty.all(Colors.black),
                        constraints: BoxConstraints(minHeight: 40),
                        textStyle: WidgetStateProperty.all(
                            TextStyle(color: Colors.black)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Adjust the corner radius as needed
                          side: BorderSide(color: Colors.grey.shade200),
                        )),
                      ),
                    SizedBox(height: 20),
                    // Now, ListView.builder to display the fetched data
                    Expanded(
                      child: SizedBox(
                        height: 400,
                        child: ListView.builder(
                          itemCount: filteredPlaylists.length,
                          itemBuilder: (context, index) {
                            // var song = filteredSongs[index]['track'];
                        
                            Playlist playlist = filteredPlaylists[index];
                            //var artistImage = song['artists'][0]['images'][0]['url'];
                        
                            return ListTile(
                              
                               leading: playlist.imageUrl != null
                                  ? FadeInImage.assetNetwork(
                                      placeholder:
                                          'assets/loading_placeholder.gif', // Path to your placeholder image
                                      image: playlist.imageUrl!,
                                      fit: BoxFit.cover,
                                      width: 50.0, // Adjust the width as needed
                                      height: 50.0, // Adjust the height as needed
                                    )
                                  : SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Icon(Icons.music_note, color: Colors.white),
                                    ),
                        
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        TrackList(playlist: playlist)));
                              },
                              title: Text(playlist.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors
                                          .white)), // Adjust according to your data structure
                              subtitle: Text(playlist.ownerName ?? 'Unknown',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white)),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
