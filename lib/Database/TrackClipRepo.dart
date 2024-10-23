

import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/main.dart';

class TrackClipRepo {

  TrackClipRepo._privateConstructor();

  static final TrackClipRepo _instance = TrackClipRepo._privateConstructor();

  factory TrackClipRepo() {
    return _instance;
  }

  void addTrackClip(TrackClip trackClip) async {
    db.trackClipBox.put(trackClip);
  }
  

}