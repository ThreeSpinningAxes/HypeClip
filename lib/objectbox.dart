import 'package:hypeclip/Entities/BackupConnectedServiceContent.dart';
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
  late final Box<BackupConnectedServiceContent>
      backupConnectedServiceContentBox;

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
    userProfileBox = Box<UserProfileDB>(store);
    userConnectedMusicServiceBox = Box<UserConnectedMusicService>(store);
    playlistBox = Box<Playlist>(store);
    songBox = Box<Song>(store);
    trackClipBox = Box<TrackClip>(store);
    trackClipPlaylistBox = Box<TrackClipPlaylist>(store);
    backupConnectedServiceContentBox =
        Box<BackupConnectedServiceContent>(store);
    _initUserProfileBox();
    _initMusicServices();
    _initRecentlyPlayedTrackClipPlaylist();
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
      //check if service has likedTracks playlist
      addNewPlaylistToConnectedService(
          service: service,
          playlistID: "likedTracks",
          playlistName: "Liked Tracks");
    }
    if (!playlistBox
        .getAll()
        .any((element) => element.id == "recentlyPlayed")) {
      // same for here
      addNewPlaylistToConnectedService(
          service: service,
          playlistID: "recentlyPlayed",
          playlistName: "Recently Played");
    }
  }

  void _initRecentlyPlayedTrackClipPlaylist() {
    if (!trackClipPlaylistBox
        .getAll()
        .any((element) => element.playlistID == "recentlyPlayed")) {
      final playlist = TrackClipPlaylist(
        playlistID: "recentlyPlayed",
        playlistName: TrackClipPlaylist.RECENTLY_LISTENED_KEY,
        clips: [],
        dateCreated: DateTime.now(),
      );
      trackClipPlaylistBox.put(playlist);
    }
  }

  void dbCleanup(
      {required MusicLibraryService service, bool deleteData = false}) {
    List<int> playlistIds = [];
    List<int> trackClipIds = [];
    List<int> songIds = [];
    for (Playlist playlist in playlistBox.getAll()) {
      if (playlist.musicLibraryServiceDB == service.name) {
        playlistIds.add(playlist.dbID!);
      }
    }
    for (TrackClip clip in trackClipBox.getAll()) {
      if (clip.musicLibraryServiceDB == service.name) {
        trackClipIds.add(clip.dbID!);
      }
    }
    for (Song song in songBox.getAll()) {
      if (song.musicLibraryServiceDB == service.name) {
        songIds.add(song.id!);
      }
    }
    playlistBox.removeMany(playlistIds);
    songBox.removeMany(songIds);
    trackClipBox.removeMany(trackClipIds);

    //userConnectedMusicServiceBox.remove(getFirstUser()!.connectedMusicStreamingServices.firstWhere((element) => element.musicLibraryServiceDB == service.name).id);
  }

  void disconnectMusicService(
      {required MusicLibraryService service,
      bool deleteData = false,
      int? userId}) {
    int id = userId ?? getFirstUser()!.id;
    UserConnectedMusicService connectedStreamingService =
        userConnectedMusicServiceBox.getAll().firstWhere((element) =>
            element.service?.name == service.name &&
            element.connectedUserDB.target?.id == id);

    if (deleteData) {
      List<int> playlistIds = [];
      List<int> trackClipIds = [];
      List<int> songIds = [];
      for (Playlist playlist in playlistBox.getAll()) {
        if (playlist.musicLibraryServiceDB == service.name) {
          playlistIds.add(playlist.dbID!);
        }
      }
      for (TrackClip clip in trackClipBox.getAll()) {
        if (clip.musicLibraryServiceDB == service.name) {
          trackClipIds.add(clip.dbID!);
        }
      }
      for (Song song in songBox.getAll()) {
        if (song.musicLibraryServiceDB == service.name) {
          songIds.add(song.id!);
        }
      }
    } else {
      cacheStreamingServiceData(service: service);
    }

    userConnectedMusicServiceBox.remove(connectedStreamingService.id);
  }

  void cacheStreamingServiceData({required MusicLibraryService service}) {
    final userProfile = getFirstUser();
    BackupConnectedServiceContent? backupService =
        backupConnectedServiceContentBox
            .getAll()
            .where((element) =>
                element.musicServiceDB == service.name &&
                element.linkedUser.target!.id == userProfile!.id)
            .firstOrNull;

    if (backupService == null) {
      backupService = BackupConnectedServiceContent();

      backupService.musicServiceDB = service.name;
      backupService.linkedUser.target = userProfile;
      backupConnectedServiceContentBox.put(backupService);
      userProfile!.streamingServiceBackups.add(backupService);
      userProfileBox.put(userProfile);
    }

    UserConnectedMusicService connectedStreamingService =
        userConnectedMusicServiceBox.getAll().firstWhere((element) =>
            element.service?.name == service.name &&
            element.connectedUserDB.target?.id == userProfile!.id);

    for (Playlist playlist in connectedStreamingService.userPlaylistsDB) {
      playlist.backup.target = backupService;
      backupService.cachedPlaylists.add(playlist);
    }
    final songsQuery =
        songBox.query(Song_.musicLibraryServiceDB.equals(service.name)).build();
    final songs = songsQuery.find();
    songsQuery.close();

    for (Song song in songs) {
      song.backup.target = backupService;
      backupService.cachedSongs.add(song);
    }
    final clipsQuery = trackClipBox
        .query(TrackClip_.musicLibraryServiceDB.equals(service.name))
        .build();
    final clips = clipsQuery.find();
    clipsQuery.close();

    for (TrackClip clip in clips) {
      List<TrackClipPlaylist> playlists = [];
      for (TrackClipPlaylist playlist in clip.linkedPlaylistsDB) {
        playlist.clipsDB.removeWhere((element) => element.dbID == clip.dbID);
        playlists.add(playlist);
        clip.linkedTrackClipPlaylistsForCache!.add(playlist.dbID!);
      }
      clip.linkedPlaylistsDB.clear();
      trackClipPlaylistBox.putMany(playlists);
      clip.backup.target = backupService;
      backupService.cachedTrackClips.add(clip);
    }

    backupConnectedServiceContentBox.put(backupService);

    playlistBox.putMany(backupService.cachedPlaylists);
    songBox.putMany(backupService.cachedSongs);
    trackClipBox.putMany(backupService.cachedTrackClips);
  }

  void disconnectMusicServiceCacheData(
      {required MusicLibraryService service, int? userId}) {
    List<int> playlistIds = [];
    List<int> songIds = [];
    List<int> clipIds = [];

    for (Playlist playlist in playlistBox.getAll()) {
      if (playlist.songsDB.isNotEmpty &&
          playlist.songsDB.first.musicLibraryServiceDB == service.name) {
        playlistIds.add(playlist.dbID!);
        for (Song song in playlist.songsDB) {
          songIds.add(song.id!);
          for (TrackClip clip in song.trackClipsDB) {
            clipIds.add(clip.dbID!);
          }
        }
      }
      playlistBox.removeMany(playlistIds);
      songBox.removeMany(songIds);
      trackClipBox.removeMany(clipIds);
    }
  }

  void addConnectedMusicService(
      {int? userId,
      required MusicLibraryService service,
      String? accessToken,
      String? refreshToken,
      bool createDefaultPlaylists = true}) {
    final userProfile =
        userId != null ? userProfileBox.get(userId) : getFirstUser();
    if (userProfile != null) {
      final connectedMusicService = UserConnectedMusicService()
        ..service = service
        ..accessToken = accessToken
        ..refreshToken = refreshToken
        ..connectedUserDB.target = userProfile;

      BackupConnectedServiceContent? backup = backupConnectedServiceContentBox
          .getAll()
          .where((element) =>
              element.musicServiceDB == service.name &&
              element.linkedUser.target!.id == userProfile.id)
          .firstOrNull;
      if (backup != null) {
        List<Playlist> playlists = [];
        List<Song> songs = [];
        List<TrackClip> clips = [];

        for (Playlist playlist in backup.cachedPlaylists) {
          playlist.backup.target = null;
          playlists.add(playlist);
        }
        for (Song song in backup.cachedSongs) {
          song.backup.target = null;
          songs.add(song);
        }
        for (TrackClip clip in backup.cachedTrackClips) {
          List<TrackClipPlaylist> cachedPlaylists = [];
          for (int i = 0;
              i < clip.linkedTrackClipPlaylistsForCache!.length;
              i++) {
            final TrackClipPlaylist? playlist = trackClipPlaylistBox
                .get(clip.linkedTrackClipPlaylistsForCache![i]);
            if (playlist != null) {
              playlist.clipsDB.add(clip);
              clip.linkedPlaylistsDB.add(playlist);
              cachedPlaylists.add(playlist);
            }
          }
          trackClipPlaylistBox.putMany(cachedPlaylists);
          clip.linkedTrackClipPlaylistsForCache?.clear();
          clip.backup.target = null;
          clips.add(clip);
        }
        playlistBox.putMany(playlists);
        songBox.putMany(songs);
        trackClipBox.putMany(clips);
        connectedMusicService.userPlaylistsDB.addAll(playlists);
        backupConnectedServiceContentBox.remove(backup.id);
      }

      userConnectedMusicServiceBox.put(connectedMusicService);
      userProfile.connectedMusicStreamingServices.add(connectedMusicService);
      userProfileBox.put(userProfile);
      if (createDefaultPlaylists) {
        initPlaylists(service: service);
      }
    } else {
      throw Exception("UserProfile with id $userId not found");
    }
  }

  void _initMusicServices({int? userId}) {
    final userProfile =
        userId != null ? userProfileBox.get(userId) : getFirstUser();
    for (UserConnectedMusicService service
        in userProfile!.connectedMusicStreamingServices) {
      // if (service.musicLibraryServiceDB != MusicLibraryService.spotify.name) {
      //   userConnectedMusicServiceBox.remove(service.id);
      // }
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

  void addNewPlaylistToConnectedService(
      {required MusicLibraryService service,
      required String playlistID,
      required String playlistName,
      int? userId,
      String? imageURL}) {
    if (playlistBox.getAll().any((element) => element.id == playlistID)) {
      return;
    }
    final Playlist playlist = Playlist(
        id: playlistID,
        name: playlistName,
        imageUrl: imageURL,
        musicLibraryService: service)
      ..musicLibraryServiceDB = service.name;

    final userProfile =
        userId != null ? userProfileBox.get(userId) : getFirstUser();
    if (userProfile != null) {
      final connectedMusicService = userProfile.connectedMusicStreamingServices
          .firstWhere(
              (element) => element.musicLibraryServiceDB == service.name);
      connectedMusicService.userPlaylistsDB.add(playlist);
      playlist.userMusicStreamingServiceAccount.target = connectedMusicService;
      playlistBox.put(playlist);
      userConnectedMusicServiceBox.put(connectedMusicService);
    }
  }

  void deletePlaylistAndSongs(Playlist playlist) {
    List<int> songIds = [];
    for (Song song in playlist.songsDB) {
      songIds.add(song.id!);
    }
    songBox.removeMany(songIds);
    playlistBox.remove(playlist.dbID!);
  }

  void deleteAllPlaylists() {
    List<int> playlistIds = [];
    List<int> songIds = [];
    for (Playlist playlist in playlistBox.getAll()) {
      playlistIds.add(playlist.dbID!);
      for (Song song in playlist.songsDB) {
        songIds.add(song.id!);
      }
    }
    songBox.removeMany(songIds);
    playlistBox.removeMany(playlistIds);
  }

  void addNewTrackClipToDB(
      {required TrackClip clip,
      List<TrackClipPlaylist>? playlists,
      List<String>? playlistIDs}) {
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
    } else if (playlistIDs != null) {
      List<TrackClipPlaylist> modifiedPlaylists = List.of([]);
      List<TrackClipPlaylist> saveToPlaylists = trackClipPlaylistBox
          .getAll()
          .where((playlist) => playlistIDs.contains(playlist.playlistID))
          .toList();
      for (TrackClipPlaylist playlist in saveToPlaylists) {
        playlist.clipsDB.add(clip);
        clip.linkedPlaylistsDB.add(playlist);
        modifiedPlaylists.add(playlist);
      }
      trackClipPlaylistBox.putMany(modifiedPlaylists);
    }

    trackClipBox.put(clip);
    _logNewTrackclip();
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
    _logNewPlaylist();
  }

  void deleteTrackClipPlaylist(
      {required TrackClipPlaylist playlist, bool deleteClips = false}) {
    if (deleteClips) {
      List<int> idsToDelete = [];

      for (TrackClip clip in playlist.clipsDB) {
        idsToDelete.add(clip.dbID!);
      }
      trackClipBox.removeMany(idsToDelete);
    }
    trackClipPlaylistBox.remove(playlist.dbID!);
  }

  void deleteTrackClipFromPlaylist(TrackClip clip, String playlistName) {
    final playlist = trackClipPlaylistBox
        .query(TrackClipPlaylist_.playlistName.equals(playlistName))
        .build()
        .findFirst()!;
    playlist.clipsDB.removeWhere((element) => element.dbID == clip.dbID);
    playlist.clips?.removeWhere((element) => element.dbID == clip.dbID);
    clip.linkedPlaylistsDB.remove(playlist);
    playlist.clipsDB.applyToDb();
    clip.linkedPlaylistsDB.applyToDb();
  }

  void deleteTrackClip(TrackClip clip) {
    trackClipBox.remove(clip.dbID!);
  }

  void deleteTrackClipFromDB(TrackClip clip) {
    List<int> playlistIds = [];
    for (TrackClipPlaylist playlist in clip.linkedPlaylistsDB) {
      playlist.clipsDB.remove(clip);
      playlistIds.add(playlist.dbID!);
    }
    trackClipPlaylistBox.putMany(clip.linkedPlaylistsDB);
    trackClipBox.remove(clip.dbID!);
  }

  void addTrackClipToPlaylists(
      {required TrackClip clip, required List<String> playlistIDs}) {
    List<TrackClipPlaylist> modifiedPlaylists = List.of([]);
    List<TrackClipPlaylist> saveToPlaylists = trackClipPlaylistBox
        .getAll()
        .where((playlist) => playlistIDs.contains(playlist.playlistID))
        .toList();
    for (TrackClipPlaylist playlist in saveToPlaylists) {
      playlist.clipsDB.add(clip);
      clip.linkedPlaylistsDB.add(playlist);
      modifiedPlaylists.add(playlist);
    }
    trackClipPlaylistBox.putMany(modifiedPlaylists);
  }

  void addTrackClipToRecentlyListened({required TrackClip clip}) {
    final recentlyListenedPlaylist = trackClipPlaylistBox
        .query(TrackClipPlaylist_.playlistName
            .equals(TrackClipPlaylist.RECENTLY_LISTENED_KEY))
        .build()
        .findFirst()!;
    recentlyListenedPlaylist.clipsDB.add(clip);
    clip.linkedPlaylistsDB.add(recentlyListenedPlaylist);
    trackClipPlaylistBox.put(recentlyListenedPlaylist);
    trackClipBox.put(clip);
  }

  void _logNewPlaylist() {
    final allPlaylists = trackClipPlaylistBox.getAll();
    for (var playlist in allPlaylists) {
      print('Playlist Name: ${playlist.playlistName}');
    }
    if (allPlaylists.isNotEmpty) {
      final latestPlaylist = allPlaylists.last;
      print('Latest Playlist Details:');
      print('Playlist ID: ${latestPlaylist.playlistID}');
      print('Playlist Name: ${latestPlaylist.playlistName.toUpperCase()}');
      print('Date Created: ${latestPlaylist.dateCreated}');
      print('Number of Clips: ${latestPlaylist.clipsDB.length}');
    }
  }

  void _logNewTrackclip() {
    final allClips = trackClipBox.getAll();
    for (var clip in allClips) {
      print('Clip Name: ${clip.clipName}');
    }
    if (allClips.isNotEmpty) {
      final latestClip = allClips.last;
      print('Latest Clip Details:');
      print('Clip ID: ${latestClip.dbID}');
      print('Clip Name: ${latestClip.clipName.toUpperCase()}');
      print('Date Created: ${latestClip.dateCreated}');
      print('Clip Duration: ${latestClip.clipLength}');
    }
  }
}
