import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/ProgressTimer.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/Providers/PlaybackState.dart';
import 'package:hypeclip/Utilities/ShowErrorDialog.dart';

final playbackProvider = ChangeNotifierProvider(
  (ref) => PlaybackNotifier(),
);

class PlaybackNotifier extends ChangeNotifier {
  PlaybackState playbackState = PlaybackState();
  late MusicServiceHandler musicServiceHandler;

  ProgressTimer timer = ProgressTimer(trackLength: Duration.zero, currentProgress: Duration.zero);

  Future<Response> playNewTrack(PlaybackState newPlaybackState) async {
    


    if (playbackState.musicLibraryService != musicServiceHandler.service) {
      musicServiceHandler.setMusicService(playbackState.musicLibraryService!);
    }
    // Response streamingServiceAppOpen = await musicServiceHandler.isStreaingServiceAppOpen();
    // if (streamingServiceAppOpen.statusCode != 200) {
    //   return streamingServiceAppOpen; 
    // }

    timer = ProgressTimer(
        trackLength: playbackState.currentSong!.duration!,
        currentProgress: playbackState.currentProgress!);

    Response? r = await musicServiceHandler.playTrack(newPlaybackState.currentSong!.trackURI, position: 0);


    if (r.statusCode == 200 || r.statusCode == 204) {
      
      playbackState.copyWith(
      currentProgress: newPlaybackState.currentProgress,
      currentSong: newPlaybackState.currentSong,
      currentSongIndex: newPlaybackState.currentSongIndex,
      paused: newPlaybackState.paused,
      songs: newPlaybackState.songs,
      musicLibraryService: newPlaybackState.musicLibraryService,
      );
      timer.resetForNewTrack(playbackState.currentSong!.duration!);
      timer.start();
      notifyListeners();
      
    }
    
    return r;
    
  }

  Future<Response?> playCurrentTrack(int? seek) async {
    Song song = playbackState.currentSong!;
    Response? r =
        await musicServiceHandler.playTrack(song.trackURI, position: seek ?? 0);
    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.paused = false;
      timer.start();
      notifyListeners();
    }
    
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

  Future<Response> playTrackInList(int index) async {
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
      return await playTrackInList(0);
    }
    return await playTrackInList(playbackState.currentSongIndex! + 1);
  }

  Future<Response> playPreviousTrack() async {
    if (playbackState.currentSongIndex == 0) {
      return await playTrackInList(playbackState.songs!.length - 1);
    }
    return await playTrackInList(playbackState.currentSongIndex! - 1);
  }

  





  



  
}
