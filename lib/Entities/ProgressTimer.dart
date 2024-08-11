import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hypeclip/Providers/PlaybackState.dart';

class ProgressTimer extends ChangeNotifier  {
  final Duration interval = Duration(milliseconds: 100);
  late Timer _timer;
  Duration trackLength;
  Duration currentProgress;
  bool trackFinished = false;
  late PlaybackState? playbackState = PlaybackState();


  ProgressTimer({required this.trackLength, required this.currentProgress, this.playbackState});

  void setPlaybackState(PlaybackState playbackState) {
    this.playbackState = playbackState;
  }

  void start({int? seek}) {
    if (seek != null) {
      currentProgress = Duration(milliseconds: seek);
    }
    _timer = Timer.periodic(interval, (timer) {
      if (currentProgress.inMilliseconds < trackLength.inMilliseconds) {         
          currentProgress = Duration(milliseconds: currentProgress.inMilliseconds + 100);
          playbackState!.currentProgress = currentProgress;
          notifyListeners();         
      } else {
        timer.cancel();
        trackFinished = true;
        notifyListeners(); // Stop the timer if the song ends
      }
    });
  }

  void stop() {
    _timer.cancel();
  }

  void resetToBeginning() {
    currentProgress = Duration.zero;
    trackFinished = false;
  }

  void seek(Duration seekPosition) {
    // Seek to a specific time
    if (seekPosition.inMilliseconds <= trackLength.inMilliseconds) {
      currentProgress = seekPosition;
    } else {
      currentProgress = trackLength;
      trackFinished = true;
    }
  }

  void resetForNewTrack(Duration newTrackLength) {
    _timer.cancel();
    trackLength = newTrackLength;
    currentProgress = Duration.zero;
    trackFinished = false;
  }

  bool isActive() {
    return _timer.isActive;
  }


}