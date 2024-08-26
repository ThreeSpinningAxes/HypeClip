import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Services/UserProfileService.dart';


final trackClipProvider = StateNotifierProvider<TrackClipNotifier, Map<String, TrackClipPlaylist>>((ref) {
  return TrackClipNotifier();
});

class TrackClipNotifier extends StateNotifier<Map<String, TrackClipPlaylist>> {
  TrackClipNotifier() : super(<String, TrackClipPlaylist>{}) {
    _loadClips();
  }

void _loadClips() {
    state = Map<String, TrackClipPlaylist>.from(UserProfileService.getAllTrackClipPlaylists());
  }

Future<void> addClipToPlaylist({String? playlistName, required TrackClip trackClip}) async {
  playlistName ??= TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY;
    if (state.containsKey(playlistName)) {
      await UserProfileService.saveNewTrackClip(trackClip: trackClip, playlistName: playlistName);
      _loadClips();
    } 
  }

  Future<bool> removeClipFromPlaylist({String? playlistName, required TrackClip trackClip}) async {
    playlistName ??= TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY;
    if (state.containsKey(playlistName)) {
      bool success = await UserProfileService.deleteTrackClipFromPlaylist(playlistName, trackClip);
      _loadClips();
      return success;
    } 
    return false; 
  }
  

}