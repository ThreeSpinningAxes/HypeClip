import 'package:flutter/material.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/objectbox.dart';
import 'package:hypeclip/objectbox.g.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';



final objectBoxProvider = Provider<ObjectBox>((ref) {
  throw UnimplementedError();
});


final trackClipNotifierProvider = ChangeNotifierProvider<TrackClipNotifier>((ref) {
  final objectBox = ref.watch(objectBoxProvider);
  return TrackClipNotifier(objectBox.trackClipBox, objectBox.trackClipPlaylistBox);
});
class TrackClipNotifier extends ChangeNotifier {
  final Box<TrackClip> trackClipBox;
  final Box<TrackClipPlaylist> trackClipPlaylistBox;

  TrackClipNotifier(this.trackClipBox, this.trackClipPlaylistBox) {
    // Listen for changes in the trackClipBox
    trackClipBox.query().watch().listen((query) {
      notifyListeners();
    });

    // Listen for changes in the trackClipPlaylistBox
    trackClipPlaylistBox.query().watch().listen((query) {
      notifyListeners();
    });
  }

  List<TrackClip> getTrackClips(String playlistName) {
    // Fetch track clips based on the playlist name
    return trackClipPlaylistBox.query((TrackClipPlaylist_.playlistName.equals(playlistName))).build().findFirst()?.clipsDB ?? [];
  }

}