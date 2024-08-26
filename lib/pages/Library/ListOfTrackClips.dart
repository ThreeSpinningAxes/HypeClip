import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Providers/TrackClipProvider.dart';
import 'package:hypeclip/Services/UserProfileService.dart';

class ListOfTrackClips extends ConsumerStatefulWidget {
  final String? playlistName;
  const ListOfTrackClips({super.key, this.playlistName});

  @override
  _ListOfTrackClipsState createState() => _ListOfTrackClipsState();
}

class _ListOfTrackClipsState extends ConsumerState<ListOfTrackClips> {
  List<TrackClip> filteredClips = [];
  late String playlistName;

  TextEditingController search = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    playlistName =
        widget.playlistName ?? TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY;
    search.addListener(() {
      filterClips(search.text);
    });
    filterClips('');
  }

 @override
Widget build(BuildContext context) {
  final Map<String, TrackClipPlaylist> trackClipPlaylists = ref.watch(trackClipProvider);
  final int totalClipsLength = trackClipPlaylists[playlistName]!.clips.length;

  return SafeArea(
    child: Column(
      children: [
        // AppBar replacement
        Row(
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
          ],
        ),
        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
            child: Column(
              children: [
                
                ListTile(
                  title: Text(widget.playlistName ?? 'Saved Clips',
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          )),
                  subtitle: Text('$totalClipsLength clips',
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
                Container(
                  height: 400,
                  child: ListView.builder(
                    itemCount: filteredClips.length,
                    itemBuilder: (context, index) {
                      Song song = filteredClips[index].song;
                      return ListTile(
                        title: Text(
                          filteredClips[index].clipName,
                          style: TextStyle(color: Colors.white, fontSize: 14),
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${song.songName!} - ${song.artistName!}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  void filterClips(String searchString) {
    searchString = searchString.trim().toLowerCase();
    final trackClipPlaylists = ref.read(trackClipProvider);
    final trackClips = trackClipPlaylists[playlistName]?.clips ?? [];

    if (searchString.isNotEmpty) {
      //print(songs.length);
      List<TrackClip> filtered =
          trackClips.where((clip) {
        final clipNameContainsSearch = clip.clipName
            .toString()
            .toLowerCase()
            .contains(searchString.toLowerCase());
        final songNameContainsSearch = clip.song.songName
            .toString()
            .toLowerCase()
            .contains(searchString.toLowerCase());
        final artistNameContainsSearch = clip.song.artistName
            .toString()
            .toLowerCase()
            .contains(searchString.toLowerCase());
        return clipNameContainsSearch ||
            songNameContainsSearch ||
            artistNameContainsSearch;
      }).toList();
      setState(() {
        this.filteredClips = filtered;
      });
    }
    else {
    // Reset to original clips if search string is empty
    setState(() {
      this.filteredClips = trackClips;
    });
  }
  }
}
