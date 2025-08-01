import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:hypeclip/Entities/ProgressTimer.dart';
import 'package:hypeclip/Entities/Song.dart';
import 'package:hypeclip/Entities/TrackClip.dart';
import 'package:hypeclip/Entities/TrackClipPlaylist.dart';
import 'package:hypeclip/Enums/MusicLibraryServices.dart';
import 'package:hypeclip/MusicAccountServices/MusicServiceHandler.dart';
import 'package:hypeclip/Entities/PlaybackState.dart';
import 'package:hypeclip/main.dart';
import 'package:palette_generator/palette_generator.dart';

final playbackProvider = ChangeNotifierProvider(
  (ref) => PlaybackNotifier(),
);

class PlaybackNotifier extends ChangeNotifier {
  bool initalized = false;
  MusicServiceHandler musicServiceHandler =
      MusicServiceHandler(service: MusicLibraryService.spotify);

  PlaybackState playbackState = PlaybackState();
  ProgressTimer timer = ProgressTimer(
    trackLength: Duration.zero,
  );

  Duration get currentProgress => playbackState.currentProgress!;
  bool _insideEvent = false;

  bool get insideEvent => _insideEvent;

  set insideEvent(bool value) {
    _insideEvent = value;
    notifyListeners();
  }

  Future<RadialGradient?> setImagePalette() async {
    String? imageURL;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      imageURL = playbackState.currentTrackClip?.linkedSongDB.target!.albumImage;
    } else {
      imageURL = playbackState.currentSong?.albumImage;
    }

