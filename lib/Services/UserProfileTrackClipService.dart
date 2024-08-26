import 'dart:async';
import 'dart:convert';

import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/UserProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileTrackClipService {
  static UserProfile userProfile = UserProfile('', '', '');

  static void saveNewTrackClip(TrackClip clip) {
    userProfile.clips.add(clip);
    saveUserTrackClipsToPreferences();
  }

  static Future<void> saveUserTrackClipsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonClips = userProfile.clips.map((clip) => jsonEncode(clip.toJson())).toList();
    await prefs.setStringList('clips', jsonClips);
  }

  static Future<void> loadUserTrackClipsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonClips = prefs.getStringList('clips');
    if (jsonClips != null) {
      userProfile.clips = jsonClips.map((clip) => TrackClip.fromJson(jsonDecode(clip))).toList();
    }
  }

  static Future<List<TrackClip>> getUserTrackClips() async {
    if (userProfile.clips.isEmpty) {
      await loadUserTrackClipsToPreferences();
    }
    return userProfile.clips;
  }

  static Future<void> deleteTrackClip(TrackClip clip) async {
    userProfile.clips.remove(clip);
    saveUserTrackClipsToPreferences();
  }

  static Future<void> deleteAllTrackClips() async {
    userProfile.clips.clear();
    saveUserTrackClipsToPreferences();
  }
}