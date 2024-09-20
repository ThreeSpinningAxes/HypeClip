import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Providers/TrackClipProvider.dart';
import 'package:hypeclip/Utilities/GenericError.dart';
import 'package:hypeclip/Utilities/ShowSnackbar.dart';
import 'package:hypeclip/Widgets/ConfirmationDialog.dart';
import 'package:hypeclip/Widgets/SaveTrackClipToPlaylistsDialog.dart';
import 'package:hypeclip/Widgets/SubmitButton.dart';
import 'package:hypeclip/Widgets/TrackUI.dart';

class ListOfTrackClips extends ConsumerStatefulWidget {
  final String? playlistName;
  final MusicLibraryService service = MusicLibraryService.spotify;
  const ListOfTrackClips({
    super.key,
    this.playlistName,
  });

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
    final Map<String, TrackClipPlaylist> trackClipPlaylists =
        ref.watch(trackClipProvider);
    final int totalClipsLength = trackClipPlaylists[playlistName]!.clips.length;
    filterClips(search.text);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar replacement
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              context.pop();
            },
          ),
          if (totalClipsLength == 0)
            Expanded(
              child: GenericError(
                title: 'Empty Playlist',
                description:
                    'This playlist has no clips. Add some clips to this playlist to see them here.',
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    SubmitButton(
                      onPressed: () {
                        if (trackClipPlaylists[
                                TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY]!
                            .clips
                            .isEmpty) {
                          context.goNamed('explore');
                          return;
                        }
                        context.pushNamed('library/clipPlaylists/playlist',
                            pathParameters: {
                              'playlistName':
                                  TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY
                            });
                      },
                      text: trackClipPlaylists[
                                  TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY]!
                              .clips
                              .isEmpty
                          ? 'Explore your tracks to create clips'
                          : 'Browse All Saved Clips',
                    ),
                  ],
                ),
              ),
            ),
          if (totalClipsLength > 0)
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: 10, left: 20, right: 20, bottom: 20),
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
                    if (filteredClips.isNotEmpty)
                      SizedBox(
                          height: 400,
                          child: ListView.builder(
                            itemCount: filteredClips.length,
                            itemBuilder: (context, index) {
                              TrackClip clip = filteredClips[index];
                              Song song = clip.song;
                              return ListTile(
                                title: Text(
                                  filteredClips[index].clipName,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                leading: song.albumImage != null
                                    ? FadeInImage.assetNetwork(
                                        placeholder:
                                            'assets/loading_placeholder.gif', // Path to your placeholder image
                                        image: song.albumImage!,
                                        fit: BoxFit.cover,
                                        width:
                                            50.0, // Adjust the width as needed
                                        height:
                                            50.0, // Adjust the height as needed
                                      )
                                    : Icon(Icons.music_note,
                                        color: Colors.white),
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
                                onTap: () {
                                  _initNewTrack(clip: clip, index: index);

                                  ref
                                      .read(
                                          miniPlayerVisibilityProvider.notifier)
                                      .state = false;
                                  ref
                                      .read(trackClipProvider.notifier)
                                      .appendRecentlyListenedToTrack(clip);
                                  context.pushNamed('songPlayer');
                                },
                                trailing: IconButton(
                                  onPressed: () {
                                    showTrackOptions(
                                        trackClipPlaylists[playlistName]!,
                                        clip);
                                  },
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void showTrackOptions(TrackClipPlaylist playlist, TrackClip clip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      elevation: 10,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.transparent,
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.5,
              builder:
                  (BuildContext context, ScrollController scrollController) {
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
                            trackName: clip.clipName,
                            artistName:
                                clip.song.artistName ?? 'Unknown Artist',
                            albumImageURL: clip.song.albumImage ?? ''),
                      ),

                      if (clip.clipDescription != null &&
                          clip.clipDescription!.trim().isNotEmpty)
                        ListTile(
                          title: Text(
                            "Description",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            clip.clipDescription!,
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ListTile(
                        leading: Icon(Icons.play_arrow, color: Colors.white),
                        title: Text('Play clip',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () async {
                          _initNewTrack(clip: clip, index: 0);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(miniPlayerVisibilityProvider.notifier)
                              .state = true;
                          Response r = await ref.read(playbackProvider).playCurrentTrack(0);
                          
                          if (r.statusCode == 200 || r.statusCode == 204) {
                            ref
                                .read(trackClipProvider.notifier)
                                .appendRecentlyListenedToTrack(
                                    clip);
                          }

                          
                         
                        },
                      ),

                      ListTile(
                        leading: Icon(Icons.playlist_add, color: Colors.white),
                        title: Text('Add to playlist',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  SaveTrackClipToPlaylistsDialog(
                                      clip, playlist));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.queue_music_outlined,
                            color: Colors.white),
                        title: Text('Add to queue',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () {
                          Navigator.pop(context);
                          ref.read(playbackProvider).addTrackClipToQueue(clip);
                          ShowSnackBar.showSnackbar(context,
                              message: 'Added to queue', seconds: 3, ref: ref);
                        },
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.queue_play_next, color: Colors.white),
                        title: Text('Play next',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () {
                          Navigator.pop(context);
                          ref
                              .read(playbackProvider)
                              .addTrackClipNextInQueue(clip);
                          ShowSnackBar.showSnackbar(context,
                              message: 'Added in queue to play next',
                              seconds: 3,
                              ref: ref);
                        },
                      ),

                      ListTile(
                        leading: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                        title: Text('Delete clip',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ConfirmationDialog(
                                  title: 'Delete Clip',
                                  content:
                                      'Are you sure you want to delete this clip?',
                                  onPrimaryConfirm: () async {
                                    bool confirm = await ref
                                        .read(trackClipProvider.notifier)
                                        .removeClipFromPlaylist(
                                            playlistName: playlistName,
                                            trackClip: clip,
                                            playbackRef: ref);
                                    if (confirm) {
                                      ShowSnackBar.showSnackbar(context,
                                          message: 'Deleted clip',
                                          seconds: 3,
                                          ref: ref);
                                    } else {
                                      ShowSnackBar.showSnackbar(context,
                                          message: 'Issue deleting clip',
                                          seconds: 3,
                                          ref: ref);
                                    }

                                    if (context.mounted &&
                                        Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                    if (context.mounted &&
                                        Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  onCancel: () {
                                    if (context.mounted &&
                                        Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                );
                              });
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

  void _initNewTrack({required TrackClip clip, required index}) {
    Map<String, TrackClipPlaylist> trackClipPlaylists =
        ref.read(trackClipProvider);
    int originalIndex = trackClipPlaylists[playlistName]!
        .clips
        .indexWhere((clip) => clip.ID == filteredClips[index].ID);
    ref.read(playbackProvider).init(PlaybackState(
        currentProgress: Duration.zero,
        currentSong: clip.song,
        startPosition: Duration(milliseconds: clip.clipPoints[0].toInt()),
        paused: true,
        currentTrackIndex: originalIndex,
        trackClipPlaylist: ref.read(trackClipProvider)[playlistName],
        currentTrackClip: clip,
        inTrackClipPlaybackMode: true,
        musicLibraryService: widget.service,
        isShuffleMode: false,
        isRepeatMode: false,
        trackClipQueue: [...trackClipPlaylists[playlistName]!.clips],
        originalTrackQueue: [...trackClipPlaylists[playlistName]!.clips]));
  }

  void filterClips(String searchString) {
    searchString = searchString.trim().toLowerCase();
    final Map<String, TrackClipPlaylist> trackClipPlaylists =
        ref.read(trackClipProvider);
    final List<TrackClip> trackClips =
        trackClipPlaylists[playlistName]?.clips ?? [];

    if (searchString.isNotEmpty) {
      //print(songs.length);
      List<TrackClip> filtered = trackClips.where((clip) {
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
        filteredClips = filtered;
      });
    } else {
      // Reset to original clips if search string is empty
      setState(() {
        filteredClips = trackClips;
      });
    }
  }
}
