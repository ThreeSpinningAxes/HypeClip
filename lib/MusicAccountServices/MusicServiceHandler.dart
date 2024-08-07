import 'package:http/http.dart';
import 'package:hypeclip/Entities/Playlist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/AppleMusicService.dart';
import 'package:hypeclip/MusicAccountServices/SpotifyService.dart';
import 'package:hypeclip/Entities/Song.dart';

class MusicServiceHandler {
  final SpotifyService spotifyService = SpotifyService();
  final AppleMusicService appleMusicService = AppleMusicService();

  MusicLibraryService service;

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

  void setMusicService(MusicLibraryService service) {
    this.service = service;
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

  Future<Response> isStreaingServiceAppOpen() async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.isSpotifyAppOpenResponse();
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      return Response("Unsopported device", 500);
    }
    return Response("Device not supported", 500);
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

  Future<Response> playTrack( trackURI, {required int position}) async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.playTrack(trackURI, position: position);
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      return Response("Unsopported device", 500);
    }
    return Response("Device not supported", 500);

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

  Future<List<Song>?> getRecentlyPlayedTracks({int limit = 25, int? time}) async {
    if (service == MusicLibraryService.spotify) {
      return await spotifyService.getRecentlyPlayedTracks(limit: limit, time: time);
    } else if (service == MusicLibraryService.appleMusic) {
      //return appleMusicService.refreshAccessToken();
    } else {
      throw Exception("Unsupported service");
    }
    return null;

  }

}
