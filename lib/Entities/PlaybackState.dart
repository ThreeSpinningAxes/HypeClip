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
  Duration? startPosition = Duration.zero;
  Duration? currentProgress;
  bool? paused;
  int? currentTrackIndex;
  List<Song>? songs = List.empty(growable: true);

  List<TrackClip>? trackClipQueue = List.empty(growable: true);
  List<Object>? originalTrackQueue = List.empty(growable: true); //used if shuffle is undone

  List<Song>? trackQueue = List.empty(growable: true);

  MusicLibraryService? musicLibraryService;
  RadialGradient? domColorLinGradient;

  bool isShuffleMode = false;
  bool isRepeatMode = false;

  bool inClipEditorMode = false;
  bool autoplay = true;
  int? trackLength;

  String? currentTrackName;
  String? currentTrackArtist;
  String? currentTrackImg;

  bool? error; //implement error afterwards


  PlaybackState({
    this.currentSong,
    this.currentProgress,
    this.paused,
    this.currentTrackIndex,
    this.songs,
    this.musicLibraryService,
    this.domColorLinGradient,
    this.inTrackClipPlaybackMode = false,
    this.trackClipPlaylist,
    this.currentTrackClip,
    this.inSongPlaybackMode,
    this.trackClipQueue,
    this.trackQueue,
    this.startPosition,
    this.isShuffleMode = false, 
    this.isRepeatMode = false, 
    this.originalTrackQueue,
    this.inClipEditorMode = false,
    this.autoplay = true,
    this.trackLength,
    this.currentTrackArtist,
    this.currentTrackImg,
    this.currentTrackName,

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
    RadialGradient? domColorLinGradient,
    Duration? startPosition,
    bool? isShuffleMode, 
    bool? isRepeatMode,
    List<Object>? originalTrackQueue,
    bool? inClipEditorMode,
    bool? autoplay,
    int? trackLength,
    String? currentTrackName,
    String? currentTrackArtist,
    String? currentTrackImg,
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
      trackQueue: trackQueue ?? trackQueue,
      domColorLinGradient: domColorLinGradient ?? this.domColorLinGradient,
      inTrackClipPlaybackMode:
          inTrackClipPlaybackMode ?? this.inTrackClipPlaybackMode,
      startPosition: startPosition ?? this.startPosition,
      isShuffleMode: isShuffleMode ?? this.isShuffleMode,
      isRepeatMode: isRepeatMode ?? this.isRepeatMode,
      originalTrackQueue: originalTrackQueue ?? this.originalTrackQueue,
      inClipEditorMode: inClipEditorMode ?? this.inClipEditorMode,
      autoplay: autoplay ?? this.autoplay,
      trackLength: trackLength ?? this.trackLength,
      currentTrackName: currentTrackName ?? this.currentTrackName,
      currentTrackArtist: currentTrackArtist ?? this.currentTrackArtist,
      currentTrackImg: currentTrackImg ?? this.currentTrackImg,
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
      startPosition: newPlaybackState.startPosition,
       isShuffleMode: newPlaybackState.isShuffleMode,
      isRepeatMode: newPlaybackState.isRepeatMode,
      originalTrackQueue: newPlaybackState.originalTrackQueue,
      inClipEditorMode: newPlaybackState.inClipEditorMode,
      autoplay: newPlaybackState.autoplay,
      trackLength: newPlaybackState.trackLength,
      currentTrackName: newPlaybackState.currentTrackName,
      currentTrackArtist: newPlaybackState.currentTrackArtist,
      currentTrackImg: newPlaybackState.currentTrackImg,

    );
  }
}
