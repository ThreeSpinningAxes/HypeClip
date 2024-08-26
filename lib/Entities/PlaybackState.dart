import 'package:flutter/material.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';

class PlaybackState {
  bool? inTrackClipPlaybackMode = false;
  bool? inSongPlaybackMode;

  TrackClipPlaylist? trackClipPlaylist;
  TrackClip? currentTrackClip;

  Song? currentSong;
  Duration? currentProgress;
  bool? paused;
  int? currentTrackIndex;
  List<Song>? songs = [];

  List<TrackClip>? trackClipQueue = [];
  List<Song>? trackQueue = [];

  MusicLibraryService? musicLibraryService;
  LinearGradient? domColorLinGradient;

  PlaybackState({
    this.currentSong,
    this.currentProgress,
    this.paused,
    this.currentTrackIndex,
    this.songs,
    this.musicLibraryService,
    this.domColorLinGradient,
    this.inTrackClipPlaybackMode,
    this.trackClipPlaylist,
    this.currentTrackClip,
    this.inSongPlaybackMode,
    this.trackClipQueue,
    this.trackQueue,
  });

  PlaybackState copyWith({
    Duration? currentProgress,
    int? currentSongIndex,
    List<Song>? songs,
    bool? paused,
    MusicLibraryService? musicLibraryService,
    Song? currentSong,
    List<TrackClip>? trackClips,
    bool? inTrackClipPlaybackMode,
    bool? inSongPlaybackMode,
    TrackClipPlaylist? trackClipPlaylist,
    TrackClip? currentTrackClip,
    List<TrackClip>? trackClipQueue,
    List<Song>? soneQueue,
    LinearGradient? domColorLinGradient

  }) {
    return PlaybackState(
      currentProgress: currentProgress ?? this.currentProgress,
      paused: paused ?? this.paused,
      songs: songs ?? this.songs,
      currentTrackIndex: currentSongIndex ?? 0,
      currentSong: currentSong ?? this.currentSong,
      musicLibraryService: musicLibraryService ?? this.musicLibraryService,
      trackClipPlaylist: trackClipPlaylist ?? this.trackClipPlaylist,
      currentTrackClip: currentTrackClip ?? this.currentTrackClip,
      inSongPlaybackMode: inSongPlaybackMode ?? this.inSongPlaybackMode,
      trackClipQueue: trackClipQueue ?? this.trackClipQueue,
      trackQueue: soneQueue ?? this.trackQueue,
      domColorLinGradient: domColorLinGradient ?? this.domColorLinGradient,
    );
  }

  PlaybackState copyState(PlaybackState newPlaybackState) {
    return PlaybackState(
      currentProgress: newPlaybackState.currentProgress,
      paused: newPlaybackState.paused,
      songs: newPlaybackState.songs,
      currentTrackIndex: newPlaybackState.currentTrackIndex,
      currentSong: newPlaybackState.currentSong,
      musicLibraryService: newPlaybackState.musicLibraryService,
      trackClipPlaylist: newPlaybackState.trackClipPlaylist,
      currentTrackClip: newPlaybackState.currentTrackClip,
      inTrackClipPlaybackMode: newPlaybackState.inTrackClipPlaybackMode,
      inSongPlaybackMode: newPlaybackState.inSongPlaybackMode,
      trackClipQueue: newPlaybackState.trackClipQueue,
      trackQueue: newPlaybackState.trackQueue,
      domColorLinGradient: newPlaybackState.domColorLinGradient,
      
    );
  }
}
