import 'package:http/http.dart';
import 'package:hypeclip/Entities/Playlist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/AppleMusicService.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/Entities/Song.dart';

class MusicServiceHandler {
  final SpotifyService spotifyService = SpotifyService();
  final AppleMusicService appleMusicService = AppleMusicService();

  final MusicLibraryService service;

  MusicServiceHandler({required this.service});

  Future<Map<String, dynamic>?> authenticate(
      MusicLibraryService service) async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.authorize();
    } else if (service == MusicLibraryService.appleMusic) {
      return await appleMusicService.authorize();
    } else {
      throw Exception("Unsupported service");
    }
  }

  Future<void> refreshAccessToken() async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.refreshAccessToken();
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported service");
    }
  }

  Future<List<dynamic>?> checkAvailableDevices(
      e) async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.getAvailableDevices();
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported service");
    }
    return null;
  }

  Future<bool?> isStreaingServiceAppOpen() async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.isSpotifyAppOpen();
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported service");
    }
    return null;
  }

  Future<List<dynamic>?> getAvailableDevices(
      ) async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.getAvailableDevices();
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported service");
    }
    return null;
  }

  Future<Response?> playTrack( trackURI, {required int position}) async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.playTrack(trackURI, position: position);
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported service");
    }
    return null;
  }

  Future<bool?> pausePlayback() async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.pausePlayback();
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported service");
    }
    return null;

  }

  Future<List<Song>?> getUserTracks(limit, int offset,) async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.getUserTracks(limit, offset);
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported service");
    }
    return null;
  }

    Future<List<Song>?> getTracksFromPlaylist(Playlist playlist, int limit, int offset,) async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.getTracksFromPlaylist(playlist, limit, offset);
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported service");
    }
    return null;
  }

  Future<List<Playlist>?> getUserPlaylists(int limit, int offset,) async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.getUserPlaylists(limit, offset);
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported service");
    }
    return null;
  }

}
