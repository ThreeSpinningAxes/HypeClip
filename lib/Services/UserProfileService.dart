import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Entities/UserProfile.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/OnBoarding/UserProfileFireStoreService.dart';
import 'package:hypeclip/OnBoarding/widgets/Auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  static UserProfile userProfile = UserProfile('', '', '');

  static FlutterSecureStorage storage = FlutterSecureStorage();

  static String _connectedMusicServicesKey = 'connectedMusicServices';

  static Future<bool> initUserFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userProfile.ID = user.uid;
      userProfile.email = user.email;
      userProfile.isLoggedIn = true;
      userProfile.username = user.displayName ?? '';

      await initUserMusicData();

      return true;
    }

    return false;
  }

  static Future<void> initUserMusicData(
      {bool fetchDataFromFirebase = false}) async {
    await UserProfileService.initMusicServicesForStorage();
    if (fetchDataFromFirebase) {
      await UserProfileService
          .fetchAndStoreConnectedMusicLibrariesFromFireStore();
    }
    await UserProfileService.loadUserTrackClipPlaylistsFromPreferences();
  }

  static Future<void> initNewUser(
      String id, String username, String email, bool isLoggedIn) async {
    setUser(id, username, email, isLoggedIn);
    await initMusicServicesForStorage();
    await loadUserTrackClipPlaylistsFromPreferences();
  }

  static void setUser(
      String id, String username, String email, bool isLoggedIn) {
    //print('user now:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
    userProfile.setID = id;
    userProfile.setUsername = username;
    userProfile.setEmail = email;
    userProfile.setLoggedIn = isLoggedIn;
    //print('user now after logging in:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
  }

  static void login(String id, String username, String email) {
    userProfile.setID = id;
    userProfile.setUsername = username;
    userProfile.setEmail = email;
    userProfile.setLoggedIn = true;
    UserProfileService.initMusicServicesForStorage();
  }

  static Set<MusicLibraryService> getConnectedMusicLibraries() {
    print(userProfile.connectedMusicServices);
    print("id${userProfile.ID}");
    return userProfile.connectedMusicServices;
  }

  static String? getUID() {
    return userProfile.ID;
  }

  static Future<void> logout() async {
    print(
        'user now:${userProfile.ID}${userProfile.username}${userProfile.email}${userProfile.isLoggedIn}');
    userProfile.setID = '';
    userProfile.setUsername = '';
    userProfile.setEmail = '';
    userProfile.setLoggedIn = false;
    await storage.deleteAll();
    userProfile.connectedMusicServices.clear();
    Auth().signOut();
    //print('user now after logging out:${user.ID}${user.username}${user.email}${user.isLoggedIn}');
  }

  //Implememt this function in different areas involving logging in for the first time, logging out, user signs into different accout etc.
  static Future<void> initMusicServicesForStorage() async {
    if (!await storage.containsKey(key: _connectedMusicServicesKey)) {
      storage.write(key: _connectedMusicServicesKey, value: jsonEncode({}));
    }
  }

  static Future<void>
      fetchAndStoreConnectedMusicLibrariesFromFireStore() async {
    UserProfileFireStoreService()
        .getConnectedMusicLibraries(userProfile.ID!)
        .then((connectedMusicLibraries) async {
      if (connectedMusicLibraries != null) {
        for (String key in connectedMusicLibraries.keys) {
          MusicLibraryService service = MusicLibraryService.values
              .firstWhere((element) => element.name == key);
          await addMusicService(service, connectedMusicLibraries[key]);
        }
      }
    });
  }

  static Future<void> addMusicService(
      MusicLibraryService musicService, Map<String, dynamic> data) async {
    //remove service if already connected
    // FlutterSecureStorage storage = FlutterSecureStorage();
    // user.connectedMusicLibraries[service] = storage;
    // for (String key in data.keys) {
    //   await storage.write(key: key, value: data[key.toString()].toString());
    // }

    // store to user object
    String service = musicService.name;
    userProfile.connectedMusicServices.add(musicService);

    //store to secure storage

    String? connectedMusicServicesJsonEncoded =
        await storage.read(key: _connectedMusicServicesKey);
    print(connectedMusicServicesJsonEncoded);
    Map<String, dynamic> connectedMusicServices =
        jsonDecode(connectedMusicServicesJsonEncoded!);
    connectedMusicServices[service] = data;
    await storage.write(
        key: _connectedMusicServicesKey,
        value: jsonEncode(connectedMusicServices));
  }

  static Future<void> deleteMusicService(
      MusicLibraryService musicService) async {
    String service = musicService.name;
    userProfile.connectedMusicServices.remove(musicService);
    String? connectedMusicServicesJsonEncoded =
        await storage.read(key: _connectedMusicServicesKey);
    Map<String, dynamic> connectedMusicServices =
        jsonDecode(connectedMusicServicesJsonEncoded!);
    if (connectedMusicServices[service] != null) {
      connectedMusicServices.remove(service);
      await storage.write(
          key: _connectedMusicServicesKey,
          value: jsonEncode(connectedMusicServices));
    }
  }

  static Future<Map<String, dynamic>?> getMusicServiceData(
      MusicLibraryService service) async {
    String? data = await storage.read(key: _connectedMusicServicesKey);
    Map<String, dynamic> storedData = jsonDecode(data!);
    if (storedData.containsKey(service.name)) {
      return storedData[service.name];
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAllConnectedMusicServiceData() async {
    String? data = await storage.read(key: _connectedMusicServicesKey);
    Map<String, dynamic> storedData = jsonDecode(data!);
    return storedData;
  }

  static Future<void> setMusicServiceData(
      MusicLibraryService service, Map<String, dynamic> data) async {
    Map<String, dynamic>? storedData = await getAllConnectedMusicServiceData();
    if (storedData![service.name] != null) {
      storedData[service.name].addAll(data);
      await storage.write(
          key: _connectedMusicServicesKey, value: jsonEncode(storedData));
    }
  }

  static Future<void> setMusicServiceDataProperty(
      MusicLibraryService service, String key, dynamic value) async {
    Map<String, dynamic>? storedData = await getMusicServiceData(service);
    if (storedData != null) {
      storedData[key] = value;
      await storage.write(key: service.name, value: jsonEncode(storedData));
    }
  }

  static bool hasMusicService(MusicLibraryService service) {
    return userProfile.connectedMusicServices.contains(service);
    // String? data = await storage.read(key: _connectedMusicServicesKey);
    // Map<String, dynamic> storedData = jsonDecode(data!);
    // return storedData.containsKey(service.name);
  }

  static Future<void> saveNewTrackClip(
      {String? playlistName, required TrackClip trackClip}) async {
    if (playlistName == null) {
      userProfile.playlists[TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY]!.clips
          .add(trackClip);
    } else {
      userProfile.playlists[playlistName]!.clips.add(trackClip);
    }
    await saveUserTrackClipPlaylistToPreferencs();
  }

// OPTIMIZE SO THAT YOU DONT HAVE TO REWRITE THE ENTIRE PLAYLIST TO PREFERENCES EVERY UPDATE. USE ID OF PLAYLISTS
  static Future<void> saveUserTrackClipPlaylistToPreferencs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> jsonPlaylists = userProfile.playlists
        .map((key, playlist) => MapEntry(key, jsonEncode(playlist.toJson())));
    await prefs.setString('playlists', jsonEncode(jsonPlaylists));
  }

  static Future<void> loadUserTrackClipPlaylistsFromPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('playlists');
    if (jsonString != null) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      userProfile.playlists = jsonMap.map((key, playlistJson) =>
          MapEntry(key, TrackClipPlaylist.fromJson(jsonDecode(playlistJson))));
    }
    userProfile.loadedTrackClips = true;
  }

  static TrackClipPlaylist? getTrackClipPlaylist(
      {required String playlistName}) {
    if (userProfile.playlists.containsKey(playlistName)) {
      return userProfile.playlists[playlistName]!;
    }
    return null;
  }

  static Map<String, TrackClipPlaylist> getAllTrackClipPlaylists() {
    return userProfile.playlists;
  }

  static Future<bool> deleteTrackClipFromPlaylist(
    String playlistName,
    TrackClip clip,
  ) async {
    if (userProfile.playlists.containsKey(playlistName)) {
      userProfile.playlists[playlistName]!.removeClip(clip);
      await saveUserTrackClipPlaylistToPreferencs();
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> deleteAllTrackClipsInPlaylist(String playlistName) async {
    if (userProfile.playlists.containsKey(playlistName)) {
      userProfile.playlists[playlistName]!.clips.clear();
      await saveUserTrackClipPlaylistToPreferencs();
      return true;
    }
    return false;
  }
}
