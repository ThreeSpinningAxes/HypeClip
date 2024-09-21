import 'package:flutter/material.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:objectbox/objectbox.dart';
import 'package:uuid/uuid.dart';


class TrackClip {
  static final Uuid _uuid = Uuid();


  
  String ID;
  Song song;
  List<double> clipPoints;
  Duration? clipLength;
  String clipName;
  String? clipDescription;
  DateTime dateCreated;
  MusicLibraryService musicLibraryService;
  RadialGradient? domColorRadGradient;

  TrackClip({
    required this.song,
    required this.clipPoints,
    required this.clipName,
    this.clipDescription,
    required this.dateCreated,
    required this.musicLibraryService,
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
      'song': song.toJson(),
      'clipPoints': clipPoints,
      'clipName': clipName,
      'clipDescription': clipDescription,
      'dateCreated': dateCreated.toIso8601String(),
      'musicLibraryService': musicLibraryService.toString(),
      'clipLength': clipLength!.inMilliseconds,
      
    };
  }
}
