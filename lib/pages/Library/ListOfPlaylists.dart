import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Widgets/CreateNewPlaylistModal.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Providers/TrackClipProvider.dart';
import 'package:hypeclip/Services/UserProfileService.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:hypeclip/Widgets/TrackUI.dart';
import 'package:spotify_sdk/models/track.dart';

class ListOfPlaylists extends ConsumerStatefulWidget {
  final MusicLibraryService service = MusicLibraryService.spotify;
  const ListOfPlaylists({
    super.key,
  });

  @override
  _ListOfTrackClipsState createState() => _ListOfTrackClipsState();
}

class _ListOfTrackClipsState extends ConsumerState<ListOfPlaylists> {
  List<TrackClipPlaylist> filteredPlaylists = [];
  List<TrackClipPlaylist> playlists = [];

  TextEditingController search = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    search.addListener(() {
      filterPlaylists(searchString: search.text);
    });
  }
  
    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    playlists = ref.watch(trackClipProvider).values.toList();
    filterPlaylists(searchString: '');
  }

  @override
  Widget build(BuildContext context) {
    playlists = ref.watch(trackClipProvider).values.toList();
    filterPlaylists(searchString: search.text, inputPlaylists: playlists);
    final int totalPlaylistsLength = playlists.length;
    return SafeArea(
      child: Column(
        children: [
          // AppBar replacement
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              IconButton(
              icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 24,
              ),
              onPressed: () {
                showDialog(context: context, builder: (context) {
                  return CreateNewPlaylistModal();
                });
                
              },
            ),
            ],
          ),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 20),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Playlists',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                        )),
                    subtitle: Text('$totalPlaylistsLength total playlists',
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                  SizedBox(height: 15),
                  SearchBar(
                    controller: search,
                    hintText: 'Search',
                    hintStyle:
                        WidgetStateProperty.all(TextStyle(color: Colors.black)),
                    leading: Icon(Icons.search_outlined, color: Colors.black),
                    backgroundColor:
                        WidgetStateProperty.all(Colors.grey.shade200),
                    shadowColor: WidgetStateProperty.all(Colors.black),
                    constraints: BoxConstraints(minHeight: 40),
                    textStyle:
                        WidgetStateProperty.all(TextStyle(color: Colors.black)),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          12), // Adjust the corner radius as needed
                      side: BorderSide(color: Colors.grey.shade200),
                    )),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: filteredPlaylists.length,
                        itemBuilder: (context, index) {
                          TrackClipPlaylist playlist = filteredPlaylists[index];
                          return ListTile(
                            title: Text(
                              filteredPlaylists[index].playlistName == TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY
                                  ? "Saved Clips"
                                  : filteredPlaylists[index].playlistName,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            leading: playlist.clips.isNotEmpty && playlist.clips[0].song.albumImage != null
                                ? FadeInImage.assetNetwork(
                                    placeholder:
                                        'assets/loading_placeholder.gif', // Path to your placeholder image
                                    image: playlist.clips[0].song.albumImage!,
                                    fit: BoxFit.cover,
                                    width: 50.0, // Adjust the width as needed
                                    height: 50.0, // Adjust the height as needed
                                  )
                                : Container(height: 50, width: 50, child: Icon(Icons.music_note, color: Colors.white, size: 30)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "playlist",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ],
                            ),
                            onTap: () {                          
                              context.pushNamed('library/clipPlaylists/playlist', pathParameters: {"playlistName": playlist.playlistName});
                            },
                            trailing: IconButton(
                              onPressed: () {
                                showPlaylistOptions(playlist);
                              },
                              icon: Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      )
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showPlaylistOptions(
      TrackClipPlaylist playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      elevation: 10,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            color: Colors.transparent,
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.25,
              maxChildSize: 0.5,
              builder: (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      SizedBox(
                        height: 70,
                        child: Trackui.buildTrackCard(context,
                            trackName: playlist.playlistName,
                            artistName: '',
                            albumImageURL: playlist.clips.isNotEmpty ? playlist.clips[0].song.albumImage ?? '' : null)
                        ),
            
                      ListTile(
                        leading: Icon(Icons.queue_music_outlined, color: Colors.white),
                        title: Text('Add to queue', style: TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () {
                          Navigator.pop(context);
                          ref.read(playbackProvider).addTrackClipPlaylistToQueue(playlist);
                          ShowSnackBar.showSnackbar(context, message: 'Added playlist to queue', seconds: 3);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.queue_play_next, color: Colors.white),
                        title: Text('Play next', style: TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () {
                          Navigator.pop(context);
                          ref.read(playbackProvider).addTrackClipPlaylistNextInQueue(playlist);
                          ShowSnackBar.showSnackbar(context, message: 'Playing ${playlist.playlistName} next', seconds: 3);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.white,),
                        title: Text('Delete Playlist', style: TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () async {
                          Navigator.pop(context);
                        await ref.read(trackClipProvider.notifier).deletePlaylist(playlistName: playlist.playlistName, keepClips: false);
                        // IMPLEMENT MODAL TO ASK USER TO KEEP CLIPS
                          ShowSnackBar.showSnackbar(context, message: 'Deleted playlist', seconds: 3);
                        },
                      ),
                      // Add more options here
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void filterPlaylists({required String searchString, List<TrackClipPlaylist>? inputPlaylists}) {
    List<TrackClipPlaylist> trackClipPlaylists = inputPlaylists ?? ref.read(trackClipProvider).values.toList();

    searchString = searchString.trim().toLowerCase();
    
    if (searchString.isNotEmpty) {
      //print(songs.length);
      List<TrackClipPlaylist> filtered = trackClipPlaylists.where((playlist) {
        final playlistNameContainsSearch = playlist.playlistName
            .toString()
            .toLowerCase()
            .contains(searchString.toLowerCase());

        return playlistNameContainsSearch;
          
      }).toList();
      setState(() {
        filteredPlaylists = filtered;
      });
    } else {
      // Reset to original clips if search string is empty
      setState(() {
        filteredPlaylists = trackClipPlaylists;
      });
    }
  }
}
