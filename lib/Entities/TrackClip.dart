import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:uuid/uuid.dart';

class TrackClip {
  static final Uuid _uuid = Uuid();

  String clipID;
  Song song;
  List<double> clipPoints;
  String clipName;
  String? clipDescription;
  DateTime dateCreated;
  MusicLibraryService musicLibraryService;

  TrackClip({
    required this.song,
    required this.clipPoints,
    required this.clipName,
    this.clipDescription,
    required this.dateCreated,
    required this.musicLibraryService, 
    String? clipID,
  }) : clipID = clipID ?? _uuid.v1();

  factory TrackClip.fromJson(Map<String, dynamic> json) {
    return TrackClip(
      clipID: json['clipID'],
      song: Song.fromJson(json['song']),
      clipPoints: List<double>.from(json['clipPoints']),
      clipName: json['clipName'],
      clipDescription: json['clipDescription'],
      dateCreated: DateTime.parse(json['dateCreated']),
      musicLibraryService: MusicLibraryService.values.firstWhere((service) => service.toString() == json['musicLibraryService']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clipID': clipID,
      'song': song.toJson(),
      'clipPoints': clipPoints,
      'clipName': clipName,
      'clipDescription': clipDescription,
      'dateCreated': dateCreated.toIso8601String(),
      'musicLibraryService': musicLibraryService.toString(),
    };
  }
}
