import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';
import 'package:hypeclip/Widgets/CreateNewPlaylistModal.dart';
import 'package:hypeclip/Widgets/SubmitButton.dart';

import '../Providers/TrackClipProvider.dart';

class SaveTrackClipToPlaylistsDialog extends ConsumerStatefulWidget {
  final TrackClip trackClip;

  final TrackClipPlaylist? currentPlaylist;


  SaveTrackClipToPlaylistsDialog(this.trackClip, this.currentPlaylist,{super.key});
  
  @override
  _SaveTrackClipToPlaylistsDialog createState() => _SaveTrackClipToPlaylistsDialog();
  

}
class _SaveTrackClipToPlaylistsDialog extends ConsumerState<SaveTrackClipToPlaylistsDialog> {

  
  Set<String> selectedPlaylists = {};

 late final TrackClip trackClip ;
 late final TrackClipPlaylist currentPlaylist;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    trackClip = widget.trackClip;
    currentPlaylist = widget.currentPlaylist!;
  }
  
  @override
  Widget build(BuildContext context) {
    List<TrackClipPlaylist> playlists = ref
        .watch(trackClipProvider)
        .values
        .where((playlist) =>
            playlist.playlistName != currentPlaylist.playlistName)
        .toList();
    

    TrackClip clip = trackClip;

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
                                trackClip: clip,
                                selectedPlaylistsInput: selectedPlaylists,
                              ));
                    },
                    text: "New playlist"),
                SizedBox(height: 20),

                //add button to create playlist
                Expanded(
                  child: ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                          checkColor: Colors.transparent,
                          activeColor: Theme.of(context).primaryColor,
                          shape: CircleBorder(),
                          checkboxShape: CircleBorder(),
                          secondary: playlists[index].clips.isNotEmpty &&
                                  playlists[index].clips[0].song.albumImage !=
                                      null
                              ? FadeInImage.assetNetwork(
                                  placeholder:
                                      'assets/loading_placeholder.gif', // Path to your placeholder image
                                  image: playlists[index]
                                      .clips[0]
                                      .song
                                      .albumImage!,
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
                          value: selectedPlaylists
                              .contains(playlists[index].playlistName),
                          onChanged: (bool? value) {
                            setState(() {
                              selectedPlaylists
                                      .contains(playlists[index].playlistName)
                                  ? selectedPlaylists
                                      .remove(playlists[index].playlistName)
                                  : selectedPlaylists
                                      .add(playlists[index].playlistName);
                            });
                          });
                    },
                  ),
                ),
                SubmitButton(
                    onPressed: () {
                      if (selectedPlaylists.isNotEmpty) {
                        for (String playlistName in selectedPlaylists) {
                          ref
                              .read(trackClipProvider.notifier)
                              .addClipToPlaylist(
                                  playlistName: playlistName,
                                  trackClip: trackClip,
                                  save: false);
                        }
                        ref.read(trackClipProvider.notifier).updateClips();
                        ShowSnackBar.showSnackbar(context,
                            message: "Clip saved to selected playlists",
                            seconds: 3,
                            textStyle: TextStyle(color: Colors.green));
                      }
                      if (context.mounted && Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    },
                    text: "Finish Selection"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
