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
}