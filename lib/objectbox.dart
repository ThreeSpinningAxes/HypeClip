import 'dart:ui';

import 'package:hypeclip/Entities/Playlist.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Entities/UserConnectedMusicServiceDB.dart';
import 'package:hypeclip/Entities/UserProfileDB.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/objectbox.g.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spotify_sdk/models/track.dart';

class ObjectBox {
  /// The Store of this app.
  late final Store store;
  late final Box<UserProfileDB> userProfileBox;
  late final Box<UserConnectedMusicService> userConnectedMusicServiceBox;
  late final Box<Playlist> playlistBox;
  late final Box<Song> songBox;
  late final Box<TrackClip> trackClipBox;
  late final Box<TrackClipPlaylist> trackClipPlaylistBox;

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
    userProfileBox = Box<UserProfileDB>(store);
    userConnectedMusicServiceBox = Box<UserConnectedMusicService>(store);
    playlistBox = Box<Playlist>(store);
    songBox = Box<Song>(store);
    trackClipBox = Box<TrackClip>(store);
    trackClipPlaylistBox = Box<TrackClipPlaylist>(store); 
    _initUserProfileBox();
  }

  //Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store =
        await openStore(directory: p.join(docsDir.path, "hypeclip_db"));
    return ObjectBox._create(store);
  }

  Future<void> initDB() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store =
        await openStore(directory: p.join(docsDir.path, "hypeclip_db"));
    _initUserProfileBox();
  }

  void _initUserProfileBox() {
    if (userProfileBox.isEmpty()) {
      // Initialize the UserProfileDB box with default data
      final userProfile = UserProfileDB();
      userProfileBox.put(userProfile);
    }
  }

  void initPlaylists({required MusicLibraryService service}) {
    if (!playlistBox.getAll().any((element) => element.id == "likedTracks")) {
      addNewPlaylistToConnectedService(
          service: service,
          playlistID: "likedTracks",
          playlistName: "Liked Tracks");
    }
    if (!playlistBox
        .getAll()
        .any((element) => element.id == "recentlyPlayed")) {
      addNewPlaylistToConnectedService(
          service: service,
          playlistID: "recentlyPlayed",
          playlistName: "Recently Played");
    }
  }

  void addConnectedMusicService(
      {int? userId,
      required MusicLibraryService service,
      String? accessToken,
      String? refreshToken}) {
    final userProfile =
        userId != null ? userProfileBox.get(userId) : getFirstUser();
    if (userProfile != null) {
      final connectedMusicService = UserConnectedMusicService()
        ..service = service
        ..accessToken = accessToken
        ..refreshToken = refreshToken
        ..connectedUserDB.target = userProfile;

      final likedTracksPlaylist = Playlist(
        id: "likedTracks",
        name: "Liked Tracks",
        imageUrl:
            "https://i.scdn.co/image/ab67706f00000003b3f3f3b3b3f3f3b3b3f3f3b3",
      );

      likedTracksPlaylist.userMusicStreamingServiceAccount.target =
          connectedMusicService;
      connectedMusicService.userPlaylistsDB.add(likedTracksPlaylist);
      playlistBox.put(likedTracksPlaylist);

      userConnectedMusicServiceBox.put(connectedMusicService);
      userProfile.connectedMusicStreamingServices.add(connectedMusicService);
      userProfileBox.put(userProfile);
    } else {
      throw Exception("UserProfile with id $userId not found");
    }
  }

  void deleteMusicService(
      {required MusicLibraryService service, bool? deleteData}) {
    final account = userConnectedMusicServiceBox.getAll().firstWhere(
          (element) => element.service == service,
        );

    final userProfile = account.connectedUserDB.target;

    if (userProfile != null) {
      // Remove the service from the user's connected services
      userProfile.connectedMusicStreamingServices.remove(account);
      userProfileBox.put(userProfile); // Update the user profile in the box
    }

    userConnectedMusicServiceBox.remove(account.id);
  }

  UserProfileDB? getFirstUser() {
    return userProfileBox.getAll().isNotEmpty
        ? userProfileBox.getAll().first
        : null;
  }

  void initLikedSongsPlaylist({required MusicLibraryService service}) {
    addNewPlaylistToConnectedService(
        service: service,
        playlistID: "likedSongs",
        playlistName: "Liked Songs");
  }

  void addNewPlaylistToConnectedService(
      {required MusicLibraryService service,
      required String playlistID,
      required String playlistName,
      int? userId,
      String? imageURL}) {
    if (playlistBox.getAll().any((element) => element.id == playlistID)) {
      return;
      
    }
    final Playlist playlist =
        Playlist(id: playlistID, name: playlistName, imageUrl: imageURL);
    final userProfile =
        userId != null ? userProfileBox.get(userId) : getFirstUser();
    if (userProfile != null) {
      final connectedMusicService = userProfile.connectedMusicStreamingServices
          .firstWhere(
              (element) => element.musicLibraryServiceDB == service.name);
      connectedMusicService.userPlaylistsDB.add(playlist);
      playlist.userMusicStreamingServiceAccount.target = connectedMusicService;
      playlistBox.put(playlist);
    }
  }

  void addNewTrackClipToDB(
      {required TrackClip clip, List<TrackClipPlaylist>? playlists, List<String>? playlistIDs}) {
    clip.linkedSongDB.target = clip.song;

    Song song = clip.song!;
    song.trackClipsDB.add(clip);
    songBox.put(song);

    if (playlists != null) {
      List<TrackClipPlaylist> modifiedPlaylists = playlists.map((playlist) {
        playlist.clipsDB.add(clip);
        clip.linkedPlaylistsDB.add(playlist);
        return playlist;
      }).toList();
      trackClipPlaylistBox.putMany(modifiedPlaylists);
    }

    else if (playlistIDs != null ) {
      List<TrackClipPlaylist> modifiedPlaylists = List.of([]);
      List<TrackClipPlaylist> saveToPlaylists = trackClipPlaylistBox.getAll().where((playlist) => playlistIDs.contains(playlist.playlistID)).toList();
      for (TrackClipPlaylist playlist in saveToPlaylists) {
        playlist.clipsDB.add(clip);
        clip.linkedPlaylistsDB.add(playlist);
        modifiedPlaylists.add(playlist);
      }
      trackClipPlaylistBox.putMany(modifiedPlaylists);
    }

    trackClipBox.put(clip);
  }

  void addNewTrackClipPlaylist(TrackClipPlaylist playlist) {
    if (playlist.clips != null || playlist.clips!.isNotEmpty) {
      List<TrackClip> clips = [];
      for (TrackClip clip in playlist.clips!) {
        clip.linkedPlaylistsDB.add(playlist);
        clips.add(clip);
        playlist.clipsDB.add(clip);
      }
      trackClipBox.putMany(clips);
    }
    trackClipPlaylistBox.put(playlist);
  }

  void deleteTrackClipPlaylist(TrackClipPlaylist playlist) {
      trackClipPlaylistBox.remove(playlist.dbID!);
  }

  void deleteTrackClipFromPlaylist(TrackClip clip, TrackClipPlaylist playlist) {
    playlist.clipsDB.remove(clip);
    playlist.clipsDB.applyToDb();
    playlist.clips!.remove(clip);

  }

  

  void addSongToDB(
      {String? playlistID,
      String? playlistName,
      required String trackid,
      required Duration duration,
      required String trackURI,
      required String artistName,
      required String songName,
      String? songImage,
      String? artistImage,
      Color? songColor,
      required String albumImage,
      String? albumName,
      String? imageURL,
      required MusicLibraryService musicLibraryService}) {
    final song = Song(
      trackID: trackid,
      trackURI: trackURI,
      artistName: artistName,
      songName: songName,
      songImage: songImage,
      artistImage: artistImage,
      songColor: songColor,
      albumImage: albumImage,
      albumName: albumName,
      imageURL: imageURL,
      duration: duration,
      musicLibraryService: musicLibraryService,
    );
    song.musicLibraryServiceDB = musicLibraryService.name;
    song.durationDB = duration.inMilliseconds;

    songBox.put(song);

    if (playlistID != null) {
      playlistBox
          .getAll()
          .firstWhere((element) => element.id == playlistID)
          .songsDB
          .add(song);
      song.playlistDB.add(playlistBox
          .getAll()
          .firstWhere((element) => element.id == playlistID));
    } else if (playlistName != null) {
      playlistBox
          .getAll()
          .firstWhere((element) => element.name == playlistName)
          .songsDB
          .add(song);
      song.playlistDB.add(playlistBox
          .getAll()
          .firstWhere((element) => element.name == playlistName));
    }
  }
}
