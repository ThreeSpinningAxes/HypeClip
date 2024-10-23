import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Providers/PlaybackProvider.dart';
import 'package:hypeclip/Services/UserProfileService.dart';


final trackClipProvider = StateNotifierProvider<TrackClipNotifier, Map<String, TrackClipPlaylist>>((ref) {
  return TrackClipNotifier();
});

class TrackClipNotifier extends StateNotifier<Map<String, TrackClipPlaylist>> {
  TrackClipNotifier() : super(<String, TrackClipPlaylist>{}) {
    updateClips();
  }

void updateClips() {
    state = Map<String, TrackClipPlaylist>.from(UserProfileService.getAllTrackClipPlaylists());
  }

Future<void> addClipToPlaylist({String? playlistName, required TrackClip trackClip, bool? save}) async {
  playlistName ??= TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY;
    if (state.containsKey(playlistName)) {
      await UserProfileService.saveNewTrackClip(trackClip: trackClip, playlistName: playlistName, save: save);
      updateClips();
    } 
  }

  Future<bool> removeClipFromPlaylist({String? playlistName, required TrackClip trackClip, WidgetRef? playbackRef}) async {
    playlistName ??= TrackClipPlaylist.SAVED_CLIPS_PLAYLIST_KEY;
    if (state.containsKey(playlistName)) {
      bool success = await UserProfileService.deleteTrackClipFromPlaylist(playlistName, trackClip);
      if (playbackRef != null) {
        playbackRef.read(playbackProvider).removeTrackClipFromQueue(trackClip);
      } 
      updateClips();
      return success;
    }
    else {
      return false;
    } 
  }
  

  Future<void> addNewPlaylist({required TrackClipPlaylist playlist}) async {
    await UserProfileService.addNewTrackClipPlaylist(playlist: playlist);
    updateClips();
  }

  Future<void> deletePlaylist({required String playlistName, bool? keepClips}) async {
    await UserProfileService.deletePlaylist(playlist: playlistName, keepClips: keepClips);
    updateClips();
  }

  Future<TrackClipPlaylist?> getRecentlyListenedToTracks() async {
    return UserProfileService.getTrackClipPlaylist(playlistName: TrackClipPlaylist.RECENTLY_LISTENED_KEY);
  }

  Future<void> appendRecentlyListenedToTrack(TrackClip clip) async {
    //await UserProfileService.addNewTrackClipPlaylist(playlist: TrackClipPlaylist(playlistName: TrackClipPlaylist.RECENTLY_LISTENED_KEY, clips: []));
    await UserProfileService.addToRecentlyListenedPlaylist(clip: clip, save: true);
    updateClips();
  }
  

}