    if (imageURL == null) {
      return null;
    }
    final ImageProvider imageProvider = NetworkImage(imageURL);
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider,
            targets: [PaletteTarget(maximumLightness: 0.4)]);
    List<PaletteColor> colors = paletteGenerator.paletteColors;
    Color? domColor;
    for (PaletteColor color in colors) {
      double luminance = color.color.computeLuminance();
      if (luminance < 0.70) {
        domColor = color.color;
        break;
      }
    }
    Color analogousColor;
    if (domColor == null) {
      domColor = Colors.black;
      analogousColor = Colors.grey[300]!;
    } else {
      HSLColor hslColor = HSLColor.fromColor(domColor);
      // Adjust the hue to get an analogous color (e.g., +15 degrees)
      double newHue = (hslColor.hue + 15) % 360;
      analogousColor = hslColor.withHue(newHue).toColor();
    }

    // Convert to HSL and decrease lightness to make colors darker
    HSLColor hslDomColor = HSLColor.fromColor(domColor).withLightness(
        (HSLColor.fromColor(domColor).lightness * 0.7).clamp(0.0, 1.0));
    HSLColor hslAnalogousColor = HSLColor.fromColor(analogousColor)
        .withLightness((HSLColor.fromColor(analogousColor).lightness * 0.7)
            .clamp(0.0, 1.0));

    RadialGradient radialGradient = RadialGradient(
      center: Alignment.center,
      radius: 1,
      colors: [
        hslDomColor.toColor(),
        hslAnalogousColor.toColor(),
      ],
    );
    playbackState.domColorLinGradient = radialGradient;
    notifyListeners();
    return radialGradient;
  }

  void update() {
    notifyListeners();
  }

  void reorderQueue(bool trackClipQueue, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (trackClipQueue) {
      final item = playbackState.trackClipQueue!.removeAt(oldIndex);
      playbackState.trackClipQueue!.insert(newIndex, item);
    } else {
      final item = playbackState.trackQueue!.removeAt(oldIndex);
      playbackState.trackQueue!.insert(newIndex, item);
    }
    if (oldIndex == playbackState.currentTrackIndex) {
      playbackState.currentTrackIndex = newIndex;
    } else if (oldIndex < playbackState.currentTrackIndex! &&
        newIndex >= playbackState.currentTrackIndex!) {
      playbackState.currentTrackIndex = playbackState.currentTrackIndex! - 1;
    } else if (oldIndex > playbackState.currentTrackIndex! &&
        newIndex <= playbackState.currentTrackIndex!) {
      playbackState.currentTrackIndex = playbackState.currentTrackIndex! + 1;
    }
    notifyListeners();
  }

  Future<void> removeItemFromQueue(int index) async {
    List queue = playbackState.inTrackClipPlaybackMode!
        ? playbackState.trackClipQueue!
        : playbackState.trackQueue!;

    if (queue.length > 1) {
      if (playbackState.currentTrackIndex! == index) {
        if (playbackState.currentTrackIndex == queue.length - 1) {
          queue.removeAt(index);
          index = 0;
          playbackState.currentTrackIndex = 0;
        } else {
          queue.removeAt(index);
        }

        playNewTrackInList(index, autoplay: true);
      } else {
        queue.removeAt(index);
        if (index < playbackState.currentTrackIndex!) {
          playbackState.currentTrackIndex =
              playbackState.currentTrackIndex! - 1;
        }
      }
    } else {
      playbackState.currentSong = null;
      playbackState.currentTrackClip = null;
      playbackState.currentTrackIndex = 0;
      playbackState.currentProgress = Duration.zero;
      playbackState.paused = true;
      timer.stop();
      pauseTrack();
      queue.clear();
    }

    notifyListeners();
  }

  void removeTrackClipFromQueue(TrackClip track) async {
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      if (playbackState.currentTrackClip == track) {
        pauseTrack();
        if (playbackState.trackClipQueue!.length > 1) {
          await playNewTrackInList(playbackState.currentTrackIndex! + 1,
              autoplay: false);
          playbackState.currentTrackIndex =
              playbackState.currentTrackIndex! - 1;
        } else {
          playbackState.currentSong = null;
          playbackState.currentTrackIndex = 0;
          playbackState.currentProgress = Duration.zero;
          playbackState.paused = true;
          timer.stop();
        }
      }
      playbackState.trackClipQueue!.removeWhere((item) => item.ID == track.ID);
      playbackState.originalTrackQueue!.removeWhere((item) => (item as TrackClip).ID == track.ID);
      notifyListeners();
    }
  }

  void init(PlaybackState newPlaybackState) {
    Object? prevTrack =
        playbackState.currentSong ?? playbackState.currentTrackClip;

    playbackState = playbackState.copyState(newPlaybackState);

    if (playbackState.musicLibraryService != musicServiceHandler.service) {
      musicServiceHandler
          .setMusicService(newPlaybackState.musicLibraryService!);
    }
    Duration trackLength = Duration.zero;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      trackLength = playbackState.currentTrackClip!.clipLength!;
      playbackState.currentTrackName = playbackState.currentTrackClip!.clipName;
      playbackState.currentTrackArtist =
          playbackState.currentTrackClip!.linkedSongDB.target!.artistName;
      playbackState.currentTrackImg =
          playbackState.currentTrackClip!.linkedSongDB.target!.albumImage;
    } else {
      trackLength = playbackState.currentSong!.duration!;
      playbackState.currentTrackName = playbackState.currentSong!.songName;
      playbackState.currentTrackArtist = playbackState.currentSong!.artistName;
      playbackState.currentTrackImg = playbackState.currentSong!.albumImage;
    }
    if (timer.isActive()) {
      timer.stop();
    }
    timer = ProgressTimer(
        trackLength: trackLength,
        playbackState: playbackState,
        playbackNotifier: this);
    initalized = true;

    playbackState.trackLength = trackLength.inMilliseconds;

    if (playbackState.domColorLinGradient == null ||
        prevTrack != playbackState.currentSong ||
        prevTrack != playbackState.currentTrackClip) {
      setImagePalette();
    }

    timer.addListener(() {
      notifyListeners();
    });
    notifyListeners();
  }

  Future<Response> playTrackAfterInit() async {
    return await playCurrentTrack(0);
  }

  void reset() {
    playbackState = PlaybackState();
    timer.stop();
    notifyListeners();
  }

  Future<Response> playCurrentTrack(int? seek) async {
    Song song;
    int playbackOffset = seek ?? 0;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      if (playbackState.currentTrackClip == null) {
        return Response('No track clip selected', 500);
      }
      song = playbackState.currentTrackClip!.linkedSongDB.target!;
      playbackOffset += playbackState.currentTrackClip!.clipPoints[0].toInt();
    } else {
      if (playbackState.currentSong == null) {
        return Response('No song selected', 500);
      }
      song = playbackState.currentSong!;
    }

    Response r = await musicServiceHandler.playTrack(song.trackURI,
        position: playbackOffset);
    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.paused = false;

      if (!timer.isActive()) {
        timer.start(seek: seek);
      } else {
        playbackState.currentProgress = Duration(
            milliseconds:
                seek ?? playbackState.currentProgress!.inMilliseconds);
      }
    } else {
      playbackState.paused = true;
    }
    notifyListeners();
    return r;
  }

  Future<Response> seekCurrentTrack(int seek) async {
    Song song;
    int playbackOffset = seek;
    Duration oldPosition = playbackState.currentProgress!;
    playbackState.isSeeking = true;

    //change the seek value on the bar, revert it if the seek failed
    playbackState.currentProgress = Duration(milliseconds: seek);
    timer.stop();
    notifyListeners();

    if (playbackState.inTrackClipPlaybackMode ?? false) {
      song = playbackState.currentTrackClip!.linkedSongDB.target!;
      playbackOffset += playbackState.currentTrackClip!.clipPoints[0].toInt();
    } else {
      song = playbackState.currentSong!;
    }
    Response r;
    r = await musicServiceHandler.playTrack(song.trackURI,
        position: playbackOffset);

    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.paused = false;

      playbackState.currentProgress = Duration(milliseconds: seek);
      if (!timer.isActive()) {
        timer.start(seek: seek);
      }
    } else {
      playbackState.paused = true;
      timer.stop();
      playbackState.currentProgress = oldPosition;
    }
    playbackState.isSeeking = false;
    notifyListeners();
    return r;
  }

  Future<bool?> pauseTrack() async {
    timer.stop();
    bool? pauseSuccessful = await musicServiceHandler.pausePlayback();
    Duration currentTime =
        Duration(milliseconds: playbackState.currentProgress!.inMilliseconds);
    if (pauseSuccessful == true) {
      //timer.stop();
      playbackState.paused = true;
      playbackState.currentProgress = currentTime;
      notifyListeners();
    }
    return pauseSuccessful;
  }

  bool inEvent() {
    return _insideEvent;
  }

  Future<Response> playNewTrackInList(int index,
      {bool? autoplay, bool updateGradient = false}) async {
    Song? newTrack;
    int trackStartPosition = 0;
    int trackLength = 0;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      if (playbackState.trackClipQueue == null ||
          playbackState.trackClipQueue!.isEmpty) {
        return Response('No track clips in queue', 500);
      }
      newTrack = playbackState.trackClipQueue![index].linkedSongDB.target;
      trackStartPosition =
          playbackState.trackClipQueue![index].clipPoints[0].toInt();
      trackLength = (playbackState.trackClipQueue![index].clipPoints[1] -
              playbackState.trackClipQueue![index].clipPoints[0])
          .toInt();
    } else {
      if (playbackState.trackQueue == null ||
          playbackState.trackQueue!.isEmpty) {
        return Response('No songs in queue', 500);
      }
      newTrack = playbackState.trackQueue![index];
      trackLength = newTrack.duration!.inMilliseconds;
    }
    if (autoplay ?? playbackState.autoplay) {
      Response r = await musicServiceHandler.playTrack(newTrack!.trackURI,
          position: trackStartPosition);
      if (r.statusCode == 200 || r.statusCode == 204) {
        playbackState.currentProgress =
            Duration.zero; //reset progress for new track
        playbackState.trackLength = trackLength;
        timer.resetForNewTrack(Duration(milliseconds: trackLength));
        timer.start();
        if (playbackState.inTrackClipPlaybackMode ?? false) {
          playbackState.currentTrackClip = playbackState.trackClipQueue![index];
          playbackState.currentSong = playbackState.trackClipQueue![index].linkedSongDB.target;
          playbackState.currentTrackName =
              playbackState.trackClipQueue![index].clipName;
          playbackState.currentTrackArtist =
              playbackState.trackClipQueue![index].linkedSongDB.target!.artistName;
          playbackState.currentTrackImg =
              playbackState.trackClipQueue![index].linkedSongDB.target!.albumImage;
        } else {
          playbackState.currentSong = playbackState.trackQueue![index];
          playbackState.currentTrackName =
              playbackState.trackQueue![index].songName;
          playbackState.currentTrackArtist =
              playbackState.trackQueue![index].artistName;
          playbackState.currentTrackImg =
              playbackState.trackQueue![index].albumImage;
          playbackState.currentTrackClip = null;
        }

        playbackState.currentTrackIndex = index;
        playbackState.paused = false;

        if (updateGradient) {
          setImagePalette();
        }
        notifyListeners();
      }
      return r;
    }
    notifyListeners();
    return Response('Successfully setup playbackstate for next track', 200);
  }

  Future<Response> playNextTrack({bool? changeIndex}) async {
    int trackQueueLength = playbackState.inTrackClipPlaybackMode!
        ? playbackState.trackClipQueue!.length
        : playbackState.trackQueue!.length;

    Response r;
    if (trackQueueLength == 1) {
      r = await playCurrentTrack(0);
    }
    if (playbackState.currentTrackIndex == trackQueueLength - 1) {
      r = await playNewTrackInList(0);
    } else {
      r = await playNewTrackInList(playbackState.currentTrackIndex! + 1);
    }

    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.isRepeatMode = false;
      if (playbackState.inTrackClipPlaybackMode ?? false) {
        db.addTrackClipToRecentlyListened(clip: playbackState.currentTrackClip!);
      } 
    }
    return r;
  }

  Future<Response> playPreviousTrack() async {
    int trackQueueLength = playbackState.inTrackClipPlaybackMode!
        ? playbackState.trackClipQueue!.length
        : playbackState.trackQueue!.length;

    Response r;
    if (trackQueueLength == 1) {
      r = await playCurrentTrack(0);
    }
    if (playbackState.currentTrackIndex == 0) {
      r = await playNewTrackInList(trackQueueLength - 1);
    }
    else {
      r = await playNewTrackInList(playbackState.currentTrackIndex! - 1);
    }
    

    if (r.statusCode == 200 || r.statusCode == 204) {
      playbackState.isRepeatMode = false;
      if (playbackState.inTrackClipPlaybackMode ?? false) {
        db.addTrackClipToRecentlyListened(clip: playbackState.currentTrackClip!);
      } 
    }
    return r;
  }

  void shuffleQueue() {
    playbackState.isShuffleMode = true;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      playbackState.originalTrackQueue =
          List.from(playbackState.trackClipQueue!);
      playbackState.trackClipQueue?.shuffle();
      playbackState.currentTrackIndex = playbackState.trackClipQueue!
          .indexWhere((element) => element == playbackState.currentTrackClip);
    } else {
      playbackState.originalTrackQueue = List.from(playbackState.trackQueue!);
      playbackState.trackQueue?.shuffle();
      playbackState.currentTrackIndex = playbackState.trackQueue!
          .indexWhere((element) => element == playbackState.currentSong);
    }
    notifyListeners();
  }

  void undueShuffle() {
    playbackState.isShuffleMode = false;
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      playbackState.trackClipQueue =
          List.from(playbackState.originalTrackQueue!);
      playbackState.currentTrackIndex = playbackState.trackClipQueue!
          .indexWhere((element) => element == playbackState.currentTrackClip);
    } else {
      playbackState.trackQueue = List.from(playbackState.originalTrackQueue!);
      playbackState.currentTrackIndex = playbackState.trackQueue!
          .indexWhere((element) => element == playbackState.currentSong);
    }
    notifyListeners();
  }

  void addTrackClipToQueue(TrackClip track) {
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      playbackState.trackClipQueue = [...playbackState.trackClipQueue!, track];
      notifyListeners();
    }
  }

  void addTrackClipNextInQueue(TrackClip track) {
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      playbackState.trackClipQueue = [...playbackState.trackClipQueue!];
      playbackState.trackClipQueue!
          .insert(playbackState.currentTrackIndex! + 1, track);
      notifyListeners();
    }
  }

  void addTrackClipPlaylistToQueue(TrackClipPlaylist playlist) {
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      playbackState.trackClipQueue = [
        ...playbackState.trackClipQueue!,
        ...playlist.clipsDB
      ];
      if (playbackState.isShuffleMode) {
        playbackState.trackClipQueue = [
          ...playbackState.trackClipQueue!,
          ...playlist.clipsDB
        ];
      }
      notifyListeners();
    }
  }

  void addTrackClipPlaylistNextInQueue(TrackClipPlaylist playlist) {
    if (playbackState.inTrackClipPlaybackMode ?? false) {
      playbackState.trackClipQueue = [...playbackState.trackClipQueue!];
      playbackState.trackClipQueue!
          .insertAll(playbackState.currentTrackIndex! + 1, playlist.clipsDB);
      if (playbackState.isShuffleMode) {
        playbackState.originalTrackQueue = [
          ...playbackState.originalTrackQueue!
        ];
        playbackState.originalTrackQueue!
            .insertAll(playbackState.currentTrackIndex! + 1, playlist.clipsDB);
      }
      notifyListeners();
    }
  }

  void setPause(bool pause) {
    playbackState.paused = pause;
    notifyListeners();
  }

  void setProgress(int progress) {
    playbackState.currentProgress = Duration(milliseconds: progress);
    notifyListeners();
  }

  void setShuffleMode(bool shuffle) {
    playbackState.isShuffleMode = shuffle;
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.dispose();
    super.dispose();
  }

  void updatePlaybackState({
    Duration? currentProgress,
    int? currentSongIndex,
    List<Song>? songs,
    bool? paused,
    MusicLibraryService? musicLibraryService,
    Song? currentSong,
    List<TrackClip>? trackClips,
    bool? inTrackClipPlaybackMode,
    bool? inSongPlaybackMode,
    TrackClipPlaylist? trackClipPlaylist,
    TrackClip? currentTrackClip,
    List<TrackClip>? trackClipQueue,
    RadialGradient? domColorLinGradient,
    Duration? startPosition,
    bool? isShuffleMode,
    bool? isRepeatMode,
    List<Object>? originalTrackQueue,
    bool? inClipEditorMode,
    bool? autoplay,
    List<double>? clipValues,
    bool? isSeeking,
  }) {
    playbackState = playbackState.copyWith(
      currentProgress: currentProgress,
      currentSongIndex: currentSongIndex,
      songs: songs,
      paused: paused,
      musicLibraryService: musicLibraryService,
      currentSong: currentSong,
      trackClips: trackClips,
      inTrackClipPlaybackMode: inTrackClipPlaybackMode,
      inSongPlaybackMode: inSongPlaybackMode,
      trackClipPlaylist: trackClipPlaylist,
      currentTrackClip: currentTrackClip,
      trackClipQueue: trackClipQueue,
      domColorLinGradient: domColorLinGradient,
      startPosition: startPosition,
      isShuffleMode: isShuffleMode,
      isRepeatMode: isRepeatMode,
      originalTrackQueue: originalTrackQueue,
      inClipEditorMode: inClipEditorMode,
      autoplay: autoplay,
      clipValues: clipValues,
      isSeeking: isSeeking,
    );
    notifyListeners();
  }
}
