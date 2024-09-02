import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';



class ProgressTimer extends ChangeNotifier  {
  final Duration interval = Duration(milliseconds: 100);
  Timer? _timer;
  Duration trackLength;
  Duration currentProgress;
  bool trackFinished = false;

  late PlaybackState? playbackState = PlaybackState();
  late PlaybackNotifier? playbackNotifier;


  ProgressTimer({required this.trackLength, required this.currentProgress, this.playbackState, this.playbackNotifier});

  void setPlaybackState(PlaybackState playbackState) {
    this.playbackState = playbackState;
  }

  void setCurrentProgress(Duration currentProgress) {
    this.currentProgress = currentProgress;
    notifyListeners();
  }

  void start({int? seek}) {
    if (seek != null) {
      currentProgress = Duration(milliseconds: seek);
      playbackState!.currentProgress = currentProgress;
    }
    if (currentProgress.inMilliseconds < trackLength.inMilliseconds) {
      trackFinished = false;
    }
    _timer = Timer.periodic(interval, (timer) async {
      if (currentProgress.inMilliseconds < trackLength.inMilliseconds) {         
          currentProgress = Duration(milliseconds: currentProgress.inMilliseconds + 100);
          playbackState!.currentProgress = currentProgress;
          notifyListeners();         
      } else {
          playbackState!.currentProgress = trackLength;
          playbackState!.paused = true; //set early so UI updates faster
          playbackNotifier!.pauseTrack();
          trackFinished = true;
          timer.cancel();
        
        notifyListeners(); // Stop the timer if the song ends
      }
    });
  }

  void stop() {
    _timer!.cancel();
  }


  void resetForNewTrack(Duration newTrackLength) {
    _timer!.cancel();
    trackLength = newTrackLength;
    currentProgress = Duration.zero;
    trackFinished = false;
  }

  bool isActive() {
    if (_timer == null) {
      return false;
    }
    return _timer!.isActive;
  }


}