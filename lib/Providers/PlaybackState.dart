
import 'package:flutter/material.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';

class PlaybackState {
  Song? currentSong;
  Duration? currentProgress;
  bool? paused;
  int? currentSongIndex;
  List<Song>? songs = [];
  MusicLibraryService? musicLibraryService;
  LinearGradient? domColorLinGradient;

  PlaybackState({this.currentSong,this.currentProgress,this.paused, this.currentSongIndex, this.songs, this.musicLibraryService, this.domColorLinGradient}) ;

   PlaybackState copyWith({
    Duration? currentProgress,
    int? currentSongIndex,
    List<Song>? songs,
    bool? paused,
    MusicLibraryService? musicLibraryService,
    Song? currentSong,
  }) 
  {

    return PlaybackState(
      currentProgress: currentProgress ?? this.currentProgress,
      paused: paused ?? this.paused,
      songs: songs ?? this.songs, currentSongIndex: currentSongIndex ?? 0, 
      currentSong: currentSong ?? this.currentSong,
      musicLibraryService: musicLibraryService ?? this.musicLibraryService,
    );
  }

  PlaybackState copyState(PlaybackState newPlaybackState) {
    return PlaybackState(
      currentProgress: newPlaybackState.currentProgress,
      paused: newPlaybackState.paused,
      songs: newPlaybackState.songs,
      currentSongIndex: newPlaybackState.currentSongIndex,
      currentSong: newPlaybackState.currentSong,
      musicLibraryService: newPlaybackState.musicLibraryService,
    );
  }

}