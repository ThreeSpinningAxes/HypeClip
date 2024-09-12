

import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:uuid/uuid.dart';

class TrackClipPlaylist {

  static final Uuid _uuid = Uuid();

  static const String SAVED_CLIPS_PLAYLIST_KEY = 'Saved Clips';

  static const String RECENTLY_LISTENED_KEY = 'Recently Listened Clips';

  String playlistID;

  String playlistName;

  DateTime? dateCreated;

  List<TrackClip> clips = List.empty(growable: true);


  TrackClipPlaylist({
    String? playlistID,
    required this.playlistName,
    this.dateCreated,
    required this.clips,

  }) : playlistID = playlistID ?? _uuid.v1() {
    dateCreated = dateCreated ?? DateTime.now();
  }

  factory TrackClipPlaylist.fromJson(Map<String, dynamic> json) {
    return TrackClipPlaylist(
      playlistID: json['playlistID'],
      playlistName: json['playlistName'],
      dateCreated: DateTime.parse(json['dateCreated']),
      clips: List<TrackClip>.from(json['clips'].map((clipJson) => TrackClip.fromJson(clipJson))),
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'playlistID': playlistID,
      'playlistName': playlistName,
      'dateCreated': dateCreated?.toIso8601String(),
      'clips': clips.map((clip) => clip.toJson()).toList(),
    };
  }

  void addClip(TrackClip clip) {
    clips.add(clip);
  }

  void removeClip(TrackClip clip) {
    if (clips.remove(clip)) {
    }
  }

  int getTrackClipCount() {
    return clips.length;
  }
}