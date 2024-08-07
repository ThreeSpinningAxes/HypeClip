import 'dart:async';

class ProgressTimer {
  final Duration interval = Duration(milliseconds: 100);
  late Timer _timer;
  Duration trackLength;
  Duration currentProgress;
  bool trackFinished = false;


  ProgressTimer({required this.trackLength, required this.currentProgress});

  void start() {
    _timer = Timer.periodic(interval, (timer) {
      if (currentProgress.inMilliseconds < trackLength.inMilliseconds) {
         
          currentProgress = Duration(milliseconds: currentProgress.inMilliseconds + 100);
         
      } else {
        timer.cancel();
        trackFinished = true; // Stop the timer if the song ends
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
}