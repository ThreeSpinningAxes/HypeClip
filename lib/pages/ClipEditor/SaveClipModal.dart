import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Widgets/CreateNewPlaylistModal.dart';
import 'package:hypeclip/Providers/TrackClipProvider.dart';
import 'package:hypeclip/Services/UserProfileService.dart';

import 'package:hypeclip/Utilities/StringUtils.dart';
import 'package:hypeclip/Widgets/SubmitButton.dart';
import 'package:hypeclip/main.dart';

class SaveClipModal extends ConsumerStatefulWidget {
  final Song song;
  final List<double> clipPoints;
  final MusicLibraryService musicLibraryService;
  final bool fromSongPlayback;

  const SaveClipModal(
      {super.key,
      required this.song,
      required this.clipPoints,
      required this.musicLibraryService,
      this.fromSongPlayback = true});

  @override
  _SaveClipModalState createState() => _SaveClipModalState();
}

class _SaveClipModalState extends ConsumerState<SaveClipModal> {
  final _formKey = GlobalKey<FormState>();
  String? clipName = '';
  String? clipDescription = '';
  String defaultClipName = '';
  String? playlistName;


 List<String> selectedTrackClipPlaylistsIDs = List.from(<String>{});

  TextEditingController clipNameController = TextEditingController();
  TextEditingController clipDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    defaultClipName =
        "${widget.song.songName} (${Stringutils.getTimeformat(widget.clipPoints[0].toInt())} - ${Stringutils.getTimeformat(widget.clipPoints[1].toInt())})";
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.4,
      child: AlertDialog(
        title: Stack(
          fit: StackFit.loose,
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Save Clip',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        scrollable: true,
        insetPadding: EdgeInsets.all(20),
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(children: [
            Form(
              key: _formKey,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.45,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    buildSongCard(),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Clip name (optional)",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      autocorrect: false,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(color: Colors.red),
                        hintText:
                            'Enter your own name for your clip (optional)',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.6),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      controller: clipNameController,
                      onSaved: (val) {
                        String? value = val?.trim();
                        if (value != null || value != '') {
                          clipName = value;
                        } else {
                          clipName = defaultClipName;
                        }
                      },
                      validator: (clipName) {
                        if (clipName!.length > 32) {
                          return 'Clip name must be less than or equal to 32 characters.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Clip Description (optional)",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      autocorrect: false,
                      controller: clipDescriptionController,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(color: Colors.red),
                        hintText: 'Enter clip description',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 1.6),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      onSaved: (value) {
                        clipDescription = value;
                      },
                      validator: (clipDescription) {
                        if (clipDescription != null &&
                            clipDescription.length > 120) {
                          return 'Clip description must be less than or equal to 120 characters.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            showSelectedPlaylistDialog().whenComplete(() {
                              setState(() {});
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.playlist_add,
                                color: selectedTrackClipPlaylistsIDs.isNotEmpty
                                    ? Colors.green
                                    : Colors.white,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Add to playlist",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: selectedTrackClipPlaylistsIDs.isNotEmpty
                                      ? Colors.green
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedTrackClipPlaylistsIDs.isNotEmpty)
                          Row(
                            children: [
                              SizedBox(width: 8),
                              Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            TrackClip clip = TrackClip(
                              song: widget.song,
                              clipName: clipNameController.text == ''
                                  ? defaultClipName
                                  : clipNameController.text,
                              clipDescription: clipDescriptionController.text,
                              clipPoints: widget.clipPoints,
                              dateCreated: DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day),
                              musicLibraryService: widget.musicLibraryService,
                            );
                            clip.clipLengthDB =
                                (clip.clipPoints[1] - clip.clipPoints[0])
                                    .toInt();
                            clip.linkedSongDB.target = widget.song;
                            clip.musicLibraryServiceDB =
                                widget.musicLibraryService.name;

                            db.addNewTrackClipToDB(clip: clip, playlistIDs: selectedTrackClipPlaylistsIDs);

                            if (selectedTrackClipPlaylistsIDs.isNotEmpty) {
                              for (String playlistID in selectedTrackClipPlaylistsIDs) {
                                await UserProfileService.saveNewTrackClip(
                                    trackClip: clip,
                                    playlistName: db.trackClipPlaylistBox.getAll().firstWhere((playlist) => playlist.playlistID == playlistID).playlistName,
                                    save: false);
                              }
                            } else {
                              await UserProfileService.saveNewTrackClip(
                                  trackClip: clip,
                                  playlistName: TrackClipPlaylist
                                      .SAVED_CLIPS_PLAYLIST_KEY,
                                  save: true);
                            }
                            ref.read(trackClipProvider.notifier).updateClips();
                            ref
                                .read(playbackProvider)
                                .updatePlaybackState(inClipEditorMode: false);

                            if (context.mounted) {
                              if (!widget.fromSongPlayback &&
                                  ref.context.mounted) {
                                ref.read(playbackProvider).pauseTrack();
                              }
                              Navigator.of(context).pop();
                              _showSuccessDialog();
                            }
                            // Handle form submission
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Text(
                          'Save to library',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<dynamic> showSelectedPlaylistDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Dialog(
              insetPadding: EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.arrow_back, color: Colors.white))),
                    Text(
                      "Playlists",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    SizedBox(height: 20),
                    SubmitButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => CreateNewPlaylistModal(
                                    selectedTrackClipPlaylistIDs: selectedTrackClipPlaylistsIDs,
                                  )).then((value) {
                            setState(() {});
                          });
                        },
                        text: "New playlist"),
                    SizedBox(height: 20),

                    //add button to create playlist
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            db.trackClipPlaylistBox.getAll().length, //ref.watch(trackClipProvider).values.length,
                        itemBuilder: (context, index) {
                          List<TrackClipPlaylist> playlists = db.trackClipPlaylistBox.getAll();
                         
                          // ref
                          //     .watch(trackClipProvider)
                          //     .values
                          //     .where((playlist) =>
                          //         playlist.playlistName !=
                          //         TrackClipPlaylist.RECENTLY_LISTENED_KEY)
                          //     .toList();
                          return CheckboxListTile(
                            checkColor: Colors.transparent,
                            activeColor: Theme.of(context).primaryColor,
                            shape: CircleBorder(),
                            checkboxShape: CircleBorder(),
                            secondary: playlists[index].clipsDB.isNotEmpty && playlists[index].clipsDB.first
                                            .linkedSongDB.target!.albumImage !=
                                        null
                                ? FadeInImage.assetNetwork(
                                    placeholder:
                                        'assets/loading_placeholder.gif', // Path to your placeholder image
                                    image: playlists[index].clipsDB.first
                                            .linkedSongDB.target!.albumImage!,
                                    fit: BoxFit.cover,
                                    width: 40.0, // Adjust the width as needed
                                    height: 40.0, // Adjust the height as needed
                                  )
                                : SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: Icon(Icons.music_note,
                                        color: Colors.white, size: 30)),
                            title: Text(playlists[index].playlistName),
                            value: selectedTrackClipPlaylistsIDs
                                .contains(playlists[index].playlistID),
                            onChanged: (bool? value) {
                              setState(() {
                                selectedTrackClipPlaylistsIDs
                                        .contains(playlists[index].playlistID)
                                    ? selectedTrackClipPlaylistsIDs
                                        .remove(playlists[index].playlistID)
                                    : selectedTrackClipPlaylistsIDs
                                        .add(playlists[index].playlistID);
                              });
                            },
                          );
                        },
                      ),
                    ),
                    SubmitButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        text: "Finish Selection"),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Close the dialog after 3 seconds
        Future.delayed(Duration(seconds: 3), () {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });

        return SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: AlertDialog(
              insetPadding: EdgeInsets.all(20),
              content: Builder(
                builder: (context) {
                  // Get available height and width of the build area of this widget. Make a choice depending on the size.
                  var height = MediaQuery.of(context).size.height * 0.2;
                  var width = MediaQuery.of(context).size.width * 0.4;

                  return SizedBox(
                    height: height,
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.green, size: 50),
                        SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Successfully Saved Clip!',
                            style: TextStyle(color: Colors.green, fontSize: 20),
                            softWrap: true,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              actions: [
                Center(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.green),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      )),
                    ),
                    onPressed: () {
                      if (context.mounted && Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }

                      if (context.mounted && Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ));
      },
    );
  }

  Widget buildSongCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            // Album Image
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Image.network(
                widget.song.songImage ?? widget.song.albumImage!,
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 20.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    defaultClipName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    widget.song.artistName!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Song Name and Artist

            // Play/Pause Button
          ],
        ),
      ],
    );
  }
}
