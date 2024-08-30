import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/ProgressTimer.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:palette_generator/palette_generator.dart';

final playbackProvider = ChangeNotifierProvider(
  (ref) => PlaybackNotifier(),
);

class PlaybackNotifier extends ChangeNotifier {
  bool initalized = false;
  MusicServiceHandler musicServiceHandler =
      MusicServiceHandler(service: MusicLibraryService.spotify);

  PlaybackState playbackState = PlaybackState();
  ProgressTimer timer =
      ProgressTimer(trackLength: Duration.zero, currentProgress: Duration.zero);

  Duration get currentProgress => timer.currentProgress;

  Future<RadialGradient?> setImagePalette() async {
    String? imageURL;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      imageURL = playbackState.currentTrackClip?.song.albumImage;
    } else {
      imageURL = playbackState.currentSong?.albumImage;
    }

    if (imageURL == null) {
      return null;
    }
    final ImageProvider imageProvider = NetworkImage(imageURL);
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider,
            targets: [PaletteTarget(maximumLightness: 0.4)]);
    List<PaletteColor> colors = paletteGenerator.paletteColors;
    Color? domColor;
    for (PaletteColor color in colors) {
      double luminance = color.color.computeLuminance();
      if (luminance < 0.70) {
        domColor = color.color;
        break;
      }
    }
    Color analogousColor;
    if (domColor == null) {
      domColor = Colors.black;
      analogousColor = Colors.grey[300]!;
    } else {
      HSLColor hslColor = HSLColor.fromColor(domColor);
    // Adjust the hue to get an analogous color (e.g., +30 degrees)
    double newHue = (hslColor.hue + 15) % 360;
    analogousColor = hslColor.withHue(newHue).toColor();
    }
   
    RadialGradient radialGradient = RadialGradient(
      center: Alignment.center,
      radius: 1,
      colors: [

        domColor,
        analogousColor
      ],
      
    
    );
    playbackState.domColorLinGradient = radialGradient;
    return radialGradient;
  }

  void init(PlaybackState newPlaybackState) {
    playbackState = playbackState.copyState(newPlaybackState);
    if (playbackState.musicLibraryService != musicServiceHandler.service) {
      musicServiceHandler
          .setMusicService(newPlaybackState.musicLibraryService!);
    }
    Duration trackLength = Duration.zero;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      trackLength = playbackState.currentTrackClip!.clipLength!;
    } else {
      trackLength = playbackState.currentSong!.duration!;
    }
    timer = ProgressTimer(
        trackLength: trackLength,
        currentProgress: playbackState.currentProgress!,
        playbackState: playbackState,
        playbackNotifier: this);
    initalized = true;

    timer.addListener(() {
      notifyListeners();
    });
    notifyListeners();
  }

  Future<Response> playCurrentTrack(int? seek) async {
    Song song;
    int playbackOffset = seek ?? 0;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      if (playbackState.currentTrackClip == null) {
        return Response('No track clip selected', 500);
      }
      song = playbackState.currentTrackClip!.song;
      playbackOffset += playbackState.currentTrackClip!.clipPoints[0].toInt();
    } else {
      if (playbackState.currentSong == null) {
        return Response('No song selected', 500);
      }
      song = playbackState.currentSong!;
    }
    
    Response r =
        await musicServiceHandler.playTrack(song.trackURI, position: playbackOffset);
    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.paused = false;
      
      if (!timer.isActive()) {
        timer.start(seek: seek);
      }
      else {
        timer.currentProgress = Duration(milliseconds: seek ?? timer.currentProgress.inMilliseconds);
      }
    } else {
      playbackState.paused = true;
    }
    notifyListeners();
    return r;
  }

  Future<Response> seekCurrentTrack(int? seek) async {
    Song song;
    int playbackOffset = seek ?? 0;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      song = playbackState.currentTrackClip!.song;
      playbackOffset += playbackState.currentTrackClip!.clipPoints[0].toInt();
    }
    else {
      song = playbackState.currentSong!;
    }
    Response r;
    if (seek != null) {
       r = await musicServiceHandler.playTrack(song.trackURI,
        position: playbackOffset);
    }
    else {
      int position = playbackState.currentProgress!.inMilliseconds;
      if (playbackState.inTrackClipPlaybackMode ?? false) {
        position += playbackOffset;
      }
      r = await musicServiceHandler.playTrack(song.trackURI,
        position: position);
    }
    
    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.paused = false;
      timer.currentProgress = Duration(milliseconds: seek!);
      if (!timer.isActive()) {
        timer.start(seek: seek);
      }
    } else {
      playbackState.paused = true;
      timer.stop();
    }
    notifyListeners();
    return r;
  }

  Future<bool?> pauseTrack() async {
    bool? pauseSuccessful = await musicServiceHandler.pausePlayback();
    Duration currentTime =
        Duration(milliseconds: timer.currentProgress.inMilliseconds);
    if (pauseSuccessful == true) {
      timer.stop();
      playbackState.paused = true;
      playbackState.currentProgress = currentTime;
      notifyListeners();
    }
    return pauseSuccessful;
  }

  Future<Response> playNewTrackInList(int index) async {
    Song? newTrack;
    int trackStartPosition = 0;
    int trackLength = 0;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      if (playbackState.trackClipQueue == null ||
          playbackState.trackClipQueue!.isEmpty) {
        return Response('No track clips in queue', 500);
      }
      newTrack = playbackState.trackClipQueue![index].song;
      trackStartPosition = playbackState.trackClipQueue![index].clipPoints[0].toInt();
      trackLength = (playbackState.trackClipQueue![index].clipPoints[1] -
              playbackState.trackClipQueue![index].clipPoints[0])
          .toInt();
    } else {
      if (playbackState.trackQueue == null || playbackState.trackQueue!.isEmpty) {
        return Response('No songs in queue', 500);
      }
      newTrack = playbackState.trackQueue![index];
      trackLength = newTrack.duration!.inMilliseconds;
    }
    Response r = await musicServiceHandler.playTrack(newTrack.trackURI,
        position: trackStartPosition);
    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.currentSong = newTrack;
      playbackState.currentTrackIndex = index;
      playbackState.currentProgress =
          Duration.zero; //reset progress for new track
      playbackState.paused = false;

      if (playbackState.inTrackClipPlaybackMode ?? false) {
        playbackState.currentTrackClip = playbackState.trackClipQueue![index];
        
      }
      timer.resetForNewTrack(Duration(milliseconds: trackLength));
      timer.start();
      notifyListeners();
    }
    return r;
  }

  

  Future<Response> playNextTrack() async {
    int trackQueueLength = playbackState.inTrackClipPlaybackMode!
        ? playbackState.trackClipQueue!.length
        : playbackState.trackQueue!.length;
    if (trackQueueLength == 1) {
      return await playCurrentTrack(0);
    }
    if (playbackState.currentTrackIndex == trackQueueLength - 1) {
      return await playNewTrackInList(0);
    }
    return await playNewTrackInList(playbackState.currentTrackIndex! + 1);
  }

  Future<Response> playPreviousTrack() async {
    int trackQueueLength = playbackState.inTrackClipPlaybackMode!
        ? playbackState.trackClipQueue!.length
        : playbackState.trackQueue!.length;
     if (trackQueueLength == 1) {
      return await playCurrentTrack(0);
    }
    if (playbackState.currentTrackIndex == 0) {
      return await playNewTrackInList(trackQueueLength - 1);
    }
    return await playNewTrackInList(playbackState.currentTrackIndex! - 1);
  }

  void shuffleQueue() {
    
    playbackState.isShuffleMode = true;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      playbackState.originalTrackQueue = List.from(playbackState.trackClipQueue!);
      playbackState.trackClipQueue?.shuffle();
    } else {
      playbackState.originalTrackQueue = List.from(playbackState.trackQueue!);
      playbackState.trackQueue?.shuffle();
    }
    notifyListeners();
  }

  void undueShuffle() {

    playbackState.isShuffleMode = false;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      playbackState.trackClipQueue = List.from(playbackState.originalTrackQueue!);
    } else {
      playbackState.trackQueue = List.from(playbackState.originalTrackQueue!);
    }
    notifyListeners();
  }

  void addTrackClipToQueue(TrackClip track) {
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      playbackState.trackClipQueue!.add(track);
      notifyListeners();
    }
  }

  void addTrackCLipNextInQueue(TrackClip track) {
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      playbackState.trackClipQueue!.insert(
          playbackState.currentTrackIndex! + 1, track);
      notifyListeners();
    }
  }

  void setPause(bool pause) {
    playbackState.paused = pause;
    notifyListeners();
  }

  void setShuffleMode(bool shuffle) {
    playbackState.isShuffleMode = shuffle;
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    this.timer.dispose();
    super.dispose();
  }
}
