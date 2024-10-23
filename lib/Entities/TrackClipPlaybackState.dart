
import 'package:flutter/material.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';

class TrackClipPlaybackState {
  Song? currentSong;
  Duration? currentProgress;
  bool? paused;
  int? currentSongIndex;
  List<Song>? songs = [];
  MusicLibraryService? musicLibraryService;
  LinearGradient? domColorLinGradient;

  TrackClipPlaybackState({this.currentSong,this.currentProgress,this.paused, this.currentSongIndex, this.songs, this.musicLibraryService, this.domColorLinGradient}) ;

   TrackClipPlaybackState copyWith({
    Duration? currentProgress,
    int? currentSongIndex,
    List<Song>? songs,
    bool? paused,
    MusicLibraryService? musicLibraryService,
    Song? currentSong,
  }) 
  {

    return TrackClipPlaybackState(
      currentProgress: currentProgress ?? this.currentProgress,
      paused: paused ?? this.paused,
      songs: songs ?? this.songs, currentSongIndex: currentSongIndex ?? 0, 
      currentSong: currentSong ?? this.currentSong,
      musicLibraryService: musicLibraryService ?? this.musicLibraryService,
    );
  }

  TrackClipPlaybackState copyState(TrackClipPlaybackState newPlaybackState) {
    return TrackClipPlaybackState(
      currentProgress: newPlaybackState.currentProgress,
      paused: newPlaybackState.paused,
      songs: newPlaybackState.songs,
      currentSongIndex: newPlaybackState.currentSongIndex,
      currentSong: newPlaybackState.currentSong,
      musicLibraryService: newPlaybackState.musicLibraryService,
    );
  }

}