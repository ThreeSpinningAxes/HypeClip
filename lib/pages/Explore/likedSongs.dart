import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/Pages/SongPlayer/Song.dart';
import 'package:hypeclip/Pages/SongPlayer/SongPlayback.dart';

class LikedSongs extends StatefulWidget {
  const LikedSongs({super.key});

  @override
  _LikedSongsState createState() => _LikedSongsState();
}

class _LikedSongsState extends State<LikedSongs>
    with AutomaticKeepAliveClientMixin {
  int totalSongs = 0;
  SpotifyService spotifyService = SpotifyService();
  Future<List<dynamic>>? likedSongs;
  List<dynamic> filteredSongs = [];
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
    likedSongs = loadSongs();
  }

  Future<List<dynamic>> loadSongs() async {
    int offset = 0;
    List<dynamic> likedSongs = [];
    while (true) {
      var fetchedSongs = await spotifyService.getUserTracks(50, offset);
      if (fetchedSongs != null && fetchedSongs.isNotEmpty) {
        likedSongs.addAll(fetchedSongs);
        filteredSongs.addAll(fetchedSongs);
        if (fetchedSongs.length < 50) {
          break;
        }
        offset += fetchedSongs.length;
      } else {
        break;
      }
    }
    return likedSongs; // Return the list of all fetched songs
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      if (newQuery.isNotEmpty) {
        likedSongs!.then((songs) {
          //print(songs.length);
          filteredSongs = songs.where((song) {
            return song['track']['name'].toString().toLowerCase().contains(search.text.toLowerCase());
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
            future: likedSongs, // The future you want to wait for
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
                      SizedBox(height: 40,),
                      ListTile(
                        title: Text('Liked Songs',
                            style: TextStyle(fontSize: 22, color: Colors.white)),
                        subtitle: Text('${snapshot.data!.length} songs',
                            style: TextStyle(fontSize: 14, color: Colors.white)),

                      ),
                      SizedBox(height: 15),
                      // Your SearchBar widget here
                      // Assuming SearchBar doesn't depend on the fetched data
                      SearchBar(
                        controller: search..addListener(() {updateSearchQuery(search.text);}),
                        hintText: 'Search',
                        hintStyle:
                            WidgetStateProperty.all(TextStyle(color: Colors.black)),
                        leading: Icon(Icons.search_outlined, color: Colors.black),
                        backgroundColor:
                            WidgetStateProperty.all(Colors.grey.shade200),
                        shadowColor: WidgetStateProperty.all(Colors.black),
                        constraints: BoxConstraints(minHeight: 40),
                        textStyle: WidgetStateProperty.all(TextStyle(color: Colors.black)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Adjust the corner radius as needed
                          side: BorderSide(color: Colors.grey.shade200),
                        )),
                      ),
                      SizedBox(height: 20),
                      // Now, ListView.builder to display the fetched data
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredSongs.length,
                          itemBuilder: (context, index) {
                            var song = filteredSongs[index]['track'];
                            var trackName = song['name'];
                            var artists = song['artists']
                                      .map((artist) => artist['name'])
                                      .join(', ');
                            var duration = song['duration_ms'];
                            var id = song['id'];
                            var href = song['href'];
                            var songURI = song['uri'];
                            var songImage = song['album']['images'][0]['url'];
                            //var artistImage = song['artists'][0]['images'][0]['url'];

                            return ListTile(
                              trailing: Icon(Icons.cut_outlined, color: Colors.white),
                              leading: 
                                    Image(image: NetworkImage(songImage)),
                              
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SongPlayback(
                                  song: Song(
                                    songName: trackName,
                                    artistName: artists,
                                    //artistImage: artistImage,
                                    trackId: songURI,
                                    songImage: songImage,
                                    duration: Duration(milliseconds: duration),),
                                  )
                                ));
                              },
                              title: Text(song['name'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors
                                          .white)), // Adjust according to your data structure
                              subtitle: Text(
                                  song['artists']
                                      .map((artist) => artist['name'])
                                      .join(', '),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style:
                                      TextStyle(fontSize: 12, color: Colors.white)),
                            );
                          },
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
