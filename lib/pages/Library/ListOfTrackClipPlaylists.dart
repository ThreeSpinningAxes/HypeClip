import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Providers/MiniPlayerProvider.dart';
import 'package:hypeclip/Widgets/ConfirmationDialog.dart';
import 'package:hypeclip/Widgets/CreateNewPlaylistModal.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Providers/TrackClipProvider.dart';
import 'package:hypeclip/Utilities/ShowSnackbar.dart';
import 'package:hypeclip/Widgets/TrackUI.dart';
import 'package:hypeclip/Services/UserProfileService.dart';

class ListOfTrackClipPlaylists extends ConsumerStatefulWidget {
  final MusicLibraryService service = MusicLibraryService.spotify;
  const ListOfTrackClipPlaylists({
    super.key,
  });

  @override
  _ListOfTrackClipsState createState() => _ListOfTrackClipsState();
}

class _ListOfTrackClipsState extends ConsumerState<ListOfTrackClipPlaylists> {
  List<TrackClipPlaylist> filteredPlaylists = [];

  TextEditingController search = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    search.addListener(() {
      filterPlaylists(searchString: search.text);
    });
    filterPlaylists(searchString: "");
  }

  @override
  Widget build(BuildContext context) {
    final trackClipProviderData = ref.watch(trackClipProvider);
    filterPlaylists(searchString: search.text); //force update of UI
    List<TrackClipPlaylist> playlists = trackClipProviderData.values.toList();
    final int totalPlaylistsLength =
        playlists.length - 1; // -1 for recently played playlist

    final TrackClipPlaylist savedClipsPlaylist =
        trackClipProviderData[TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY]!;

    return Column(
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
                showDialog(
                    context: context,
                    builder: (context) {
                      return CreateNewPlaylistModal();
                    });
              },
            ),
          ],
        ),
        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: const Text('Playlists',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      )),
                  subtitle: Text('$totalPlaylistsLength total playlists',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                ),
                SizedBox(height: 15),
                SearchBar(
                  autoFocus: false,
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
                genericTrackListTile(
                    playlist: savedClipsPlaylist, pinned: true),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: filteredPlaylists.length,
                      itemBuilder: (context, index) {
                        TrackClipPlaylist playlist = filteredPlaylists[index];
                        if (playlist.playlistName !=
                                TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY &&
                            playlist.playlistName !=
                                TrackClipPlaylist.RECENTLY_LISTENED_KEY) {
                          return genericTrackListTile(playlist: playlist);
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void showPlaylistOptions(TrackClipPlaylist playlist) {
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
                              trackName: playlist.playlistName,
                              artistName: '',
                              albumImageURL: playlist.clips.isNotEmpty
                                  ? playlist.clips[0].song.albumImage ?? ''
                                  : null)),

                      ListTile(
                        leading: Icon(Icons.play_arrow, color: Colors.white),
                        title: Text('Play playlist',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () async {
                          _initPlaylistPlayback(playlist);
                           if (context.mounted) {
                            Navigator.pop(context);
                          }
                          ref
                              .read(miniPlayerVisibilityProvider.notifier)
                              .state = true;
                          Response r = await ref
                              .read(playbackProvider)
                              .playCurrentTrack(0);
                          if (r.statusCode == 200 || r.statusCode == 204) {
                            ref
                                .read(trackClipProvider.notifier)
                                .appendRecentlyListenedToTrack(
                                    playlist.clips[0]);
                          }
                         
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
                          ref
                              .read(playbackProvider)
                              .addTrackClipPlaylistToQueue(playlist);
                          ShowSnackBar.showSnackbar(context,
                              message: 'Added playlist to queue',
                              seconds: 3,
                              ref: ref);
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
                              .addTrackClipPlaylistNextInQueue(playlist);
                          ShowSnackBar.showSnackbar(context,
                              message: 'Playing ${playlist.playlistName} next',
                              seconds: 3,
                              ref: ref);
                        },
                      ),
                      if (playlist.playlistName !=
                          TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY)
                        ListTile(
                          leading: Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                          title: Text('Delete Playlist',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                          onTap: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return ConfirmationDialog(
                                    primaryConfirmText: "Delete",
                                    title: 'Delete Playlist',
                                    content:
                                        'Are you sure you want to delete this playlist?\n(All clips by are saved by default)',
                                    onPrimaryConfirm: () async {
                                      await ref
                                          .read(trackClipProvider.notifier)
                                          .deletePlaylist(
                                              playlistName:
                                                  playlist.playlistName,
                                              keepClips: true);
                                      if (context.mounted &&
                                          Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }

                                      // IMPLEMENT MODAL TO ASK USER TO KEEP CLIPS
                                      ShowSnackBar.showSnackbar(context,
                                          message: 'Deleted playlist',
                                          textStyle:
                                              TextStyle(color: Colors.green),
                                          seconds: 3,
                                          ref: ref);
                                    },
                                    onSecondConfirm: () async {
                                      await ref
                                          .read(trackClipProvider.notifier)
                                          .deletePlaylist(
                                              playlistName:
                                                  playlist.playlistName,
                                              keepClips: false);
                                      Navigator.pop(context);
                                      ShowSnackBar.showSnackbar(context,
                                          message:
                                              'Deleted playlist and all clips',
                                          textStyle:
                                              TextStyle(color: Colors.green),
                                          seconds: 3,
                                          ref: ref);
                                    },
                                    secondConfirmText:
                                        "Delete Playlist and Clips",
                                    secondConfirmButtonColor:
                                        Theme.of(context).primaryColor,
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

  ListTile genericTrackListTile(
      {required TrackClipPlaylist playlist, bool pinned = false}) {
    return ListTile(
      title: Text(
        playlist.playlistName,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
      leading:
          playlist.clips.isNotEmpty && playlist.clips[0].song.albumImage != null
              ? FadeInImage.assetNetwork(
                  placeholder:
                      'assets/loading_placeholder.gif', // Path to your placeholder image
                  image: playlist.clips[0].song.albumImage!,
                  fit: BoxFit.cover,
                  width: 50.0, // Adjust the width as needed
                  height: 50.0, // Adjust the height as needed
                )
              : SizedBox(
                  height: 50,
                  width: 50,
                  child: Icon(Icons.music_note, color: Colors.white, size: 30)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (pinned)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.pin_drop,
                    color: Theme.of(context).primaryColor,
                    size: 14,
                  ),
                ),
              Text(
                "playlist",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        context.pushNamed('library/clipPlaylists/playlist',
            pathParameters: {"playlistName": playlist.playlistName});
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
  }

  void filterPlaylists({required String searchString}) {
    List<TrackClipPlaylist> trackClipPlaylists =
        ref.read(trackClipProvider).values.toList();

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

  void _initPlaylistPlayback(TrackClipPlaylist playlist)  {
    ref.read(playbackProvider).init(PlaybackState(
        currentProgress: Duration.zero,
        currentSong: playlist.clips[0].song,
        startPosition:
            Duration(milliseconds: playlist.clips[0].clipPoints[0].toInt()),
        paused: true,
        currentTrackIndex: 0,
        trackClipPlaylist: playlist,
        currentTrackClip: playlist.clips[0],
        inTrackClipPlaybackMode: true,
        musicLibraryService: playlist.clips[0].musicLibraryService,
        isShuffleMode: false,
        isRepeatMode: false,
        trackClipQueue: [...playlist.clips],
        originalTrackQueue: [...playlist.clips]));
  }
}
