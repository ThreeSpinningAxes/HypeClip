import "package:hypeclip/Entities/TrackClip.dart";
import "package:hypeclip/Entities/TrackClipPlaylist.dart";
import "package:hypeclip/Enums/MusicLibraryServices.dart";


class UserProfile {
  String? username;


  String? ID;

  String? email;

  bool isLoggedIn = false;

  //check if you loaded the track clips from the shared preferences
  bool loadedTrackClips = false;

  Set<MusicLibraryService> connectedMusicServices = {};

  List<TrackClip> clips = [];

  Map<String, TrackClipPlaylist> playlists = {
    TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY: TrackClipPlaylist(
        playlistName: "Saved Clips",
        clips: <TrackClip>[],),
    TrackClipPlaylist.RECENTLY_LISTENED_KEY: TrackClipPlaylist(
        playlistName: "Recently Listened Clips",
        clips: <TrackClip>[],),
  };

  UserProfile(this.username, this.ID, this.email);

// Getters
  String? get getUsername => username;
  String? get getID => ID;
  String? get getEmail => email;
  bool get getLoggedIn => isLoggedIn;
  Set<MusicLibraryService> get getConnectedMusicServices =>
      connectedMusicServices;
  List<TrackClip> get getClips => clips;
  TrackClipPlaylist get getRecentlyListenedPlaylist =>
      playlists[TrackClipPlaylist.RECENTLY_LISTENED_KEY]!;
  bool get getLoadedTrackClips => loadedTrackClips;
// Setters
  set setUsername(String value) => username = value;
  set setID(String value) => ID = value;
  set setEmail(String value) => email = value;
  set setLoggedIn(bool value) => isLoggedIn = value;
  set setConnectedMusicServices(Set<MusicLibraryService> value) =>
      connectedMusicServices = value;
  set setClips(List<TrackClip> value) => clips = value;
  set setPlaylists(Map<String, TrackClipPlaylist> value) => playlists = value;
  set setRecentlyListenedPlaylist(TrackClipPlaylist value) =>
    playlists[TrackClipPlaylist.RECENTLY_LISTENED_KEY] = value;

  set setLoadedTrackClips(bool value) => loadedTrackClips = value;
}
