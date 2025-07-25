import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';

class ProgressTimer extends ChangeNotifier {
  final Duration interval = Duration(milliseconds: 100);
  Timer? _timer;
  Duration trackLength;
  bool trackFinished = false;

  late PlaybackState? playbackState = PlaybackState();
  late PlaybackNotifier? playbackNotifier;

  ProgressTimer(
      {required this.trackLength, this.playbackState, this.playbackNotifier});

  void setPlaybackState(PlaybackState playbackState) {
    this.playbackState = playbackState;
  }

  void start({int? seek}) {
    if (seek != null) {
      playbackNotifier!.playbackState.currentProgress =
          Duration(milliseconds: seek);
    }
    if (playbackNotifier!.playbackState.currentProgress!.inMilliseconds <
        trackLength.inMilliseconds) {
      trackFinished = false;
    }
    _timer = Timer.periodic(interval, (timer) async {
      if (playbackNotifier!.playbackState.currentProgress!.inMilliseconds <
          trackLength.inMilliseconds) {
        playbackNotifier!.playbackState.currentProgress = Duration(
            milliseconds:
                playbackNotifier!.currentProgress.inMilliseconds + 100);
        if (playbackNotifier!.playbackState.inClipEditorMode) {
          await handleClipEditor();
        }
        notifyListeners();
      } else {
        playbackNotifier!.playbackState.currentProgress = trackLength;
        trackFinished = true;
        timer.cancel();
        await handleTrackEnd();

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
    playbackNotifier!.playbackState.currentProgress = Duration.zero;
    trackFinished = false;
  }

  bool isActive() {
    if (_timer == null) {
      return false;
    }
    return _timer!.isActive;
  }

  Future<void> handleTrackEnd() async {
    PlaybackState playbackState = playbackNotifier!.playbackState;
    if (playbackNotifier?.insideEvent ?? false) {
      return;
    }
    playbackNotifier!.insideEvent = true;
    notifyListeners();

    //regular song playback
    if (!playbackState.inClipEditorMode) {
      if (!playbackState.paused!) {
        if (playbackState.isRepeatMode) {
          await playbackNotifier!.seekCurrentTrack(0);
        } else {
          await playbackNotifier!.playNextTrack();
          playbackNotifier!.setImagePalette();
        }
      }
      return;
    } 
    playbackNotifier!.insideEvent = false;
    notifyListeners();
  }

  Future<void> handleClipEditor() async {
    PlaybackState playbackState = playbackNotifier!.playbackState;
    if (playbackNotifier!.playbackState.isSeeking! || playbackNotifier!.insideEvent) {
      return;
    }
    if (!playbackState.isSeeking!) {
      if (playbackState.currentProgress!.inMilliseconds >= playbackState.clipValues![1]) {
        playbackNotifier!.insideEvent = true;
        playbackNotifier!.updatePlaybackState(paused: true, );
        await playbackNotifier!.pauseTrack();
        playbackNotifier!.updatePlaybackState(currentProgress: Duration(milliseconds: playbackState.clipValues![1].toInt()));
        playbackNotifier!.insideEvent = false;
      } 
    }
  }
}
