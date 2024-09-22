import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Entities/Playlist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';

class TrackList extends ConsumerStatefulWidget {
  final MusicLibraryService service = MusicLibraryService.spotify;
  final Playlist? playlist;
  final bool fetchLikedSongs;
  final bool fetchRecentlyPlayedTracks;
  const TrackList(
      {super.key,
      this.playlist,
      this.fetchLikedSongs = false,
      this.fetchRecentlyPlayedTracks = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TrackListState();
}

class _TrackListState extends ConsumerState<TrackList>
    with AutomaticKeepAliveClientMixin {
  int offset = 0;
  late MusicServiceHandler musicServiceHandler;
  Future<List<Song>>? trackList;
  List<Song> filteredSongs = [];
  TextEditingController search = TextEditingController();
  Map<String, int>? originalTrackIndexFromPlaylist;

  @override
  void initState() {
    super.initState();
    musicServiceHandler = MusicServiceHandler(service: widget.service);
    trackList = loadSongs();

    search.addListener(() {
      updateSearchQuery(search.text);
    });
  }

  Future<List<Song>> loadSongs() async {
    Future<List<Song>> songs;
    if (widget.fetchLikedSongs) {
      songs = loadLikedSongs();
    } else if (widget.fetchRecentlyPlayedTracks) {
      songs = loadRecentlyPlayedSongs();
    } else {
      songs = loadTracksFromPlaylist();
    }

    return songs;
  }

  Future<List<Song>> loadLikedSongs() async {
    int offset = 0;
    List<Song> likedSongs = [];
    while (true) {
      List<Song>? fetchedSongs =
          await musicServiceHandler.getUserTracks(50, offset);
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

  Future<List<Song>> loadRecentlyPlayedSongs() async {
    List<Song> recentlyPlayedSongs = [];

    List<Song>? fetchedSongs =
        await musicServiceHandler.getRecentlyPlayedTracks(limit: 50);
    if (fetchedSongs != null && fetchedSongs.isNotEmpty) {
      final Set uniqueFetchedSongs = {};
      fetchedSongs.retainWhere((song) => uniqueFetchedSongs.add(song.trackURI));
      recentlyPlayedSongs.addAll(fetchedSongs);
      filteredSongs.addAll(fetchedSongs);
    }
    return recentlyPlayedSongs; // Return the list of all fetched songs
  }

  Future<List<Song>> loadTracksFromPlaylist() async {
    int offset = 0;
    List<Song> tracks = [];

    List<Song>? fetchedTracks = await musicServiceHandler.getTracksFromPlaylist(
        widget.playlist!, 50, offset);
    if (fetchedTracks != null && fetchedTracks.isNotEmpty) {
      tracks.addAll(fetchedTracks);
      filteredSongs.addAll(fetchedTracks);
    }

    return tracks; // Return the list of all fetched songs
  }

  void updateSearchQuery(String searchString) {
    setState(() {
      if (searchString.isNotEmpty) {
        trackList!.then((songs) {
          //print(songs.length);
          filteredSongs = songs.where((song) {
            final songNameContainsSearch = song.songName
                .toString()
                .toLowerCase()
                .contains(searchString.toLowerCase());
            final artistNameContainsSearch = song.artistName
                .toString()
                .toLowerCase()
                .contains(searchString.toLowerCase());
            return songNameContainsSearch || artistNameContainsSearch;
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
          future: trackList, // The future you want to wait for
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

              // store the index of the original track in the playlist
              List<Song> trackList = snapshot.data as List<Song>;
              if (originalTrackIndexFromPlaylist == null) {
                if (trackList.isNotEmpty) {
                  originalTrackIndexFromPlaylist = {
                    for (var song in trackList)
                      song.trackURI: trackList.indexOf(song)
                  };
                }
              }

              Widget? leading; // Assign a default value
              if (widget.playlist != null) {
                leading = widget.playlist!.imageUrl != null &&
                        widget.playlist!.imageUrl!.isNotEmpty
                    ? Image(image: NetworkImage(widget.playlist!.imageUrl!))
                    : Icon(Icons.music_note, color: Colors.white);
              }

              String title = "";

              if (widget.fetchRecentlyPlayedTracks) {
                title = 'Recently Played Tracks';
              } else if (widget.fetchLikedSongs) {
                title = 'Liked Songs';
              } else {
                title = widget.playlist!.name;
              }

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    ListTile(
                      leading: leading,
                      title: Text(title,
                          style: TextStyle(fontSize: 22, color: Colors.white)),
                      subtitle: Text('${snapshot.data!.length} songs',
                          style: TextStyle(fontSize: 14, color: Colors.white)),
                    ),
                    SizedBox(height: 15),
                    // Your SearchBar widget here
                    // Assuming SearchBar doesn't depend on the fetched data
                    SearchBar(
                      controller: search, 
                      hintText: 'Search',
                      hintStyle: WidgetStateProperty.all(
                          TextStyle(color: Colors.black)),
                      leading: Icon(Icons.search_outlined, color: Colors.black),
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
                      child: ListView.builder(
                        itemCount: filteredSongs.length,
                        itemBuilder: (context, index) {
                          // var song = filteredSongs[index]['track'];

                          Song song = filteredSongs[index];
                          //var artistImage = song['artists'][0]['images'][0]['url'];

                          return ListTile(
                            trailing: IconButton(
                              icon: Icon(
                                Icons.cut_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                List<Song>? songs = trackList;

                                // if (ref.read(playbackProvider).playbackState.currentSong != null && ref.read(playbackProvider).playbackState.currentSong!.trackURI == song.trackURI) {
                                //   ref.read(playbackProvider).state.currentSong!.isPlaying = false;
                                // }

                                ref.read(playbackProvider).init(PlaybackState(
                                    currentSong: song,
                                    currentProgress: Duration.zero,
                                    
                                    paused: true,
                                    currentTrackIndex:
                                        originalTrackIndexFromPlaylist?[
                                                song.trackURI] ??
                                            0,
                                    songs: songs,
                                    musicLibraryService: widget.service,
                                    inSongPlaybackMode: true,
                                    inTrackClipPlaybackMode: false,
                                    originalTrackQueue: List.empty(growable: true)));
                                ref
                                    .watch(
                                        miniPlayerVisibilityProvider.notifier)
                                    .state = false;

                                context.pushNamed('clipEditor', queryParameters: {'fromSongPlaybackWidget': 'false'});
                              },
                            ),
                            leading: song.albumImage != null
                                ? FadeInImage.assetNetwork(
                                    placeholder:
                                        'assets/loading_placeholder.gif', // Path to your placeholder image
                                    image: song.albumImage!,
                                    fit: BoxFit.cover,
                                    width: 50.0, // Adjust the width as needed
                                    height: 50.0, // Adjust the height as needed
                                  )
                                : Icon(Icons.music_note, color: Colors.white),

                            onTap: () async {
                              List<Song>? songs = trackList;
                              ref.read(playbackProvider).init(PlaybackState(
                                    currentSong: song,
                                    currentProgress: Duration.zero,
                                    paused: true,
                                    currentTrackIndex:
                                        originalTrackIndexFromPlaylist?[song.trackURI] ?? 0,
                                    trackQueue: [...songs],
                                    songs: songs,
                                    musicLibraryService: widget.service,
                                    inSongPlaybackMode: true,
                                    inTrackClipPlaybackMode: false,
                                    originalTrackQueue: [...songs],
                                    isShuffleMode: false,
                                    isRepeatMode: false,
                                  ));
                              ref
                                  .watch(miniPlayerVisibilityProvider.notifier)
                                  .state = false;
                              context.pushNamed('songPlayer', queryParameters: {'resetForNewTrack': 'true'});
                            },
                            title: Text(song.songName ?? 'Unknown',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors
                                        .white)), // Adjust according to your data structure
                            subtitle: Text(song.artistName ?? 'Unknown',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white)),
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
