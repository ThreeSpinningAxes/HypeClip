import 'package:flutter/material.dart';

class Song {
  Duration? duration;
  String trackURI;
  String? artistName;
  String? songName;
  String? songImage;
  String? artistImage;
  Color? songColor;
 
  String? albumImage;
  String? albumName;
  String? imageURL;


  Song(
      {this.duration,
      required this.trackURI,
      this.artistName,
      this.songName,
      this.songImage,
      this.artistImage,
      this.songColor,
   
      this.albumImage,
      this.albumName,
      this.imageURL});

      factory Song.fromJson(Map<String, dynamic> json) {
        return Song(
          duration: json['duration'] != null ? Duration(milliseconds: json['duration']) : null,
          trackURI: json['trackURI'],
          artistName: json['artistName'],
          songName: json['songName'],
          songImage: json['songImage'],
          artistImage: json['artistImage'],
          songColor: json['songColor'] != null ? Color(json['songColor']) : null,
          albumImage: json['albumImage'],
          albumName: json['albumName'],
          imageURL: json['imageURL'],
        );
      }

      Map<String, dynamic> toJson() {
        return {
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
        };
      }
}