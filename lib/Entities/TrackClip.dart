import 'package:flutter/material.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';

@Entity()
class TrackClip {

  @Transient()
  static final Uuid _uuid = Uuid();

  String ID;

  @Id(assignable: true)
  int? dbID;

  @Transient()
  Song? song;

  final originalSongDB = ToOne<Song>();

  @Property(type: PropertyType.floatVector)
  List<double> clipPoints;

  @Transient()
  Duration? clipLength;

  int get clipLengthDB => clipLength?.inMilliseconds ?? 0;
  set clipLengthDB(int value) => clipLength = Duration(milliseconds: value);

  final linkedSongDB = ToOne<Song>();


  String clipName;
  String? clipDescription;

  @Property(type: PropertyType.date)
  DateTime dateCreated;

  @Transient()
  MusicLibraryService? musicLibraryService;

  String get musicLibraryServiceDB => musicLibraryService!.name;
  set musicLibraryServiceDB(String value) => musicLibraryService = MusicLibraryService.values.firstWhere((val) {
    return val.name == value;
  }, orElse: () => MusicLibraryService.unknown);

  @Transient()
  RadialGradient? domColorRadGradient;

  TrackClip({
    this.song,
    required this.clipPoints,
    required this.clipName,
    this.clipDescription,
    required this.dateCreated,
    this.musicLibraryService,
    this.domColorRadGradient,
    String? ID,
  }) : ID = ID ?? _uuid.v1(),
       clipLength = Duration(milliseconds: (clipPoints[1] - clipPoints[0]).toInt());

  factory TrackClip.fromJson(Map<String, dynamic> json) {
    return TrackClip(
      ID: json['ID'],
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
      'ID': ID,
      'song': song!.toJson(),
      'clipPoints': clipPoints,
      'clipName': clipName,
      'clipDescription': clipDescription,
      'dateCreated': dateCreated.toIso8601String(),
      'musicLibraryService': musicLibraryService.toString(),
      'clipLength': clipLength!.inMilliseconds,
      
    };
  }
}
