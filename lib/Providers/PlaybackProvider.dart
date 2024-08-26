import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/ProgressTimer.dart';
import 'package:hypeclip/Entities/Song.dart';
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

  Future<LinearGradient?> setImagePalette() async {
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

    LinearGradient linearGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        domColor?.withOpacity(0.33) ?? Colors.black.withOpacity(0.1),
        domColor?.withOpacity(0.66) ?? Colors.black.withOpacity(0.3),
        domColor ?? Colors.black,
        domColor?.withOpacity(0.66) ?? Colors.black.withOpacity(0.7),
        domColor?.withOpacity(0.33) ?? Colors.black.withOpacity(0.3),
        Colors.transparent,
      ],
      stops: [
        0.0,
        0.175,
        0.3125,
        0.5,
        0.6875,
        0.825,
        1.0,
      ],
    );
    playbackState.domColorLinGradient = linearGradient;
    return linearGradient;
  }

  Future<Response> playNewTrack(PlaybackState newPlaybackState) async {
    if (initalized &&
        playbackState.musicLibraryService != musicServiceHandler.service) {
      musicServiceHandler.setMusicService(playbackState.musicLibraryService!);
    }

    int trackStartPosition = 0;
    Duration trackDuration = Duration.zero;
    String trackURI = "";
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      trackStartPosition =
          playbackState.currentTrackClip!.clipPoints[0].toInt();
      trackDuration = Duration(
          milliseconds: (playbackState.currentTrackClip!.clipPoints[1] -
                  playbackState.currentTrackClip!.clipPoints[0])
              .toInt());
      trackURI = playbackState.currentTrackClip!.song.trackURI;
    } else {
      trackDuration = newPlaybackState.currentSong!.duration!;
      trackURI = newPlaybackState.currentSong!.trackURI;
    }

    Response? r = await musicServiceHandler.playTrack(trackURI,
        position: trackStartPosition);

    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.copyState(newPlaybackState);
      playbackState.paused = false;
      timer.resetForNewTrack(trackDuration);
      timer.start();
    } else {
      playbackState.paused = false;
    }
    notifyListeners();

    return r;
  }

  void init(PlaybackState newPlaybackState) {
    playbackState = playbackState.copyState(newPlaybackState);
    if (playbackState.musicLibraryService != musicServiceHandler.service) {
      musicServiceHandler
          .setMusicService(newPlaybackState.musicLibraryService!);
    }
    Duration trackLength = Duration.zero;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      trackLength = Duration(
          milliseconds: (playbackState.currentTrackClip!.clipPoints[1] -
                  playbackState.currentTrackClip!.clipPoints[0])
              .toInt());
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
    int startPosition = 0;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      if (playbackState.currentTrackClip == null) {
        return Response('No track clip selected', 500);
      }
      song = playbackState.currentTrackClip!.song;
      startPosition = playbackState.currentTrackClip!.clipPoints[0].toInt();
    } else {
      if (playbackState.currentSong == null) {
        return Response('No song selected', 500);
      }
      song = playbackState.currentSong!;
    }

    Response r =
        await musicServiceHandler.playTrack(song.trackURI, position: seek ?? startPosition);
    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.paused = false;
      timer.start(seek: seek);
    } else {
      playbackState.paused = true;
    }
    notifyListeners();
    return r;
  }

  Future<Response> seekCurrentTrack(int? seek) async {
    Song song = playbackState.inTrackClipPlaybackMode!
        ? playbackState.currentTrackClip!.song
        : playbackState.currentSong!;
    int trackStartPosition = playbackState.inTrackClipPlaybackMode!
        ? playbackState.currentTrackClip!.clipPoints[0].toInt()
        : 0;
    Response r = await musicServiceHandler.playTrack(song.trackURI,
        position: seek ?? trackStartPosition);
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
      if (playbackState.songs == null) {
        return Response('No songs in playlist', 500);
      }
      newTrack = playbackState.songs![index];
      trackLength = newTrack.duration!.inMilliseconds;
    }
    Response r = await musicServiceHandler.playTrack(newTrack.trackURI,
        position: trackStartPosition);
    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.currentSong = newTrack;
      playbackState.currentTrackIndex = index;
      playbackState.currentProgress =
          Duration(milliseconds: trackStartPosition);
      playbackState.paused = false;
      timer.resetForNewTrack(Duration(milliseconds: trackLength));
      timer.start();
      notifyListeners();
    }
    return r;
  }

  Future<Response> playNextTrack() async {
    int trackQueueLength = playbackState.inTrackClipPlaybackMode!
        ? playbackState.trackClipQueue!.length
        : playbackState.songs!.length;
    if (playbackState.currentTrackIndex == trackQueueLength - 1) {
      return await playNewTrackInList(0);
    }
    return await playNewTrackInList(playbackState.currentTrackIndex! + 1);
  }

  Future<Response> playPreviousTrack() async {
    int trackQueueLength = playbackState.inTrackClipPlaybackMode!
        ? playbackState.trackClipQueue!.length
        : playbackState.songs!.length;
    if (playbackState.currentTrackIndex == 0) {
      return await playNewTrackInList(trackQueueLength - 1);
    }
    return await playNewTrackInList(playbackState.currentTrackIndex! - 1);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    this.timer.dispose();
    super.dispose();
  }
}
