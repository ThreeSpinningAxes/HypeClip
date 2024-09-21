import 'package:flutter/material.dart';
import 'package:hypeclip/Entities/Playlist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Song {

  @Id(assignable: true)
  int? id = 0;

  String? trackID;

  @Transient()
  Duration? duration;

  int get getDurationDB => duration?.inMilliseconds ?? 0;
  set setDurationDB(int value) => duration = Duration(milliseconds: value);
  
  String trackURI;
  String? artistName;

  @Index()
  String? songName;
  String? songImage;
  String? artistImage;

  @Transient()
  Color? songColor;

  String? albumImage;
  String? albumName;
  String? imageURL;


  @Transient()
  MusicLibraryService? musicLibraryService;

  String get musicLibraryServiceDB => musicLibraryService?.name ?? MusicLibraryService.unknown.name;
  set setMusicLibraryServiceDB(String value) => musicLibraryService = MusicLibraryService.values.firstWhere((val) {
    return val.name == value;
  }, orElse: () => MusicLibraryService.unknown);

   final playlist = ToMany<Playlist>();


  

  Song(
      {
        this.id,
        this.duration,
        this.trackID,
      required this.trackURI,
      this.artistName,
      this.songName,
      this.songImage,
      this.artistImage,
      this.songColor,
      this.albumImage,
      this.albumName,
      this.imageURL,
      this.musicLibraryService});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? 0,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      trackURI: json['trackURI'],
      artistName: json['artistName'],
      songName: json['songName'],
      songImage: json['songImage'],
      artistImage: json['artistImage'],
      songColor: json['songColor'] != null ? Color(json['songColor']) : null,
      albumImage: json['albumImage'],
      albumName: json['albumName'],
      imageURL: json['imageURL'],
      musicLibraryService: json['musicLibraryService'] != null
          ? MusicLibraryService.values.firstWhere((val) {
              return val.name == json['musicLibraryService'];
            })
          : MusicLibraryService.unknown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'duration': duration?.inMilliseconds,
      'trackURI': trackURI,
      'artistName': artistName,
      'songName': songName,
      'songImage': songImage,
      'artistImage': artistImage,
      'songColor': songColor?.value,
      'albumImage': albumImage,
      'albumName': albumName,
      'imageURL': imageURL,
      'musicLibraryService': musicLibraryService?.name,
    };
  }
}


