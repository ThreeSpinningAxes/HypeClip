import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Utilities/ShowSnackbar.dart';
import 'package:hypeclip/main.dart';

class CreateNewPlaylistModal extends ConsumerStatefulWidget {
  final TrackClip? trackClip;
  //if widget is  from the create new clip page, this will be used to preselect the newly created playlist
  final List<String>? selectedTrackClipPlaylistIDs;

  CreateNewPlaylistModal(
      {super.key, this.trackClip, this.selectedTrackClipPlaylistIDs});

  @override
  _SaveClipModalState createState() => _SaveClipModalState();
}

class _SaveClipModalState extends ConsumerState<CreateNewPlaylistModal> {
  final _formKey = GlobalKey<FormState>();
  String playlistName = '';
  TextEditingController playlistNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final allPlaylists = db.trackClipPlaylistBox.getAll();

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
                  'Create New Playlist',
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
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    TextFormField(
                      cursorColor: Theme.of(context).primaryColor,
                      textAlign: TextAlign.center,
                      autocorrect: false,
                      decoration: InputDecoration(
                        fillColor: Colors.black,
                        filled: true,
                        errorStyle: TextStyle(
                          color: Colors.red,
                        ),
                        hintText: 'Name your new playlist',
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
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
                      controller: playlistNameController,
                      onSaved: (val) {
                        if (val == null) return;
                        playlistName = val.trim();
                      },
                      validator: (name) {
                        if (name == null || name.isEmpty) {
                          return 'Please enter a name for your playlist.';
                        }
                        if (name.length > 24) {
                          return 'Must be less than or equal to 24 characters.';
                        }
                        if (allPlaylists
                            .any((element) => element.playlistName == name)) {
                          return 'Playlist with this name already exists.';
                        }

                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            TrackClipPlaylist playlist = TrackClipPlaylist(
                              playlistName: playlistName,
                              clips: widget.trackClip != null
                                  ? <TrackClip>[widget.trackClip!]
                                  : List.empty(growable: true),
                              dateCreated: DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day),
                            );

                            db.addNewTrackClipPlaylist(playlist);
                            final playlists = db.trackClipPlaylistBox.getAll();
                            for (var playlist in playlists) {
                              print(playlist.playlistName);
                            }

                            if (widget.selectedTrackClipPlaylistIDs != null) {
                              widget.selectedTrackClipPlaylistIDs!
                                  .add(playlist.playlistID);
                            }

                            if (context.mounted && Navigator.canPop(context)) {
                              Navigator.of(context).pop();
                            }
                            if (context.mounted) {
                              ShowSnackBar.showSnackbar(context,
                                  message:
                                      "Playlist $playlistName created successfully!",
                                  seconds: 3,
                                  textStyle: TextStyle(color: Colors.green));
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
                          'Create Playlist',
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
}
