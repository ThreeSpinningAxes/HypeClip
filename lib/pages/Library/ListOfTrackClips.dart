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
import 'package:hypeclip/Utilities/GenericError.dart';
import 'package:hypeclip/Utilities/ShowSnackbar.dart';
import 'package:hypeclip/Widgets/ConfirmationDialog.dart';
import 'package:hypeclip/Widgets/SaveTrackClipToPlaylistsDialog.dart';
import 'package:hypeclip/Widgets/SubmitButton.dart';
import 'package:hypeclip/Widgets/TrackUI.dart';
import 'package:hypeclip/main.dart';
import 'package:hypeclip/objectbox.g.dart';

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
  late String playlistName;
  Stream<List<TrackClip>> trackClips = Stream.empty();

  TextEditingController search = TextEditingController(text: '');

  @override
  void initState() {
    super.initState();
    playlistName =
        widget.playlistName ?? TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY;

    search.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (playlistName == TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY) {
      trackClips = db.trackClipBox.query().watch(triggerImmediately: true).map(
          (trackClip) => trackClip
              .find()
              .where((clip) => clip.backup.target == null && matchSearchString(clip))
              .toList());
    } else {
      trackClips = db.trackClipPlaylistBox
          .query((TrackClipPlaylist_.playlistName.equals(playlistName)))
          .watch(triggerImmediately: true)
          .map((playlist) => playlist
              .find()
              .first
              .clipsDB
              .where((clip) =>  matchSearchString(clip))
              .toList());
    }
    return StreamBuilder(
        stream: trackClips,
        builder: (context, snapshot) {
          // if (snapshot.hasError) {
          //   return GenericError(
          //     title: 'Error',
          //     description: 'An error occurred while fetching clips',
          //     child: SubmitButton(
          //       onPressed: () {
          //         setState(() {});
          //       },
          //       text: 'Retry',
          //     ),
          //   );
          // }

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
                if (snapshot.data?.length == 0) //EDIT
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
                              if (widget.playlistName == TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY || db.trackClipBox.isEmpty()) {
                                context.goNamed('explore');
                                return;
                              }
                              context.pushNamed(
                                  'library/clipPlaylists/playlist',
                                  pathParameters: {
                                    'playlistName': TrackClipPlaylist
                                        .SAVED_CLIPS_PLAYLIST_KEY
                                  });
                            },
                            text: db.trackClipBox.isEmpty()
                                ? 'Explore your tracks to create clips'
                                : 'Browse All Saved Clips',
                          ),
                        ],
                      ),
                    ),
                  ),
                if (snapshot.data != null && snapshot.data!.isNotEmpty)
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
                            subtitle: Text('${snapshot.data?.length} clips',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),
                          ),
                          SizedBox(height: 15),
                          SearchBar(
                            controller: search,
                            hintText: 'Search',
                            hintStyle: WidgetStateProperty.all(
                                TextStyle(color: Colors.black)),
                            leading: Icon(Icons.search_outlined,
                                color: Colors.black),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.grey.shade200),
                            shadowColor: WidgetStateProperty.all(Colors.black),
                            constraints: BoxConstraints(minHeight: 40),
                            textStyle: WidgetStateProperty.all(
                                TextStyle(color: Colors.black)),
                            shape:
                                WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // Adjust the corner radius as needed
                              side: BorderSide(color: Colors.grey.shade200),
                            )),
                          ),
                          SizedBox(height: 20),
                          if (snapshot.data?.length != 0)
                            SizedBox(
                                height: 400,
                                child: ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    TrackClip clip = snapshot.data![index];
                                    Song song = clip.linkedSongDB.target!;
                                    return ListTile(
                                      title: Text(
                                        snapshot.data![index].clipName,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${song.songName!} - ${song.artistName!}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        _initNewTrack(clip: clip, index: index);

                                        ref
                                            .read(miniPlayerVisibilityProvider
                                                .notifier)
                                            .state = false;
                                        // ref
                                        //     .read(trackClipProvider.notifier)
                                        //     .appendRecentlyListenedToTrack(
                                        //         clip); // EDIT
                                        db.addTrackClipToRecentlyListened(clip: clip);
                                        context.pushNamed('songPlayer',
                                            queryParameters: {
                                              'resetForNewTrack': 'true',
                                            });
                                      },
                                      trailing: IconButton(
                                        onPressed: () {
                                          showTrackOptions(clip);
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
        });
  }

  void showTrackOptions(TrackClip clip) {
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
              minChildSize: 0.25,
              maxChildSize: 0.7,
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
                            artistName: clip.linkedSongDB.target!.artistName ??
                                'Unknown Artist',
                            albumImageURL:
                                clip.linkedSongDB.target!.albumImage ?? ''),
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
                          Response r = await ref
                              .read(playbackProvider)
                              .playCurrentTrack(0);

                          if (r.statusCode == 200 || r.statusCode == 204) {
                            // ref
                            //     .read(trackClipProvider.notifier)
                            //     .appendRecentlyListenedToTrack(clip); //REMOVE

                            db.addTrackClipToRecentlyListened(clip: clip);
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
                                  SaveTrackClipToPlaylistsDialog(clip, playlistName));
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
                      if (playlistName != TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY)
                      ListTile(
                        leading: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.white,
                        ),
                        title: Text('Remove clip',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                        onTap: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ConfirmationDialog(
                                  title: 'Remove Clip',
                                  content:
                                      'Are you sure you want to remove this clip from this playlist?',
                                  onPrimaryConfirm: ()  {

                                    db.deleteTrackClipFromPlaylist(clip, playlistName);
                                     setState(() {
                                      
                                    });

                                      ShowSnackBar.showSnackbar(context,
                                          message: 'Removed clip from playlist',
                                          seconds: 3,
                                          ref: ref);

                                    // else {
                                    //   ShowSnackBar.showSnackbar(context,
                                    //       message: 'Issue deleting clip',
                                    //       seconds: 3,
                                    //       ref: ref);
                                    // }

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
                      ListTile(
                        leading: Icon(
                          Icons.delete_forever,
                          color: Colors.red,
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
                                      'Are you sure you want to permanently delete this clip?',
                                  onPrimaryConfirm: ()  {

                                    deleteTrackClip(clip: clip);
                                    setState(() {
                                      
                                    });

                                      ShowSnackBar.showSnackbar(context,
                                          message: 'Deleted clip',
                                          seconds: 3,
                                          ref: ref);

                                    // else {
                                    //   ShowSnackBar.showSnackbar(context,
                                    //       message: 'Issue deleting clip',
                                    //       seconds: 3,
                                    //       ref: ref);
                                    // }

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
                                }).then((_) {
                                if (context.mounted && Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
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
    int originalIndex;
    TrackClipPlaylist? playlist;

    if (playlistName == TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY) {
      originalIndex = db.trackClipBox
          .getAll()
          .indexWhere((element) => element.ID == clip.ID);
    } else {
      originalIndex = db.trackClipPlaylistBox
              .query((TrackClipPlaylist_.playlistName.equals(playlistName)))
              .build()
              .findFirst()
              ?.clipsDB
              .indexWhere((element) => element.ID == clip.ID) ??
          0;
      playlist = db.trackClipPlaylistBox
          .query((TrackClipPlaylist_.playlistName.equals(playlistName)))
          .build()
          .findFirst()!;
    }

    ref.read(playbackProvider).init(PlaybackState(
            currentProgress: Duration.zero,
            currentSong: clip.linkedSongDB.target!,
            startPosition: Duration(milliseconds: clip.clipPoints[0].toInt()),
            paused: true,
            currentTrackIndex: originalIndex,
            //trackClipPlaylist: ref.read(trackClipProvider)[playlistName],
            currentTrackClip: clip,
            inTrackClipPlaybackMode: true,
            musicLibraryService: widget.service,
            isShuffleMode: false,
            isRepeatMode: false,
            trackClipQueue: [
              ...playlist?.clipsDB ?? db.trackClipBox.getAll()
            ],
            originalTrackQueue: [
              ...playlist?.clipsDB ?? db.trackClipBox.getAll()
            ]));
  }


  bool matchSearchString(TrackClip clip) {
    final clipNameContainsSearch = clip.clipName
        .toString()
        .toLowerCase()
        .contains(search.text.toLowerCase());
    final songNameContainsSearch = clip.linkedSongDB.target!.songName
        .toString()
        .toLowerCase()
        .contains(search.text.toLowerCase());
    final artistNameContainsSearch = clip.linkedSongDB.target!.artistName
        .toString()
        .toLowerCase()
        .contains(search.text.toLowerCase());
    return clipNameContainsSearch ||
        songNameContainsSearch ||
        artistNameContainsSearch;
  }

  void deleteTrackClip({required TrackClip clip, bool fromSavedClips = false}) {
    // if (fromSavedClips) {
    //   db.deleteTrackClip(clip);
      
    // }
    db.deleteTrackClip(clip);
    ref.read(playbackProvider).removeTrackClipFromQueue(clip);
    

  }
  
}
