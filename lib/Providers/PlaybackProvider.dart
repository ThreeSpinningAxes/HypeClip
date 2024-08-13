import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/ProgressTimer.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/Providers/PlaybackState.dart';
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
    String? imageURL = playbackState.currentSong?.albumImage;
    if (imageURL == null) {
      return null;
    }
    final ImageProvider imageProvider = NetworkImage(imageURL);
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    Color? domColor = paletteGenerator.dominantColor?.color;
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
    // Response streamingServiceAppOpen = await musicServiceHandler.isStreaingServiceAppOpen();
    // if (streamingServiceAppOpen.statusCode != 200) {
    //   return streamingServiceAppOpen;
    // }

    // timer = ProgressTimer(
    //     trackLength: playbackState.currentSong!.duration!,
    //     currentProgress: playbackState.currentProgress!);

    Response? r = await musicServiceHandler
        .playTrack(newPlaybackState.currentSong!.trackURI, position: 0);

    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.copyState(newPlaybackState);
      playbackState.paused = false;
      timer.resetForNewTrack(playbackState.currentSong!.duration!);
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
    timer = ProgressTimer(
        trackLength: playbackState.currentSong!.duration!,
        currentProgress: playbackState.currentProgress!, playbackState: playbackState);
      initalized = true;

    timer.addListener(() {
      notifyListeners();
    });
      notifyListeners();
    
  }

    Future<Response> playCurrentTrack(int? seek) async {
      Song song = playbackState.currentSong!;
      Response r = await musicServiceHandler.playTrack(song.trackURI,
          position: seek ?? 0);
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
      Song song = playbackState.currentSong!;
      Response r = await musicServiceHandler.playTrack(song.trackURI,
          position: seek ?? 0);
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

    Future<bool?> pauseSong() async {
      bool? pauseSuccessful = await musicServiceHandler.pausePlayback();
      if (pauseSuccessful == true) {
        playbackState.paused = true;
        timer.stop();
        notifyListeners();
      }
      return pauseSuccessful;
    }

    Future<Response> playNewTrackInList(int index) async {
      if (playbackState.songs == null) {
        return Response('No songs in playlist', 500);
      }
      Song newTrack = playbackState.songs![index];
      Response r = await musicServiceHandler.playTrack(newTrack.trackURI, position: 0);
      if (r.statusCode == 200 || r.statusCode == 204) {
        playbackState.currentSong = newTrack;
        playbackState.currentSongIndex = index;
        playbackState.currentProgress = Duration.zero;
        playbackState.paused = false;
        timer.resetForNewTrack(newTrack.duration!);
        timer.start();
        notifyListeners();
      }
      return r;
    }

    Future<Response> playNextTrack() async {
      if (playbackState.currentSongIndex == playbackState.songs!.length - 1) {
        return await playNewTrackInList(0);
      }
      return await playNewTrackInList(playbackState.currentSongIndex! + 1);
    }

    Future<Response> playPreviousTrack() async {
      if (playbackState.currentSongIndex == 0) {
        return await playNewTrackInList(playbackState.songs!.length - 1);
      }
      return await playNewTrackInList(playbackState.currentSongIndex! - 1);
    }

    @override
  void dispose() {
    // TODO: implement dispose
    this.timer.dispose();
    super.dispose();
  }
}
