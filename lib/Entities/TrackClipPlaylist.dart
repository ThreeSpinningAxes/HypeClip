

import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

@Entity()
class TrackClipPlaylist {

  @Transient()
  static final Uuid _uuid = Uuid();

  @Transient()
  static const String SAVED_CLIPS_PLAYLIST_KEY = 'Saved Clips';

  @Transient()
  static const String RECENTLY_LISTENED_KEY = 'Recently Listened Clips';

  @Id(assignable: true)
  int? dbID;
  
  String playlistID;

  String playlistName;

  @Property(type: PropertyType.date)
  DateTime? dateCreated;

  final clipsDB = ToMany<TrackClip>();

  @Transient()
  List<TrackClip>? clips = List.empty(growable: true);


  TrackClipPlaylist({
    String? playlistID,
    required this.playlistName,
    this.dateCreated,
    this.clips,

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
      'clips': clips!.map((clip) => clip.toJson()).toList(),
    };
  }

  void addClip(TrackClip clip) {
    clips!.add(clip);
  }

  void removeClip(TrackClip clip) {
    if (clips!.remove(clip)) {
    }
  }

  int getTrackClipCount() {
    return clips!.length;
  }
}